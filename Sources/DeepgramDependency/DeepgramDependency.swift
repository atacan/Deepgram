#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)

import Dependencies
import Foundation
import SwiftDeepgram

public struct DeepgramClient {
    public var transcribeLocalAudio: @Sendable (URL, QueryParameters) async throws -> String
}

extension DeepgramClient: DependencyKey {
    static public var liveValue: Self = Self(
        transcribeLocalAudio: { fileUrl, parameters in
            #if DEBUG
            let startTime = DispatchTime.now()
            defer {
                let endTime = DispatchTime.now()
                let elapsedTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
                print("🕰️ Deepgram response in seconds:", Double(elapsedTime) / 1_000_000_000)
            }
            #endif
            // Create an instance of your parameters

            // Prepare the base URL
            guard let baseUrl = URL(string: "https://api.deepgram.com/v1/listen") else {
                fatalError("Invalid base URL")
            }
            let url = baseUrl.appending(queryItems: parameters.toURLQueryItems())

            // Create and configure the URLRequest
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Token \(Env.deepgramApiKey)", forHTTPHeaderField: "Authorization")

            // Create the URLSession configuration
            let session = URLSession.shared

            let (data, response) = try await session.upload(for: request, fromFile: fileUrl, delegate: nil)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw Failure.responseIsNotHTTPURLResponse
            }
            guard (200 ... 299).contains(httpResponse.statusCode) else {
                throw Failure.httpStatus(httpResponse.statusCode)
            }

            guard let mimeType = httpResponse.mimeType, mimeType == "application/json" else {
                throw Failure.responseNotJson
            }

            let decoder = JSONDecoder()
            let deepgramResponse = try decoder.decode(DeepgramResponse.self, from: data)

            #if DEBUG
            if let responseBody = String(data: data, encoding: .utf8) {
                print("📢 \(responseBody)")
            }
            dump(deepgramResponse.results.channels[0].alternatives[0].paragraphs.debugDescription)
            #endif

            return deepgramResponse.results.channels[0].alternatives[0].transcript
        }
    )
}

extension DeepgramClient {
    public enum Failure: Error {
        case responseIsNotHTTPURLResponse
        case httpStatus(NSInteger)
        case responseNotJson
    }
}

extension DependencyValues {
    public var deepgram: DeepgramClient {
        get { self[DeepgramClient.self] }
        set { self[DeepgramClient.self] = newValue }
    }
}

extension QueryParameters {
    func toURLQueryItems() -> [URLQueryItem] {
        var items = [URLQueryItem]()

        // Helper function to add a query item if the value is not nil
        func addQueryItem(name: String, value: Any?) {
            if let value = value {
                items.append(URLQueryItem(name: name, value: "\(value)"))
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
        addQueryItem(name: CodingKeys.keywords.rawValue, value: keywords)
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
