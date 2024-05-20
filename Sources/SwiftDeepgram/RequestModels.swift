//
// https://github.com/atacan
// 05.04.24

import Foundation

public struct DeepgramQueryParameters: Codable {
    /// Callback URL to provide if you would like your submitted audio to be processed asynchronously. 
    public var callback: String?
    /// Enable a callback method. Default: false
    public var callbackMethod: Bool?
    /// A custom topic you want the model to detect within your input audio if present. Submit up to one hundred topics.
    public var customTopic: String?
    /// When strict, the model will only return topics submitted using the custom_topic param. When extended, the model will return its own detected topics in addition to those submitted using the custom_topic param. Default: extended
    public var customTopicMode: String?
    /// Recognize speaker changes. Each word in the transcript will be assigned a speaker number starting at 0. Default: false.
    public var diarize: Bool?
    /// Version of the diarization feature to use. Only used when the diarization feature is enabled (diarize=true is passed to the API).
    public var diarizeVersion: String?
    /// Spoken dictation commands will be converted to their corresponding punctuation marks. e.g., comma to , Default: false
    public var dictation: Bool?
    /// Entity Detection identifies and extracts key entities from content in submitted audio. Default: false
    public var detectEntities: Bool?
    /// Detect the language of the provided audio. Default: false.
    public var detectLanguage: Bool?
    /// Identify and extract key topics. Default: false.
    public var detectTopics: Bool?
    /// To add an extra parameter in the query string and pass a key-value pair you would like to include in the response.
    public var extra: String?
    /// Whether to include words like "uh" and "um" in transcription output. Default: false.
    public var fillerWords: Bool?
    /// Recognizes speaker intent throughout an entire transcript. Returns a list of text segments and the intents found within each segment.
    public var intents: Bool?
    /// Uncommon proper nouns or other words to transcribe that are not a part of the model's vocabulary. Can send multiple instances in query string (for example, keywords=snuffalupagus:10&keywords=systrom:5.5).
    public var keywords: String?
    /// The BCP-47 language tag that hints at the primary spoken language. Default: en.
    public var language: String?
    /// Spoken measurements will be converted to their corresponding abbreviations. e.g., milligram to mg. Default: false
    public var measurements: Bool?
    /// AI model used to process submitted audio. Default: base-general.
    public var model: String?
    /// Transcribe each audio channel independently. Default: false.
    public var multichannel: Bool?
    /// Convert numbers from written format (e.g., one) to numerical format (e.g., 1). Default: false.
    public var numerals: Bool?
    /// Split audio into paragraphs. Default: false.
    public var paragraphs: Bool?
    /// Remove profanity from the transcript. Default: false.
    public var profanityFilter: Bool?
    /// Add punctuation and capitalization to the transcript. Default: false.
    public var punctuate: Bool?
    /// Redact sensitive information, replacing redacted content with asterisks (*). Can send multiple instances in query string (for example, redact=pci&redact=numbers). Default: false.
    public var redact: String?
    /// Terms or phrases to search for in the submitted audio and replace. Can send multiple instances in query string (for example, replace=this:that&replace=thisalso:thatalso).
    public var replace: String?
    /// Apply formatting to transcript output. When set to true, additional formatting will be applied to transcripts to improve readability. Default: false.
    public var smartFormat: Bool?
    /// Terms or phrases to search for in the submitted audio. Can send multiple instances in query string (for example, search=speech&search=Friday).
    public var search: String?
    /// Recognizes the sentiment of the entire transcript and detects a shift in sentiment throughout the transcript. Returns a list of text segments and the sentiment found within each segment.
    public var sentiment: Bool?
    /// Summarize content. Default: v2.
    public var summarize: String?
    /// Tag to associate with the request.
    public var tag: String?
    /// Detects topics throughout an entire transcript. Returns a list of text segments and the topics found within each segment.
    public var topics: Bool?
    /// Segment speech into meaningful units based on gaps in speech. Default: false.
    public var utterances: Bool?
    /// Length of time in seconds used to split utterances. Default: 0.8.
    public var uttSplit: Double?
    /// Version of the model to use. Default: latest.
    public var version: String?

    public init(
        callback: String? = nil,
        callbackMethod: Bool? = nil,
        customTopic: String? = nil,
        customTopicMode: String? = nil,
        diarize: Bool? = nil,
        diarizeVersion: String? = nil,
        dictation: Bool? = nil,
        detectEntities: Bool? = nil,
        detectLanguage: Bool? = nil,
        detectTopics: Bool? = nil,
        extra: String? = nil,
        fillerWords: Bool? = nil,
        intents: Bool? = nil,
        keywords: String? = nil,
        language: String? = nil,
        measurements: Bool? = nil,
        model: String? = nil,
        multichannel: Bool? = nil,
        numerals: Bool? = nil,
        paragraphs: Bool? = nil,
        profanityFilter: Bool? = nil,
        punctuate: Bool? = nil,
        redact: String? = nil,
        replace: String? = nil,
        smartFormat: Bool? = nil,
        search: String? = nil,
        sentiment: Bool? = nil,
        summarize: String? = nil,
        tag: String? = nil,
        topics: Bool? = nil,
        utterances: Bool? = nil,
        uttSplit: Double? = nil,
        version: String? = nil
    ) {
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
    public enum CodingKeys: String, CodingKey, CaseIterable {
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
