//
// https://github.com/atacan
// 05.04.24
	

import Foundation

public struct QueryParameters: Codable {
    public var callback: String?
    public var callbackMethod: Bool?
    public var customTopic: String?
    public var customTopicMode: String?
    public var diarize: Bool?
    public var diarizeVersion: String?
    public var dictation: Bool?
    public var detectEntities: Bool?
    public var detectLanguage: Bool?
    public var detectTopics: Bool?
    public var extra: String?
    public var fillerWords: Bool?
    public var intents: Bool?
    public var keywords: String?
    public var language: String?
    public var measurements: Bool?
    public var model: String?
    public var multichannel: Bool?
    public var numerals: Bool?
    public var paragraphs: Bool?
    public var profanityFilter: Bool?
    public var punctuate: Bool?
    public var redact: String?
    public var replace: String?
    public var smartFormat: Bool?
    public var search: String?
    public var sentiment: Bool?
    public var summarize: String?
    public var tag: String?
    public var topics: Bool?
    public var utterances: Bool?
    public var uttSplit: Double?
    public var version: String?
    
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
