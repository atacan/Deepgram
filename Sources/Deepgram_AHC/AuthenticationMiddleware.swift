import AsyncHTTPClient
import HTTPTypes
import OpenAPIRuntime

#if os(Linux)
@preconcurrency import struct Foundation.URL
@preconcurrency import struct Foundation.Data
@preconcurrency import struct Foundation.Date
#else
import struct Foundation.URL
import struct Foundation.Data
import struct Foundation.Date
#endif

/// Injects an authorization header to every request.
public struct AuthenticationMiddleware: ClientMiddleware {
    public init(apiToken: String) {
        self.apiToken = apiToken
    }

    /// The service account token
    public var apiToken: String

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        request.headerFields[.authorization] = "Token \(apiToken)"
        return try await next(request, body, baseURL)
    }
}