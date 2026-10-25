import Deepgram
import DeepgramTypes
import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing

private struct TranscriptionTransport: ClientTransport {
    var status: Int = 200
    var json: String
    var expectedQuery: [String: [String]] = [:]

    func send(_ request: HTTPRequest, body: HTTPBody?, baseURL: URL, operationID: String) async throws -> (HTTPResponse, HTTPBody?) {
        #expect(operationID == Operations.transcribe.id)
        let components = try #require(URLComponents(string: "https://api.deepgram.com" + (request.path ?? "")))
        for (name, expected) in expectedQuery {
            #expect(components.queryItems?.filter { $0.name == name }.compactMap(\.value) == expected)
        }
        return (HTTPResponse(status: .init(code: status), headerFields: [.contentType: "application/json"]), HTTPBody(json))
    }
}

private func transcriptionClient(status: Int = 200, json: String, expectedQuery: [String: [String]] = [:]) -> Client {
    Client(
        serverURL: URL(string: "https://api.deepgram.com")!,
        transport: TranscriptionTransport(status: status, json: json, expectedQuery: expectedQuery),
        authentication: .apiKey("offline-key")
    )
}

struct TranscriptionRegressionTests {
    @Test func preservesCapturedChannelWordDetails() async throws {
        let url = try #require(Bundle.module.url(forResource: "captured-nova3-diarized-utterances", withExtension: "json", subdirectory: "Resources"))
        let json = try String(contentsOf: url, encoding: .utf8)
        let response = try await transcriptionClient(json: json).transcribe(.init(body: .binary(HTTPBody("audio"))))
        let decoded = try response.ok.body.json
        guard case .ListenV1Response(let transcript) = decoded else {
            Issue.record("Expected full transcript")
            return
        }
        let words = try #require(transcript.results.channels.first?.alternatives?.first?.words)
        #expect(words.count == 62)
        #expect(words.allSatisfy { $0.speaker == 0 && $0.speaker_confidence != nil && $0.punctuated_word != nil })
        #expect(transcript.metadata.created.timeIntervalSince1970 > 0)
    }

    @Test func allowsOptionalWordDetailsAndLanguage() throws {
        let decoder = JSONDecoder()
        let plain = try decoder.decode(
            Components.Schemas.ListenV1ResponseResultsChannelsItemsAlternativesItemsWordsItems.self,
            from: Data(#"{"word":"hola","start":0,"end":1,"confidence":1,"language":"es"}"#.utf8)
        )
        #expect(plain.language == "es")
        #expect(plain.speaker == nil)
        #expect(plain.speaker_confidence == nil)
        #expect(plain.punctuated_word == nil)
    }

    @Test func encodesRepeatedRedactionAndAudioParameters() async throws {
        let client = transcriptionClient(
            json: #"{"request_id":"offline"}"#,
            expectedQuery: [
                "redact": ["phi", "name", "dob", "ssn"],
                "sample_rate": ["16000"], "channels": ["2"], "diarize_model": ["latest"],
                "language_hint": ["en", "es"],
            ]
        )
        _ = try await client.transcribe(
            .init(
                query: .init(
                    redact: .V1ListenPostParametersRedact1(["phi", "name", "dob", "ssn"]),
                    sample_rate: 16000,
                    channels: 2,
                    diarize_model: "latest",
                    language_hint: ["en", "es"]
                ),
                body: .binary(HTTPBody("audio"))
            )
        )
    }

    @Test(arguments: [400, 401, 402, 429])
    func decodesTypedErrors(status: Int) async throws {
        let json = #"{"err_code":"INVALID_AUTH","err_msg":"Invalid credentials.","request_id":"uuid"}"#
        let response = try await transcriptionClient(status: status, json: json).transcribe(.init(body: .binary(HTTPBody("audio"))))
        let error: Components.Schemas.ErrorResponse
        switch response {
        case .badRequest(let value): error = try value.body.json
        case .unauthorized(let value): error = try value.body.json
        case .code402(let value): error = try value.body.json
        case .tooManyRequests(let value): error = try value.body.json
        default:
            Issue.record("Expected typed error for status \(status)")
            return
        }
        guard case .ErrorResponseLegacyError(let value) = error else {
            Issue.record("Expected legacy error")
            return
        }
        #expect(value.err_msg == "Invalid credentials.")
        #expect(value.request_id == "uuid")
    }

    @Test func decodesCapturedUnauthorizedError() async throws {
        let url = try #require(Bundle.module.url(forResource: "captured-error-401", withExtension: "json", subdirectory: "Resources"))
        let json = try String(contentsOf: url, encoding: .utf8)
        let response = try await transcriptionClient(status: 401, json: json).transcribe(.init(body: .binary(HTTPBody("audio"))))
        guard case .ErrorResponseLegacyError(let error) = try response.unauthorized.body.json else {
            Issue.record("Expected captured legacy error")
            return
        }
        #expect(error.err_code == "INVALID_AUTH")
        #expect(error.err_msg == "Invalid credentials.")
        #expect(error.request_id != nil)
    }

    @Test func distinguishesModernErrors() async throws {
        let json = #"{"category":"INVALID_JSON","message":"Invalid JSON submitted.","details":"Missing field","request_id":"uuid"}"#
        let response = try await transcriptionClient(status: 400, json: json).transcribe(.init(body: .binary(HTTPBody("audio"))))
        guard case .ErrorResponseModernError(let error) = try response.badRequest.body.json else {
            Issue.record("Expected modern error with message preserved")
            return
        }
        #expect(error.message == "Invalid JSON submitted.")
        #expect(error.details == "Missing field")
    }

    @Test func preservesTextErrorShape() throws {
        let error = try JSONDecoder().decode(Components.Schemas.ErrorResponse.self, from: Data(#""Request failed""#.utf8))
        #expect(error == .ErrorResponseTextError("Request failed"))
    }

    @Test func dateTranscoderRejectsInvalidInputAndRoundTrips() throws {
        let transcoder = DeepgramDateTranscoder()
        #expect(throws: (any Error).self) { try transcoder.decode("not-a-date") }
        let date = Date(timeIntervalSince1970: 1_791_038_437.263)
        #expect(abs(try transcoder.decode(transcoder.encode(date)).timeIntervalSince1970 - date.timeIntervalSince1970) < 0.001)
    }
}
