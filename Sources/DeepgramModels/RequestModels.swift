//
// https://github.com/atacan
// 05.04.24
	

import Foundation

public struct SpeechToTextParameters {
    public var smartFormat: Bool
    public var punctuation: Bool
    public var model: String
    public var language: String
    
    public init(smartFormat: Bool = false, 
                punctuation: Bool = true,
                model: String = "nova-2", language: String = "en-US") {
        self.smartFormat = smartFormat
        self.punctuation = punctuation
        self.model = model
        self.language = language
    }
    
    public func toQueryItems() -> [URLQueryItem] {
        return [
            URLQueryItem(name: "smart_format", value: "\(smartFormat)"),
            URLQueryItem(name: "punctuation", value: "\(punctuation)"),
            URLQueryItem(name: "model", value: model),
            URLQueryItem(name: "language", value: language)
        ]
    }
}

//extension URL {
//    public func appending(queryItems: [URLQueryItem]) -> URL {
//        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return self }
//        urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems
//        return urlComponents.url ?? self
//    }
//}
