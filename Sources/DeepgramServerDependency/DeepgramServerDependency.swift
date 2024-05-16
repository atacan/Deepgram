import AsyncHTTPClient
import HttpClientDependency
import SwiftDeepgram
import Dependencies

public struct DeepgramServerDependency{
    public var transcribeLocalFile: @Sendable (_ audio: HTTPClientRequest.Body, SwiftDeepgram.QueryParameters) async throws -> Int
}

extension DeepgramServerDependency: DependencyKey {
    public static var liveValue: Self = {
        @Dependency(\.asyncHttpClient) var asyncHttpClient
        
        var request = HTTPClientRequest(url: "https://api.deepgram.com/v1/listen")
        request.headers.replaceOrAdd(name: "Authorization", value: "Token \(SwiftDeepgram.Env.deepgramApiKey)")
        
        return Self(
            transcribeLocalFile: { [request] audio, queryParameters in
                var localFileRequest = request
                localFileRequest.method = .POST
                localFileRequest.headers.replaceOrAdd(name: "Content-Type", value: "audio/wav")
                localFileRequest.body = audio
                let response = try await asyncHttpClient.execute(localFileRequest, timeout: .minutes(20))
//                if response.status == .ok {
                    print(response)
//                }
                
                return .init(response.status.code)
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
