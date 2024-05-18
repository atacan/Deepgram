import AsyncHTTPClient
import SwiftDeepgram
import Dependencies
import Foundation

public struct DeepgramServerDependency{
    public var transcribeLocalFile: @Sendable (_ audio: HTTPClientRequest.Body, SwiftDeepgram.QueryParameters) async throws -> DeepgramResponse
}

extension DeepgramServerDependency: DependencyKey {
    public static var liveValue: Self = {
        
        var request = HTTPClientRequest(url: "https://api.deepgram.com/v1/listen")
        request.headers.replaceOrAdd(name: "Authorization", value: "Token \(SwiftDeepgram.Env.deepgramApiKey)")
        
        return Self(
            transcribeLocalFile: { [request] audio, queryParameters in
                var localFileRequest = request
                localFileRequest.method = .POST
                localFileRequest.headers.replaceOrAdd(name: "Content-Type", value: "audio/wav")
                localFileRequest.body = audio
                let response = try await HTTPClient.shared.execute(localFileRequest, timeout: .minutes(20))
                let buffer = try await response.body.collect(upTo: 1024 * 1024 * 2)
                let output = try JSONDecoder().decode(DeepgramResponse.self, from: buffer)
                
                return output
            }
        )
    }()
}


extension DependencyValues {
    public var deepgram: DeepgramServerDependency {
        get { self[DeepgramServerDependency.self] }
        set { self[DeepgramServerDependency.self] = newValue }
    }
}
