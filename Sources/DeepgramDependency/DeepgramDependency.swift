//
// https://github.com/atacan
// 05.04.24
	

import Foundation
import Dependencies
import DeepgramModels

public struct DeepgramClient {
    public var transcribeLocalAudio: @Sendable (URL, SpeechToTextParameters) async throws -> String
}

extension DeepgramClient: DependencyKey {
    static public var liveValue: Self = Self(
        transcribeLocalAudio: {fileUrl, parameters in
            // Create an instance of your parameters

            // Prepare the base URL
            guard let baseUrl = URL(string: "https://api.deepgram.com/v1/listen") else {
                fatalError("Invalid base URL")
            }
            let url = baseUrl.appending(queryItems: parameters.toQueryItems())

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
            guard (200...299).contains(httpResponse.statusCode) else {
                throw Failure.httpStatus(httpResponse.statusCode)
            }
            
            guard let mimeType = httpResponse.mimeType, mimeType == "application/json" else {
                throw Failure.responseNotJson
            }
         
#if DEBUG
            if let responseBody = String(data: data, encoding: .utf8) {
                print("📢 \(responseBody)")
            }
#endif
            
            let decoder = JSONDecoder()
            let deepgramResponse = try decoder.decode(DeepgramResponse.self, from: data)
            
#if DEBUG
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
