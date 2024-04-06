// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let deepgramResponse = try? JSONDecoder().decode(DeepgramResponse.self, from: jsonData)

import Foundation

// MARK: - DeepgramResponse
public struct DeepgramResponse: Codable, Sendable {
    public let results: Results
    public let metadata: Metadata

    public init(results: Results, metadata: Metadata) {
        self.results = results
        self.metadata = metadata
    }
}

// MARK: - Metadata
public struct Metadata: Codable, Sendable {
    public let sha256: String
    public let models: [String]
    public let channels: Int
    public let transactionKey, requestID, created: String
    public let duration: Double
    public let modelInfo: [String: Model]

    enum CodingKeys: String, CodingKey {
        case sha256, models, channels
        case transactionKey = "transaction_key"
        case requestID = "request_id"
        case created, duration
        case modelInfo = "model_info"
    }

    public init(sha256: String, models: [String], channels: Int, transactionKey: String, requestID: String, created: String, duration: Double, modelInfo: [String: Model]) {
        self.sha256 = sha256
        self.models = models
        self.channels = channels
        self.transactionKey = transactionKey
        self.requestID = requestID
        self.created = created
        self.duration = duration
        self.modelInfo = modelInfo
    }
}

// MARK: - The30089E0599D14376B32EC263170674AF
public struct Model: Codable, Sendable {
    public let name, version, arch: String

    public init(name: String, version: String, arch: String) {
        self.name = name
        self.version = version
        self.arch = arch
    }
}

// MARK: - Results
public struct Results: Codable, Sendable {
    public let channels: [Channel]

    public init(channels: [Channel]) {
        self.channels = channels
    }
}

// MARK: - Channel
public struct Channel: Codable, Sendable {
    public let alternatives: [Alternative]

    public init(alternatives: [Alternative]) {
        self.alternatives = alternatives
    }
}

// MARK: - Alternative
public struct Alternative: Codable, Sendable {
    public let transcript: String
    public let words: [Word]
    public let confidence: Double
    public let paragraphs: Paragraphs?

    public init(transcript: String, words: [Word], confidence: Double, paragraphs: Paragraphs? = nil) {
        self.transcript = transcript
        self.words = words
        self.confidence = confidence
        self.paragraphs = paragraphs
    }
}

// MARK: - Paragraphs
public struct Paragraphs: Codable, Sendable {
    public let transcript: String
    public let paragraphs: [Paragraph]

    public init(transcript: String, paragraphs: [Paragraph]) {
        self.transcript = transcript
        self.paragraphs = paragraphs
    }
}

// MARK: - Paragraph
public struct Paragraph: Codable, Sendable {
    public let numWords: Int
    public let end: Double
    public let sentences: [Sentence]
    public let start: Double

    enum CodingKeys: String, CodingKey {
        case numWords = "num_words"
        case end, sentences, start
    }

    public init(numWords: Int, end: Double, sentences: [Sentence], start: Double) {
        self.numWords = numWords
        self.end = end
        self.sentences = sentences
        self.start = start
    }
}

// MARK: - Sentence
public struct Sentence: Codable, Sendable {
    public let start: Double
    public let text: String
    public let end: Double

    public init(start: Double, text: String, end: Double) {
        self.start = start
        self.text = text
        self.end = end
    }
}

// MARK: - Word
public struct Word: Codable, Sendable {
    public let word: String
    public let punctuatedWord: String?
    public let end, confidence, start: Double

    enum CodingKeys: String, CodingKey {
        case word
        case punctuatedWord = "punctuated_word"
        case end, confidence, start
    }

    public init(word: String, punctuatedWord: String?, end: Double, confidence: Double, start: Double) {
        self.word = word
        self.punctuatedWord = punctuatedWord
        self.end = end
        self.confidence = confidence
        self.start = start
    }
}
