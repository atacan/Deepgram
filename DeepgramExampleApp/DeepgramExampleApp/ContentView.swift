//
// https://github.com/atacan
// 10.10.24
	
import Foundation
import AVFoundation
import SwiftUI
import Dependencies
import DeepgramDependency
import Deepgram

struct ContentView: View {
    var body: some View {
        VStack {
            RecordingView()
        }
        .padding()
    }
}

@Observable
class RecordingViewModel {
    
    @ObservationIgnored
    @Dependency(\.deepgram) var deepgramClient
    
    var isRecording = false
    
    func startRecording() async throws {
        isRecording = true
        print("Recording started")

        let transcript = try await deepgramClient.streamAndCollect(
            apiKey: ProcessInfo.processInfo.environment["apikey"]!,
//            apiKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"]!,
            baseUrlString: "ws://localhost:8080/echo?model=deepgram.base&output_format=json",
//            baseUrlString: "ws://localhost:8080/echo?model=assemblyai.best",
//            baseUrlString: "wss://api.speechall.com/echo?model=deepgram.base",
//            baseUrlString: "wss://api.openai.com/v1/realtime?intent=transcription",
//            baseUrlString: "wss://api.deepgram.com/v1/listen?encoding=linear16&sample_rate=48000&channels=1&model=nova&smart_format=true&filler_words=true",
            parameters: .init()
        )
        print(#function, transcript)
    }
    
    func stopRecording() async throws {
        isRecording = false
        
        try await deepgramClient.stopStreamAndCollect()
        
        print("Recording stopped")
    }
}

struct RecordingView: View {
    @State private var viewModel = RecordingViewModel()
    
    var body: some View {
        VStack {
            Text(viewModel.isRecording ? "Recording..." : "Not Recording")
                .font(.headline)
                .padding()
            
            Button(action: {
                var audioEngine = AVAudioEngine()
                let inputNode = audioEngine.inputNode
                let inputFormat = inputNode.inputFormat(forBus: 0)
                print("inputFormat.sampleRate", inputFormat.sampleRate)
                Task {
                    if viewModel.isRecording {
                        try! await viewModel.stopRecording()
                    } else {
                        try! await  viewModel.startRecording()
                    }
                }
            }) {
                Text(viewModel.isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .background(viewModel.isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
    }
}


#Preview {
    ContentView()
}

/*
 curl \
   -X POST \
   -H "Authorization: Token " \
   -H "Content-Type: application/json" \
   -d '{"url":"https://static.deepgram.com/examples/Bueller-Life-moves-pretty-fast.wav"}' \
   "https://api.deepgram.com/v1/listen?smart_format=true&language=en&model=nova-2"
 */
