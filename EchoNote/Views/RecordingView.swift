import SwiftUI
import AVFoundation
import Speech

struct RecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var audioRecorder: AVAudioRecorder?
    @State private var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()

    private let speechRecognitionManager = SpeechRecognitionManager()
    
    @State private var isRecording = false
    @State private var hasMicrophoneAccess = false
    @State private var timer: Timer?
    @State private var elapsedTime: TimeInterval = 0.0
    @State private var currentSessionID = UUID().uuidString

    private var formattedElapsedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        let milliseconds = Int((elapsedTime.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }

    // Define a unique temporary URL for each recording session
    private var temporaryRecordingURL: URL {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentPath.appendingPathComponent("temp_recording_\\(currentSessionID).m4a")
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()

                Text(formattedElapsedTime)
                    .font(.system(size: 60, weight: .light, design: .monospaced))

                Button(action: toggleRecording) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? Color.red.opacity(0.8) : Color.accentColor)
                            .frame(width: 150, height: 150)
                        
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                    }
                }
                .disabled(!hasMicrophoneAccess)
                
                if isRecording {
                    Button(action: stopAndSave) {
                        Text("Stop & Save")
                            .font(.headline)
                            .padding(.vertical, 12).padding(.horizontal, 40)
                            .background(Color.red).foregroundColor(.white).cornerRadius(25)
                    }
                } else {
                    Text(hasMicrophoneAccess ? "Tap to record" : "Microphone access required")
                        .font(.headline).foregroundColor(.secondary)
                        .padding(.vertical, 12).padding(.horizontal, 40)
                }

                Spacer()
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: cancelRecording)
                }
            }
            .onAppear {
                currentSessionID = UUID().uuidString // Generate new session ID each time view appears
                requestPermissions()
            }
            .onDisappear(perform: stopTimer)
        }
    }

    private func requestPermissions() {
        AVAudioApplication.requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.hasMicrophoneAccess = granted
            }
        }
        SFSpeechRecognizer.requestAuthorization { _ in }
    }

    private func toggleRecording() {
        withAnimation(.easeInOut) {
            if isRecording {
                stopAndSave()
            } else {
                startRecording()
            }
        }
    }

    private func startRecording() {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session: \\(error.localizedDescription)")
            return
        }
        
        // Clean up any previous temporary file, just in case.
        try? FileManager.default.removeItem(at: temporaryRecordingURL)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitRateKey: 192000,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        
        do {
            // Always record to the same temporary URL
            audioRecorder = try AVAudioRecorder(url: temporaryRecordingURL, settings: settings)
            audioRecorder?.record()
            isRecording = true
            startTimer()
        } catch {
            print("Could not start recording: \\(error.localizedDescription)")
        }
    }
    
    private func stopRecording() -> TimeInterval? {
        guard let recorder = audioRecorder else { return nil }
        
        let duration = recorder.currentTime
        recorder.stop()
        self.audioRecorder = nil
        isRecording = false
        stopTimer()
        
        do {
            try recordingSession.setActive(false)
        } catch {
            print("Failed to deactivate audio session: \\(error.localizedDescription)")
        }
        
        return duration
    }

    private func stopAndSave() {
        guard let duration = stopRecording() else {
            dismiss()
            return
        }
        
        let sourceURL = temporaryRecordingURL
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let timestamp = Int(Date().timeIntervalSince1970)
        let finalURL = documentPath.appendingPathComponent("recording_\(timestamp)_\(UUID().uuidString).m4a")

        // Create the VoiceNote object FIRST on main thread
        let newVoiceNote = VoiceNote(
            filename: finalURL.lastPathComponent,
            createdAt: Date(),
            duration: duration
        )
        
        // Insert into context IMMEDIATELY on main thread
        modelContext.insert(newVoiceNote)
        
        // Save IMMEDIATELY on main thread - this is the critical fix
        do {
            try modelContext.save()
            print("✅ Voice note saved successfully to database")
            print("✅ Filename: \\(finalURL.lastPathComponent)")
            print("✅ Created at: \\(Date())")
            print("✅ Duration: \\(duration)")
            print("✅ File will be saved to: \\(finalURL.path)")
        } catch {
            print("❌ Failed to save voice note to database: \\(error.localizedDescription)")
        }
        
        // Dismiss immediately since data is already saved
        dismiss()

        // Handle file operations in background
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.1) {
            print("🔄 Starting file copy operation...")
            print("🔄 Source: \\(sourceURL.path)")
            print("🔄 Destination: \\(finalURL.path)")
            print("🔄 Source file exists: \\(FileManager.default.fileExists(atPath: sourceURL.path))")
            
            // Check available disk space
            do {
                let resourceValues = try finalURL.resourceValues(forKeys: [.volumeAvailableCapacityKey])
                if let availableCapacity = resourceValues.volumeAvailableCapacity {
                    print("🔄 Available disk space: \(availableCapacity / 1024 / 1024) MB")
                }
            } catch {
                print("⚠️ Could not check disk space: \(error.localizedDescription)")
            }
            
            do {
                // Check if destination file already exists and remove it
                if FileManager.default.fileExists(atPath: finalURL.path) {
                    print("⚠️ Destination file already exists, removing...")
                    try FileManager.default.removeItem(at: finalURL)
                    print("✅ Existing destination file removed")
                }
                
                // Move (not copy) the temporary file to final location - more efficient
                try FileManager.default.moveItem(at: sourceURL, to: finalURL)
                print("✅ File moved successfully (moveItem)")
                
                print("✅ Audio file saved successfully: \\(finalURL.lastPathComponent)")
                print("✅ Final file exists: \\(FileManager.default.fileExists(atPath: finalURL.path))")
                
                // Start transcription in background
                self.speechRecognitionManager.transcribe(audioURL: finalURL) { transcribedText in
                    DispatchQueue.main.async {
                        if let text = transcribedText {
                            newVoiceNote.transcribedText = text
                            try? self.modelContext.save()
                            print("✅ Transcription saved: \\(text.prefix(50))...")
                        } else {
                            print("⚠️ No transcription received")
                        }
                    }
                }
            } catch {
                print("❌ Failed to save audio file: \(error.localizedDescription)")
                let nsError = error as NSError
                print("❌ Error domain: \(nsError.domain)")
                print("❌ Error code: \(nsError.code)")
                print("❌ Error userInfo: \(nsError.userInfo)")
                
                // If file copy fails, remove the VoiceNote from database
                DispatchQueue.main.async {
                    print("🗑️ Removing VoiceNote from database due to file save failure...")
                    self.modelContext.delete(newVoiceNote)
                    do {
                        try self.modelContext.save()
                        print("✅ VoiceNote removed from database")
                    } catch {
                        print("❌ Failed to remove VoiceNote from database: \\(error.localizedDescription)")
                    }
                }
            }
        }
    }

    private func cancelRecording() {
        if isRecording {
            _ = stopRecording()
            // Clean up the temporary file on cancellation
            try? FileManager.default.removeItem(at: temporaryRecordingURL)
        }
        dismiss()
    }

    private func startTimer() {
        elapsedTime = 0
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