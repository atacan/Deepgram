import Foundation
import OpenAPIRuntime

/// Accepts Deepgram ISO-8601 dates with or without fractional seconds.
///
/// Encodes dates with fractional seconds, matching the transport factory defaults.
public struct DeepgramDateTranscoder: DateTranscoder {
    private let fractional: ISO8601DateTranscoder = .iso8601WithFractionalSeconds
    private let whole: ISO8601DateTranscoder = .iso8601

    /// Creates a transcoder accepting either ISO-8601 precision.
    public init() {}

    /// Encodes a date using ISO-8601 with fractional seconds.
    public func encode(_ date: Date) throws -> String {
        try fractional.encode(date)
    }

    /// Decodes an ISO-8601 date with optional fractional seconds.
    public func decode(_ value: String) throws -> Date {
        do {
            return try fractional.decode(value)
        } catch {
            return try whole.decode(value)
        }
    }
}
