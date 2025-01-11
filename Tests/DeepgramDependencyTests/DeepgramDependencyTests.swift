//
// https://github.com/atacan
// 05.04.24
	

import XCTest
import Dependencies
import Foundation
@testable import DeepgramDependency
@testable import Deepgram

final class DeepgramDependencyTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDecoding() throws {
        let replaced = sampleResponse//.replacingOccurrences(of: #"transcript":"\\n"#, with: #"transcript":""#)
        let data = replaced.data(using: .utf8)!
        let decoder = JSONDecoder()
        let response = try decoder.decode(DeepgramResponse.self, from: data)
    }
    
    func testQueryParametersEncoding() throws {
        let parameters = DeepgramQueryParameters(keywords: .init(words: ["systrom", "krieger"]), language: .chineseMandarinTraditional)
        let query = parameters.toURLQueryItems()
        guard let baseUrl = URL(string: "https://api.deepgram.com/v1/listen") else {
            throw DeepgramClient.Failure.invalidBaseURL
        }
        let url = baseUrl.appending(queryItems: parameters.toURLQueryItems())
        XCTAssertEqual("https://api.deepgram.com/v1/listen?keywords=systrom&keywords=krieger&language=zh-TW", url.absoluteString)
    }

    func testLiveValue() async throws {
        let url = URL(filePath: "/Users/atacan/Documents/myway/_Develop/DownloadedRepos/whisper.cpp/samples/jfk.wav")
//        let url = URL(filePath: "/Users/atacan/Downloads/Deepgram Test.m4a")
        var parameters = DeepgramQueryParameters()
        parameters.smartFormat = true
        parameters.punctuate = true
        parameters.model = "nova-2"
        parameters.language = .english

        let apiKey = getEnvironmentVariable("DEEPGRAM_API_TOKEN")!
        
        let text = try await DeepgramClient.liveValue.transcribeLocalAudio(
          apiKey: apiKey,
          baseUrlString: "https://api.deepgram.com",
          fileUrl: url,
          parameters: parameters
        )
        
        XCTAssertEqual("And so my fellow Americans, ask not what your country can do for you, ask what you can do for your country.", text)
    }

}

let sampleResponse = #"""
{
  "results" : {
    "channels" : [
      {
        "alternatives" : [
          {
            "transcript" : "This is a recording that I made to test Deepgram speech to text API. I am using Philips Speechmic 3 microphone. This microphone is great for dictation.",
            "words" : [
              {
                "word" : "this",
                "punctuated_word" : "This",
                "end" : 0.88,
                "confidence" : 0.99760157000000005,
                "start" : 0.56000000000000005
              },
              {
                "word" : "is",
                "punctuated_word" : "is",
                "end" : 1.1999998999999999,
                "confidence" : 0.99975723000000005,
                "start" : 0.88
              },
              {
                "word" : "a",
                "punctuated_word" : "a",
                "end" : 1.5999999,
                "confidence" : 0.99876180000000003,
                "start" : 1.1999998999999999
              },
              {
                "word" : "recording",
                "punctuated_word" : "recording",
                "end" : 2.1000000000000001,
                "confidence" : 0.99996969999999996,
                "start" : 1.5999999
              },
              {
                "word" : "that",
                "punctuated_word" : "that",
                "end" : 2.3999999000000001,
                "confidence" : 0.99993109999999996,
                "start" : 2.1599998
              },
              {
                "word" : "i",
                "punctuated_word" : "I",
                "end" : 2.7200000000000002,
                "confidence" : 0.99988449999999995,
                "start" : 2.3999999000000001
              },
              {
                "word" : "made",
                "punctuated_word" : "made",
                "end" : 3.2200000000000002,
                "confidence" : 0.99965179999999998,
                "start" : 2.7200000000000002
              },
              {
                "word" : "to",
                "punctuated_word" : "to",
                "end" : 3.52,
                "confidence" : 0.99985120000000005,
                "start" : 3.2799999999999998
              },
              {
                "word" : "test",
                "punctuated_word" : "test",
                "end" : 4.0199999999999996,
                "confidence" : 0.99989605000000004,
                "start" : 3.52
              },
              {
                "word" : "deepgram",
                "punctuated_word" : "Deepgram",
                "end" : 5.2199999999999998,
                "confidence" : 0.99846435,
                "start" : 4.7199999999999998
              },
              {
                "word" : "speech",
                "punctuated_word" : "speech",
                "end" : 7.8949999999999996,
                "confidence" : 0.89791889999999996,
                "start" : 7.4950000000000001
              },
              {
                "word" : "to",
                "punctuated_word" : "to",
                "end" : 8.1349999999999998,
                "confidence" : 0.99785570000000001,
                "start" : 7.8949999999999996
              },
              {
                "word" : "text",
                "punctuated_word" : "text",
                "end" : 8.6349999999999998,
                "confidence" : 0.99543420000000005,
                "start" : 8.1349999999999998
              },
              {
                "word" : "api",
                "punctuated_word" : "API.",
                "end" : 9.2750000000000004,
                "confidence" : 0.94150984000000004,
                "start" : 8.7750000000000004
              },
              {
                "word" : "i",
                "punctuated_word" : "I",
                "end" : 9.9749999999999996,
                "confidence" : 0.99419785000000005,
                "start" : 9.8149999999999995
              },
              {
                "word" : "am",
                "punctuated_word" : "am",
                "end" : 10.215,
                "confidence" : 0.99941694999999997,
                "start" : 9.9749999999999996
              },
              {
                "word" : "using",
                "punctuated_word" : "using",
                "end" : 10.715,
                "confidence" : 0.99978259999999997,
                "start" : 10.215
              },
              {
                "word" : "philips",
                "punctuated_word" : "Philips",
                "end" : 11.355,
                "confidence" : 0.7039782,
                "start" : 10.855
              },
              {
                "word" : "speechmic",
                "punctuated_word" : "Speechmic",
                "end" : 12.395,
                "confidence" : 0.61520432999999997,
                "start" : 11.895
              },
              {
                "word" : "3",
                "punctuated_word" : "3",
                "end" : 13.434998999999999,
                "confidence" : 0.91121339999999995,
                "start" : 12.934998999999999
              },
              {
                "word" : "microphone",
                "punctuated_word" : "microphone.",
                "end" : 14.475,
                "confidence" : 0.93569840000000004,
                "start" : 13.975
              },
              {
                "word" : "this",
                "punctuated_word" : "This",
                "end" : 15.98,
                "confidence" : 0.99592762999999995,
                "start" : 15.74
              },
              {
                "word" : "microphone",
                "punctuated_word" : "microphone",
                "end" : 16.48,
                "confidence" : 0.99971049999999995,
                "start" : 15.98
              },
              {
                "word" : "is",
                "punctuated_word" : "is",
                "end" : 17.18,
                "confidence" : 0.99898330000000002,
                "start" : 16.859999999999999
              },
              {
                "word" : "great",
                "punctuated_word" : "great",
                "end" : 17.68,
                "confidence" : 0.99853146000000004,
                "start" : 17.18
              },
              {
                "word" : "for",
                "punctuated_word" : "for",
                "end" : 18.399999999999999,
                "confidence" : 0.9992453,
                "start" : 17.899999999999999
              },
              {
                "word" : "dictation",
                "punctuated_word" : "dictation.",
                "end" : 19.760000000000002,
                "confidence" : 0.98402566000000002,
                "start" : 19.260000000000002
              }
            ],
            "confidence" : 0.99853146000000004,
            "paragraphs" : {
              "transcript":"\nThis is a recording that I made to test Deepgram speech to text API. I am using Philips Speechmic 3 microphone. This microphone is great for dictation.",
              "paragraphs" : [
                {
                  "num_words" : 27,
                  "end" : 19.760000000000002,
                  "sentences" : [
                    {
                      "start" : 0.56000000000000005,
                      "text" : "This is a recording that I made to test Deepgram speech to text API.",
                      "end" : 9.2750000000000004
                    },
                    {
                      "start" : 9.8149999999999995,
                      "text" : "I am using Philips Speechmic 3 microphone.",
                      "end" : 14.475
                    },
                    {
                      "start" : 15.74,
                      "text" : "This microphone is great for dictation.",
                      "end" : 19.760000000000002
                    }
                  ],
                  "start" : 0.56000000000000005
                }
              ]
            }
          }
        ]
      }
    ]
  },
  "metadata" : {
    "sha256" : "be53166fa5d63b6ceeafa44deb4b627ffdbcf8b07eac12a0f7b9f2ac23489b99",
    "models" : [
      "30089e05-99d1-4376-b32e-c263170674af"
    ],
    "channels" : 1,
    "transaction_key" : "deprecated",
    "request_id" : "b5d79748-d2cc-446a-b14d-f6d3e1165798",
    "created" : "2024-04-05T19:45:23.840Z",
    "duration" : 22.176687000000001,
    "model_info" : {
      "30089e05-99d1-4376-b32e-c263170674af" : {
        "name" : "2-general-nova",
        "version" : "2024-01-09.29447",
        "arch" : "nova-2"
      }
    }
  }
}
"""#
