//
// https://github.com/atacan
// 05.04.24
	

import Foundation

public struct QueryParameters: Codable {
    public let callback: String?
    public let callbackMethod: Bool?
    public let customTopic: String?
    public let customTopicMode: String?
    public let diarize: Bool?
    public let diarizeVersion: String?
    public let dictation: Bool?
    public let detectEntities: Bool?
    public let detectLanguage: Bool?
    public let detectTopics: Bool?
    public let extra: String?
    public let fillerWords: Bool?
    public let intents: Bool?
    public let keywords: String?
    public let language: String?
    public let measurements: Bool?
    public let model: String?
    public let multichannel: Bool?
    public let numerals: Bool?
    public let paragraphs: Bool?
    public let profanityFilter: Bool?
    public let punctuate: Bool?
    public let redact: String?
    public let replace: String?
    public let smartFormat: Bool?
    public let search: String?
    public let sentiment: Bool?
    public let summarize: String?
    public let tag: String?
    public let topics: Bool?
    public let utterances: Bool?
    public let uttSplit: Double?
    public let version: String?

    // CodingKeys to map snake_case to camelCase for encoding/decoding
    public enum CodingKeys: String, CodingKey {
        case callback
        case callbackMethod = "callback_method"
        case customTopic = "custom_topic"
        case customTopicMode = "custom_topic_mode"
        case diarize
        case diarizeVersion = "diarize_version"
        case dictation
        case detectEntities = "detect_entities"
        case detectLanguage = "detect_language"
        case detectTopics = "detect_topics"
        case extra
        case fillerWords = "filler_words"
        case intents
        case keywords
        case language
        case measurements
        case model
        case multichannel
        case numerals
        case paragraphs
        case profanityFilter = "profanity_filter"
        case punctuate
        case redact
        case replace
        case smartFormat = "smart_format"
        case search
        case sentiment
        case summarize
        case tag
        case topics
        case utterances
        case uttSplit = "utt_split"
        case version
    }
}
