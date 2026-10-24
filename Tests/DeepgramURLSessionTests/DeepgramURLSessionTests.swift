import Deepgram
import DeepgramURLSession
import Foundation
import OpenAPIRuntime
import Testing

struct DeepgramURLSessionTests {
    @Test func factoryRejectsMissingCredentialsBeforeSending() async throws {
        let client = Client.urlSession(serverURL: URL(string: "https://api.deepgram.com")!)
        do {
            _ = try await client.projects(.init())
            Issue.record("Expected missing credentials to fail")
        } catch let error as ClientError {
            #expect(error.underlyingError is AuthenticationError)
        }
    }
}
