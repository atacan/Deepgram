#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)

import Dependencies
import DependenciesMacros
import Foundation
import Deepgram
import AudioDataStreamClient
import WebSocketDependency

@DependencyClient
public struct DeepgramClient: Sendable {
    public var transcribeLocalAudio: @Sendable (_ apiKey: String, _ baseUrlString: String, _ fileUrl: URL, _ parameters: DeepgramQueryParameters) async throws -> String
    /// record, send audio via web socket and collect transcripts chunk by chunk, and return them in one go
    public var streamAndCollect: @Sendable (_ apiKey: String, _ baseUrlString: String, _ parameters: DeepgramQueryParameters) async throws -> String
    public var stopStreamAndCollect: @Sendable () async throws -> Void
}

extension DeepgramClient: DependencyKey {
    static public var liveValue: Self = {
        
        let webSocketId = WebSocketClient.ID()
        @Dependency(\.continuousClock) var clock
        
        return Self(
            transcribeLocalAudio: { apiKey, baseUrlString, fileUrl, parameters in
#if DEBUG
                let startTime = DispatchTime.now()
                defer {
                    let endTime = DispatchTime.now()
                    let elapsedTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
                    print("🕰️ Deepgram response in seconds:", Double(elapsedTime) / 1_000_000_000)
                }
#endif
                
                // Prepare the base URL
                guard let baseUrl = URL(string: baseUrlString) else {
                    throw Failure.invalidBaseURL
                }
                let url = baseUrl.appending(queryItems: parameters.toURLQueryItems())
                
                // Create and configure the URLRequest
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
                
                // Create the URLSession configuration
                let session = URLSession.shared
                
                let (data, response) = try await session.upload(for: request, fromFile: fileUrl, delegate: nil)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw Failure.responseIsNotHTTPURLResponse
                }
                guard (200 ... 299).contains(httpResponse.statusCode) else {
                    throw Failure.httpStatus(httpResponse.statusCode)
                }
                
                //            guard let mimeType = httpResponse.mimeType, mimeType == "application/json" else {
                //                throw Failure.responseNotJson
                //            }
                
                let decoder = JSONDecoder()
                let deepgramResponse = try decoder.decode(DeepgramResponse.self, from: data)
                let firstAlternative = deepgramResponse.results.channels[0].alternatives[0]
                if let paragraphs = firstAlternative.paragraphs {
                    return paragraphs.paragraphs.map({ paragraph in
                        return paragraph.sentences.map(\.text).joined(separator: " ")
                    })
                    .joined(separator: "\n\n")
                } else {
                    return firstAlternative.transcript
                }
            },
            streamAndCollect: { apiKey, baseUrlString, parameters in
                // Prepare the base URL
                guard let baseUrl = URL(string: baseUrlString) else {
                    throw Failure.invalidBaseURL
                }
                let url = baseUrl.appending(queryItems: parameters.toURLQueryItems())
                
                // Create and configure the URLRequest
                var request = URLRequest(url: url)
                request.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
                
                @Dependency(\.audioDataStream) var audioDataStreamClient
                @Dependency(\.webSocket) var webSocketClient
                
                // Open WebSocket connection
                let actions = await webSocketClient.open(id: webSocketId, url: request, protocols: [])
                
                return try await withThrowingTaskGroup(of: Void.self) { group in
                    let collectedTranscript = LockIsolated("")
                    
                    // Process WebSocket messages
                    for await action in actions {
                        switch action {
                        case .didOpen:
                            print("WebSocket did open")
                            // Start audio streaming
                            group.addTask {
                                for try await data in await audioDataStreamClient.startTask() {
                                    try await webSocketClient.send(id: webSocketId, message: .data(data))
//                                    print(data.count, "of data sent", terminator: "")
//                                    print(".", terminator: "")
                                }
                            }
                            
                            // Start collecting transcripts
                            group.addTask {
                                let decoder = JSONDecoder()
                                for await result in try await webSocketClient.receive(id: webSocketId) {
                                    switch result {
                                    case .success(let message):
                                        switch message {
                                        case .string(let text):
                                            do {
                                                let deepgramResponse = try decoder.decode(DeepgramStreamingResponse.self, from: text.data(using: .utf8)!)
                                                let transcript = deepgramResponse.channel.alternatives[0].transcript
                                                collectedTranscript.withValue({$0 += " " + transcript})
                                                print(transcript)
                                            } catch {
                                                // Check if it's a finalization message
                                                if let _ = try? decoder.decode(DeepgramFinalizeConfirmation.self, from: text.data(using: .utf8)!) {
                                                    // In most cases, you will receive this response, but it is not guaranteed if there is no significant amount of audio data to process. https://developers.deepgram.com/docs/finalize
                                                    print("Finalization received")
                                                }
                                            }
                                        case .data(let data):
                                            print(data.count, "of data received")
                                        }
                                    case .failure(let error):
                                        print("WebSocket did receive failure", error)
                                        throw error
                                    }
                                }
                            }
                            
//                            group.addTask {
//                                // Keep-alive ping
//                                while !Task.isCancelled {
//                                    try await clock.sleep(for: .seconds(3))
//                                    try? await webSocketClient.sendPing(id: webSocketId)
//                                    try await webSocketClient.send(id: webSocketId, message: .string(##"{"type": "KeepAlive"}"##))
//                                    print("ping sent")
//                                }
//                            }
                            
                        case .didClose(_, _):
                            print("WebSocket did close")
                            // WebSocket closed, we can return the collected transcript
                            return collectedTranscript.value.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    }
                    
                    // If we reach here, it means the WebSocket closed unexpectedly
                    throw Failure.unexpectedWebSocketClosure
                }
            },
            
            stopStreamAndCollect: {
                @Dependency(\.audioDataStream) var audioDataStreamClient
                @Dependency(\.webSocket) var webSocketClient
                
                await audioDataStreamClient.stop()
                try await webSocketClient.send(id: webSocketId, message: .string(##"{ "type": "Finalize"}"##))
                try await clock.sleep(for: .seconds(0.3))
                try await webSocketClient.send(id: webSocketId, message: .string(##"{ "type": "CloseStream"}"##))
                try await webSocketClient.close(id: webSocketId, code: .normalClosure, reason: nil)
            }
        )
    }()
}

extension DeepgramClient {
    public enum Failure: Error, LocalizedError {
        case invalidBaseURL
        case responseIsNotHTTPURLResponse
        case httpStatus(NSInteger)
        case responseNotJson
        case unexpectedWebSocketClosure

        public var errorDescription: String? {
            switch self {
            case .invalidBaseURL:
                return "invalidBaseURL"
            case .responseIsNotHTTPURLResponse:
                return "responseIsNotHTTPURLResponse"
            case .httpStatus(let nSInteger):
                return "httpStatus \(nSInteger)"
            case .responseNotJson:
                return "responseNotJson"
            case .unexpectedWebSocketClosure:
                return "unexpectedWebSocketClosure"
            }
        }
    }
}

extension DependencyValues {
    public var deepgram: DeepgramClient {
        get { self[DeepgramClient.self] }
        set { self[DeepgramClient.self] = newValue }
    }
}

extension DeepgramQueryParameters {
    func toURLQueryItems() -> [URLQueryItem] {
        var items = [URLQueryItem]()

        // Helper function to add a query item if the value is not nil
        func addQueryItem(name: String, value: Any?) {
            if let value = value {
                items.append(URLQueryItem(name: name, value: "\(value)"))
            }
        }

        // Helper function to add a query item if the value is not nil
        func addKeywords() {
            if let keywords = self.keywords {
                keywords.words.forEach { word in
                    items.append(URLQueryItem(name: "keywords", value: word))
                }
            }
        }

        addQueryItem(name: CodingKeys.callback.rawValue, value: callback)
        addQueryItem(name: CodingKeys.callbackMethod.rawValue, value: callbackMethod)
        addQueryItem(name: CodingKeys.customTopic.rawValue, value: customTopic)
        addQueryItem(name: CodingKeys.customTopicMode.rawValue, value: customTopicMode)
        addQueryItem(name: CodingKeys.diarize.rawValue, value: diarize)
        addQueryItem(name: CodingKeys.diarizeVersion.rawValue, value: diarizeVersion)
        addQueryItem(name: CodingKeys.dictation.rawValue, value: dictation)
        addQueryItem(name: CodingKeys.detectEntities.rawValue, value: detectEntities)
        addQueryItem(name: CodingKeys.detectLanguage.rawValue, value: detectLanguage)
        addQueryItem(name: CodingKeys.detectTopics.rawValue, value: detectTopics)
        addQueryItem(name: CodingKeys.extra.rawValue, value: extra)
        addQueryItem(name: CodingKeys.fillerWords.rawValue, value: fillerWords)
        addQueryItem(name: CodingKeys.intents.rawValue, value: intents)
//        addQueryItem(name: CodingKeys.keywords.rawValue, value: keywords)
        addKeywords()
        addQueryItem(name: CodingKeys.language.rawValue, value: language)
        addQueryItem(name: CodingKeys.measurements.rawValue, value: measurements)
        addQueryItem(name: CodingKeys.model.rawValue, value: model)
        addQueryItem(name: CodingKeys.multichannel.rawValue, value: multichannel)
        addQueryItem(name: CodingKeys.numerals.rawValue, value: numerals)
        addQueryItem(name: CodingKeys.paragraphs.rawValue, value: paragraphs)
        addQueryItem(name: CodingKeys.profanityFilter.rawValue, value: profanityFilter)
        addQueryItem(name: CodingKeys.punctuate.rawValue, value: punctuate)
        addQueryItem(name: CodingKeys.redact.rawValue, value: redact)
        addQueryItem(name: CodingKeys.replace.rawValue, value: replace)
        addQueryItem(name: CodingKeys.smartFormat.rawValue, value: smartFormat)
        addQueryItem(name: CodingKeys.search.rawValue, value: search)
        addQueryItem(name: CodingKeys.sentiment.rawValue, value: sentiment)
        addQueryItem(name: CodingKeys.summarize.rawValue, value: summarize)
        addQueryItem(name: CodingKeys.tag.rawValue, value: tag)
        addQueryItem(name: CodingKeys.topics.rawValue, value: topics)
        addQueryItem(name: CodingKeys.utterances.rawValue, value: utterances)
        addQueryItem(name: CodingKeys.uttSplit.rawValue, value: uttSplit)
        addQueryItem(name: CodingKeys.version.rawValue, value: version)

        return items
    }
}

#endif
