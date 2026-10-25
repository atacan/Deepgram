import Deepgram
import DeepgramAsyncHTTPClient
import DeepgramTypes
import DeepgramURLSession
import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing

private let serverURL = URL(string: "https://api.deepgram.com")!
private let agentJSON = #"{"agent_id":"agent","config":{},"created_at":"2026-10-03T14:40:37.263Z"}"#

private func fixtureResponse(created: String = "2026-10-03T14:40:37.263Z") -> (HTTPResponse, HTTPBody?) {
    (HTTPResponse(status: .ok, headerFields: [.contentType: "application/json"]), HTTPBody(agentJSON.replacingOccurrences(of: "2026-10-03T14:40:37.263Z", with: created)))
}

private func fetchAgent(_ client: Client) async throws -> Components.Schemas.AgentConfigurationV1 {
    let response = try await client.projects_project_id_Agents_agent_id(
        .init(path: .init(project_id: "project", agent_id: "agent"))
    )
    return try response.ok.body.json
}

// Short-circuit the network while retaining the factory's HTTP response conversion.
// Authentication is verified separately using a terminal mock transport below.
private struct FixtureMiddleware: ClientMiddleware {
    var created = "2026-10-03T14:40:37.263Z"
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        #expect(request.path == "/v1/projects/project/agents/agent")
        #expect(baseURL == serverURL)
        return fixtureResponse(created: created)
    }
}

private enum Factory: CaseIterable, Sendable {
    case urlSession, asyncHTTPClient, customTransport

    func makeClient(configuration: Configuration? = nil, created: String = "2026-10-03T14:40:37.263Z") -> Client {
        switch (self, configuration) {
        case (.customTransport, nil):
            return Client(serverURL: serverURL, transport: AuthenticationTransport(expectedAuthorization: "Token test-key", created: created), authentication: .apiKey("test-key"))
        case (.customTransport, .some(let configuration)):
            return Client(
                serverURL: serverURL,
                configuration: configuration,
                transport: AuthenticationTransport(expectedAuthorization: "Token test-key", created: created),
                authentication: .apiKey("test-key")
            )
        case (.urlSession, nil):
            return .urlSession(serverURL: serverURL, authentication: .apiKey("test-key"), middlewares: [FixtureMiddleware(created: created)])
        case (.asyncHTTPClient, nil):
            return .asyncHTTPClient(serverURL: serverURL, authentication: .apiKey("test-key"), middlewares: [FixtureMiddleware(created: created)])
        case (.urlSession, .some(let configuration)):
            return .urlSession(serverURL: serverURL, configuration: configuration, middlewares: [FixtureMiddleware(created: created)])
        case (.asyncHTTPClient, .some(let configuration)):
            return .asyncHTTPClient(serverURL: serverURL, configuration: configuration, middlewares: [FixtureMiddleware(created: created)])
        }
    }
}

private struct OverrideDateTranscoder: DateTranscoder {
    func encode(_ date: Date) throws -> String { "caller-override" }
    func decode(_ value: String) throws -> Date { Date(timeIntervalSince1970: 42) }
}

struct FactoryDefaultsTests {
    @Test(arguments: Factory.allCases, ["2026-10-03T14:40:37.263Z", "2026-10-03T14:40:37Z"])
    fileprivate func decodesISO8601Dates(factory: Factory, created: String) async throws {
        let agent = try await fetchAgent(factory.makeClient(created: created))
        #expect(agent.agent_id == "agent")
        let createdStringHasFraction = created.contains(".")
        let created = try #require(agent.created_at)
        #expect(abs(created.timeIntervalSince1970 - (createdStringHasFraction ? 1_791_038_437.263 : 1_791_038_437)) < 0.001)
    }

    @Test(arguments: Factory.allCases)
    fileprivate func honorsExplicitConfiguration(factory: Factory) async throws {
        let agent = try await fetchAgent(factory.makeClient(configuration: .init(dateTranscoder: OverrideDateTranscoder())))
        #expect(agent.created_at == Date(timeIntervalSince1970: 42))
    }
}

private struct AuthenticationTransport: ClientTransport {
    var expectedAuthorization: String?
    var created = "2026-10-03T14:40:37.263Z"

    func send(_ request: HTTPRequest, body: HTTPBody?, baseURL: URL, operationID: String) async throws -> (HTTPResponse, HTTPBody?) {
        #expect(request.headerFields[.authorization] == expectedAuthorization)
        #expect(operationID == Operations.projects_project_id_Agents_agent_id.id)
        return fixtureResponse(created: created)
    }
}

private struct UnreachableTransport: ClientTransport {
    func send(_ request: HTTPRequest, body: HTTPBody?, baseURL: URL, operationID: String) async throws -> (HTTPResponse, HTTPBody?) {
        Issue.record("Authentication must fail before the transport is called")
        return fixtureResponse()
    }
}

private actor KeyProvider {
    private(set) var calls = 0
    func key() -> String {
        calls += 1
        return "rotating-key"
    }
}

struct AuthenticationTests {
    private func makeClient(_ authentication: Authentication, expected: String) -> Client {
        Client(
            serverURL: serverURL,
            configuration: .init(dateTranscoder: .iso8601WithFractionalSeconds),
            transport: AuthenticationTransport(expectedAuthorization: expected),
            authentication: authentication
        )
    }

    @Test func sendsDeepgramTokenPrefix() async throws {
        _ = try await fetchAgent(makeClient(.apiKey("test-key"), expected: "Token test-key"))
    }

    @Test func supportsNamedCredentials() async throws {
        _ = try await fetchAgent(makeClient(.credentials(["ApiKeyAuth": .init("named-key")]), expected: "Token named-key"))
    }

    @Test func supportsJWTAlternative() async throws {
        _ = try await fetchAgent(makeClient(.bearer("test-jwt"), expected: "Bearer test-jwt"))
    }

    @Test func evaluatesProviderForEveryRequest() async throws {
        let provider = KeyProvider()
        let client = makeClient(.apiKey { await provider.key() }, expected: "Token rotating-key")
        _ = try await fetchAgent(client)
        _ = try await fetchAgent(client)
        #expect(await provider.calls == 2)
    }

    @Test func prefersAPIKeyWhenBothCredentialsAreAvailable() async throws {
        let authentication = Authentication.credentials([
            "ApiKeyAuth": .init("preferred-key"),
            "JwtAuth": .init("jwt"),
        ])
        _ = try await fetchAgent(makeClient(authentication, expected: "Token preferred-key"))
    }

    private enum ProviderFailure: Error { case unavailable }

    @Test func propagatesProviderFailureBeforeTransport() async throws {
        let client = Client(
            serverURL: serverURL,
            transport: UnreachableTransport(),
            authentication: .apiKey { throw ProviderFailure.unavailable }
        )
        do {
            _ = try await fetchAgent(client)
            Issue.record("Expected credential provider failure")
        } catch let error as ClientError {
            #expect(error.underlyingError is ProviderFailure)
        }
    }

    @Test func rejectsMissingCredentialsBeforeTransport() async throws {
        let client = Client(serverURL: serverURL, transport: UnreachableTransport(), authentication: .none)
        do {
            _ = try await fetchAgent(client)
            Issue.record("Expected missing credentials to fail")
        } catch let error as ClientError {
            #expect(error.underlyingError is AuthenticationError)
        }
    }
}
