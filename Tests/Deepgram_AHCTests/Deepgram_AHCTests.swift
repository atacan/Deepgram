import Foundation
import HTTPTypes
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime
import Testing

@testable import Deepgram_AHC

final class Deepgram_AHCTests {
    let client = {
        // get api key from environment
        let apiToken = getEnvironmentVariable("DEEPGRAM_API_TOKEN")!
        let stsUrl = try! Servers.Server1.url()

        let authMiddleware = AuthenticationMiddleware(apiToken: apiToken)

        return Client(
            serverURL: stsUrl,
            transport: AsyncHTTPClientTransport(),
            middlewares: [
                authMiddleware
            ]
        )
    }()

    @Test
    func testDefaultListen() async throws {
        let audioFileUrl = Bundle.module.url(forResource: "Resources/amazing-things", withExtension: "wav")!
        let audioData = try Data(contentsOf: audioFileUrl)

        let response = try await client.listen(Operations.listen.Input(
            query: .init(language: .en_hyphen_GB, paragraphs: true),
            body: .binary(.init(audioData))
        ))

        dump(response)
    }
}
