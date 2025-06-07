import SwiftUI
import AVFoundation

struct RecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var audioRecorderManager = AudioRecorderManager()
    private let speechRecognitionManager = SpeechRecognitionManager()
    @State private var hasMicrophoneAccess = false
    @State private var timer: Timer?
    @State private var elapsedTime: TimeInterval = 0.0

    private var formattedElapsedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        let milliseconds = Int((elapsedTime.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()

                Text(formattedElapsedTime)
                    .font(.system(size: 60, weight: .light, design: .monospaced))
                    .padding(.horizontal)

                Button(action: toggleRecording) {
                    ZStack {
                        Circle()
                            .fill(audioRecorderManager.isRecording ? Color.red.opacity(0.8) : Color.accentColor)
                            .frame(width: 150, height: 150)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: audioRecorderManager.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                            .scaleEffect(audioRecorderManager.isRecording ? 1.2 : 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: audioRecorderManager.isRecording)
                    }
                }
                .disabled(!hasMicrophoneAccess)
                
                if audioRecorderManager.isRecording {
                    Button(action: stopAndSave) {
                        Text("Stop & Save")
                            .font(.headline)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 40)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                            .transition(.scale.combined(with: .opacity))
                    }
                } else {
                    Text(hasMicrophoneAccess ? "Tap to record" : "Microphone access required")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 40)
                }

                Spacer()
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if audioRecorderManager.isRecording {
                            audioRecorderManager.stopRecording(delete: true)
                        }
                        dismiss()
                    }
                }
            }
            .onAppear(perform: requestMicrophoneAccess)
            .onDisappear(perform: stopTimer)
        }
    }

    private func requestMicrophoneAccess() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.hasMicrophoneAccess = granted
            }
        }
    }

    private func toggleRecording() {
        withAnimation(.easeInOut) {
            if audioRecorderManager.isRecording {
                stopAndSave()
            } else {
                startRecording()
            }
        }
    }

    private func startRecording() {
        elapsedTime = 0
        audioRecorderManager.startRecording()
        startTimer()
    }

    private func stopAndSave() {
        stopTimer()
        let recording = audioRecorderManager.stopRecording()
        
        if let recording = recording {
            let newVoiceNote = VoiceNote(
                filename: recording.fileURL.lastPathComponent,
                createdAt: recording.createdAt,
                duration: recording.duration
            )
            modelContext.insert(newVoiceNote)
            
            // Start transcription after saving
            speechRecognitionManager.transcribe(audioURL: recording.fileURL) { transcribedText in
                if let text = transcribedText {
                    // The newVoiceNote is already a managed object in the context.
                    // We can update it directly and SwiftData will save the changes.
                    newVoiceNote.transcribedText = text
                }
            }
        }
        dismiss()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            self.elapsedTime += 0.01
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    RecordingView()
        .modelContainer(for: VoiceNote.self, inMemory: true)
} 