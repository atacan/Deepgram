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
    
    public init(callback: String? = nil, callbackMethod: Bool? = nil, customTopic: String? = nil, customTopicMode: String? = nil, diarize: Bool? = nil, diarizeVersion: String? = nil, dictation: Bool? = nil, detectEntities: Bool? = nil, detectLanguage: Bool? = nil, detectTopics: Bool? = nil, extra: String? = nil, fillerWords: Bool? = nil, intents: Bool? = nil, keywords: String? = nil, language: String? = nil, measurements: Bool? = nil, model: String? = nil, multichannel: Bool? = nil, numerals: Bool? = nil, paragraphs: Bool? = nil, profanityFilter: Bool? = nil, punctuate: Bool? = nil, redact: String? = nil, replace: String? = nil, smartFormat: Bool? = nil, search: String? = nil, sentiment: Bool? = nil, summarize: String? = nil, tag: String? = nil, topics: Bool? = nil, utterances: Bool? = nil, uttSplit: Double? = nil, version: String? = nil) {
        self.callback = callback
        self.callbackMethod = callbackMethod
        self.customTopic = customTopic
        self.customTopicMode = customTopicMode
        self.diarize = diarize
        self.diarizeVersion = diarizeVersion
        self.dictation = dictation
        self.detectEntities = detectEntities
        self.detectLanguage = detectLanguage
        self.detectTopics = detectTopics
        self.extra = extra
        self.fillerWords = fillerWords
        self.intents = intents
        self.keywords = keywords
        self.language = language
        self.measurements = measurements
        self.model = model
        self.multichannel = multichannel
        self.numerals = numerals
        self.paragraphs = paragraphs
        self.profanityFilter = profanityFilter
        self.punctuate = punctuate
        self.redact = redact
        self.replace = replace
        self.smartFormat = smartFormat
        self.search = search
        self.sentiment = sentiment
        self.summarize = summarize
        self.tag = tag
        self.topics = topics
        self.utterances = utterances
        self.uttSplit = uttSplit
        self.version = version
    }

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
