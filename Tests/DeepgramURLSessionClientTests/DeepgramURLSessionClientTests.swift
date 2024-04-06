//
// https://github.com/atacan
// 05.04.24
	

import XCTest
import DeepgramURLSessionClient
import Foundation
import HTTPTypes
import OpenAPIRuntime
import OpenAPIURLSession

final class DeepgramURLSessionClientTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let client = Client(serverURL: URL(string: "https://api.deepgram.com/v1")!, 
                            transport: URLSessionTransport(),
                            middlewares: [AuthenticationMiddleware()]
        )
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

struct AuthenticationMiddleware: ClientMiddleware {
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        request.headerFields.append(.init(name: .authorization, value: "Token e549c898f8429bea5ae81e38c069786268d4dce5"))
        
        return try await next(request, body, baseURL)
    }
}
