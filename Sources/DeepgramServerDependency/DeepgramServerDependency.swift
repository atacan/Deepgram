import AsyncHTTPClient
import HttpClientDependency
import SwiftDeepgram
import Dependencies

public struct DeepgramServerDependency{
    var transcribeLocalFile: @Sendable (SwiftDeepgram.QueryParameters) async throws -> String
}

extension DeepgramServerDependency: DependencyKey {
    public static var liveValue: Self = {
        @Dependency(\.asyncHttpClient) var asyncHttpClient
        
        var request = HTTPClientRequest(url: "https://api.deepgram.com/v1/listen")
        request.headers.replaceOrAdd(name: "Authorization", value: "Token \(SwiftDeepgram.Env.deepgramApiKey)")
        
        return Self(
            transcribeLocalFile: { [request] queryParameters in
                var localFileRequest = request
                localFileRequest.method = .POST
                localFileRequest.headers.replaceOrAdd(name: "Content-Type", value: "audio/wav")
                
                return "todo"
            }
        )
    }()
}
