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
    @State private var pulseAnimation = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var showNameInput = false
    @State private var recordingName = ""
    @State private var recordingDuration: TimeInterval = 0.0

    private var formattedElapsedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        let milliseconds = Int((elapsedTime.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
    
    private var formattedElapsedTimeDisplay: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // Define a unique temporary URL for each recording session
    private var temporaryRecordingURL: URL {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentPath.appendingPathComponent("temp_recording_\(currentSessionID).m4a")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Enhanced gradient background
                LinearGradient(
                    colors: [
                        AppColors.background,
                        AppColors.background.opacity(0.8),
                        AppColors.primary.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer(minLength: 40)
                    
                    // Simplified and modern status indicator
                    VStack(spacing: 24) {
                        // Clean timer display
                        Text(isRecording ? formattedElapsedTime : formattedElapsedTimeDisplay)
                            .font(.custom("SF Mono", size: 72, relativeTo: .largeTitle))
                            .fontWeight(.ultraLight)
                            .foregroundColor(AppColors.textPrimary)
                            .contentTransition(.numericText())
                            .shadow(color: AppColors.primary.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    
                    Spacer(minLength: 80)
                    
                    // Enhanced main recording button with professional design
                    VStack(spacing: 40) {
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .heavy)
                            impact.impactOccurred()
                            
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                buttonScale = 0.9
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    buttonScale = 1.0
                                }
                                toggleRecording()
                            }
                        }) {
                            ZStack {
                                // Modern pulse rings for recording state
                                if isRecording {
                                    ForEach(0..<2, id: \.self) { index in
                                        Circle()
                                            .stroke(AppColors.primary.opacity(0.2 - Double(index) * 0.1), lineWidth: 2)
                                            .frame(width: 220 + CGFloat(index * 15), height: 220 + CGFloat(index * 15))
                                            .scaleEffect(pulseAnimation ? 1.15 : 1.0)
                                            .opacity(pulseAnimation ? 0.0 : 0.4)
                                            .animation(
                                                .easeInOut(duration: 1.8)
                                                .repeatForever(autoreverses: false)
                                                .delay(Double(index) * 0.2),
                                                value: pulseAnimation
                                            )
                                    }
                                }
                                
                                // Main button circle with modern gradient
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: isRecording 
                                                ? [AppColors.primary, AppColors.secondary]
                                                : [AppColors.primary, AppColors.secondary],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 200, height: 200)
                                    .shadow(
                                        color: AppColors.primary.opacity(0.3),
                                        radius: 25,
                                        x: 0,
                                        y: 12
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.white.opacity(0.3), .clear],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                
                                // Enhanced icon with better sizing
                                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                    .font(.system(size: 80, weight: .medium))
                                    .foregroundColor(.white)
                                    .contentTransition(.symbolEffect(.replace))
                                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                            }
                        }
                        .disabled(!hasMicrophoneAccess)
                        .scaleEffect(buttonScale)
                        
                        // Enhanced action button or status text
                        Group {
                            if isRecording {
                                Button(action: {
                                    let impact = UIImpactFeedbackGenerator(style: .medium)
                                    impact.impactOccurred()
                                    stopAndSave()
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                        Text("Stop & Save Recording")
                                            .font(.custom("SF Pro Display", size: 18, relativeTo: .body))
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 18)
                                    .background(
                                        LinearGradient(
                                            colors: [AppColors.primary, AppColors.secondary],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(Capsule())
                                    .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            } else {
                                VStack(spacing: 12) {
                                    Text(hasMicrophoneAccess ? "Tap to Start" : "Microphone Access Required")
                                        .font(.custom("SF Pro Display", size: 18, relativeTo: .title3))
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.textPrimary)
                                        .multilineTextAlignment(.center)
                                    
                                    if !hasMicrophoneAccess {
                                        Text("Please enable microphone access in Settings to record voice notes")
                                            .font(.custom("SF Pro Text", size: 16, relativeTo: .body))
                                            .foregroundColor(AppColors.textSecondary)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                    
                    // Enhanced tips section with better design
                    if !isRecording && hasMicrophoneAccess {
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.primary.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(AppColors.primary)
                                }
                                
                                                                                                 VStack(alignment: .leading, spacing: 4) {
                                    Text("Pro Tips")
                                        .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text("Speak clearly for better results")
                                        .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(AppColors.cardBackground)
                                    .shadow(color: AppColors.primary.opacity(0.08), radius: 8, x: 0, y: 4)
                            )
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer(minLength: 60)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        cancelRecording()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Cancel")
                                .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                                .fontWeight(.medium)
                        }
                        .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("New Recording")
                        .font(.custom("SF Pro Display", size: 17, relativeTo: .headline))
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            .onAppear {
                currentSessionID = UUID().uuidString
                requestPermissions()
                pulseAnimation = true
            }
            .onDisappear(perform: stopTimer)
            .sheet(isPresented: $showNameInput) {
                NameInputView(
                    recordingName: $recordingName,
                    onSave: saveRecordingWithName,
                    onCancel: {
                        showNameInput = false
                        dismiss()
                    }
                )
            }
        }
        .preferredColorScheme(.light)
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
            print("Failed to set up recording session: \(error.localizedDescription)")
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
            print("Could not start recording: \(error.localizedDescription)")
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
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
        
        return duration
    }

    private func stopAndSave() {
        guard let duration = stopRecording() else {
            dismiss()
            return
        }
        
        // Show name input instead of dismissing immediately
        showNameInput = true
        recordingName = "Recording \(Date().formatted(date: .numeric, time: .shortened))"
        
        // Store duration for later use
        self.recordingDuration = duration
    }
    
    private func saveRecordingWithName() {
        let sourceURL = temporaryRecordingURL
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let timestamp = Int(Date().timeIntervalSince1970)
        let finalURL = documentPath.appendingPathComponent("recording_\(timestamp)_\(UUID().uuidString).m4a")

        // Create the VoiceNote object with custom name
        let newVoiceNote = VoiceNote(
            filename: finalURL.lastPathComponent,
            title: recordingName.isEmpty ? "Recording \(Date().formatted(date: .numeric, time: .shortened))" : recordingName,
            createdAt: Date(),
            duration: recordingDuration
        )
        
        // Insert into context
        modelContext.insert(newVoiceNote)
        
        // Save to database
        do {
            try modelContext.save()
            print("✅ Voice note saved successfully to database")
            print("✅ Title: \(newVoiceNote.title)")
            print("✅ Filename: \(finalURL.lastPathComponent)")
        } catch {
            print("❌ Failed to save voice note to database: \(error.localizedDescription)")
        }
        
        // Dismiss the view
        dismiss()

        // Handle file operations in background
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.1) {
            print("🔄 Starting file copy operation...")
            print("🔄 Source: \(sourceURL.path)")
            print("🔄 Destination: \(finalURL.path)")
            print("🔄 Source file exists: \(FileManager.default.fileExists(atPath: sourceURL.path))")
            
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
                
                print("✅ Audio file saved successfully: \(finalURL.lastPathComponent)")
                print("✅ Final file exists: \(FileManager.default.fileExists(atPath: finalURL.path))")
                
                // Start transcription in background
                self.speechRecognitionManager.transcribe(audioURL: finalURL) { transcribedText in
                    DispatchQueue.main.async {
                        if let text = transcribedText {
                            newVoiceNote.transcribedText = text
                            try? self.modelContext.save()
                            print("✅ Transcription saved: \(text.prefix(50))...")
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
                        print("❌ Failed to remove VoiceNote from database: \(error.localizedDescription)")
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