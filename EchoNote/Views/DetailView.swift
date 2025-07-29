import SwiftUI
import SwiftData

struct DetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // The note is now fetched inside the view using its ID
    let voiceNoteID: PersistentIdentifier
    @State private var voiceNote: VoiceNote?
    
    @StateObject private var audioPlayerManager = AudioPlayerManager()
    @State private var showDeleteConfirmation = false
    @State private var isEditingTitle = false
    @State private var editedTitle = ""

    var body: some View {
        // Show a loading indicator until the note is fetched
        if let currentNote = voiceNote {
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
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Enhanced header section
                        VStack(spacing: 24) {
                            // Modern title section with edit capability
                            VStack(spacing: 16) {
                                if isEditingTitle {
                                    TextField("Recording Title", text: $editedTitle)
                                        .font(.custom("SF Pro Display", size: 32, relativeTo: .largeTitle))
                                        .fontWeight(.bold)
                                        .foregroundColor(AppColors.textPrimary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(AppColors.cardBackground)
                                                .shadow(color: AppColors.primary.opacity(0.08), radius: 8, x: 0, y: 4)
                                        )
                                        .onSubmit {
                                            saveTitle()
                                        }
                                        .onAppear {
                                            editedTitle = currentNote.title
                                        }
                                } else {
                                    HStack {
                                        Text(currentNote.title)
                                            .font(.custom("SF Pro Display", size: 32, relativeTo: .largeTitle))
                                            .fontWeight(.bold)
                                            .foregroundColor(AppColors.textPrimary)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(3)
                                        
                                        Button(action: {
                                            isEditingTitle = true
                                        }) {
                                            Image(systemName: "pencil.circle.fill")
                                                .font(.system(size: 24, weight: .medium))
                                                .foregroundColor(AppColors.primary)
                                        }
                                    }
                                }
                                
                                // Enhanced metadata with modern design
                                HStack(spacing: 24) {
                                    MetadataItem(
                                        icon: "calendar",
                                        text: currentNote.createdAt.formatted(date: .abbreviated, time: .omitted),
                                        color: AppColors.textSecondary
                                    )
                                    
                                    MetadataItem(
                                        icon: "clock",
                                        text: currentNote.createdAt.formatted(date: .omitted, time: .shortened),
                                        color: AppColors.textSecondary
                                    )
                                    
                                    MetadataItem(
                                        icon: "timer",
                                        text: String(format: "%.0f sec", currentNote.duration),
                                        color: AppColors.accent
                                    )
                                }
                            }
                            .padding(.top, 20)
                        }
                        
                        // Enhanced Transcribed Text Card
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.primary.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "text.bubble.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(AppColors.primary)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Transcription")
                                        .font(.custom("SF Pro Display", size: 20, relativeTo: .title3))
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text("AI-powered speech-to-text")
                                        .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                Spacer()
                            }
                            
                            if let transcribedText = currentNote.transcribedText, !transcribedText.isEmpty {
                                Text(transcribedText)
                                    .font(.custom("SF Pro Text", size: 16, relativeTo: .body))
                                    .foregroundColor(AppColors.textPrimary)
                                    .lineSpacing(6)
                                    .textSelection(.enabled)
                                    .padding(.vertical, 8)
                            } else {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(AppColors.accent.opacity(0.15))
                                            .frame(width: 32, height: 32)
                                        
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accent))
                                            .scaleEffect(0.8)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Processing transcription...")
                                            .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                                            .fontWeight(.medium)
                                            .foregroundColor(AppColors.textPrimary)
                                        
                                        Text("This may take a few moments")
                                            .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 20)
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(AppColors.cardBackground)
                                .shadow(color: AppColors.primary.opacity(0.08), radius: 12, x: 0, y: 6)
                        )
                        .padding(.horizontal, 20)
                        
                        // Enhanced Audio Player Card
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.secondary.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "waveform")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(AppColors.secondary)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Audio Playback")
                                        .font(.custom("SF Pro Display", size: 20, relativeTo: .title3))
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text("High-quality audio recording")
                                        .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                Spacer()
                            }
                            
                            // Enhanced progress bar with time labels
                            VStack(spacing: 16) {
                                // Custom progress bar
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(AppColors.textSecondary.opacity(0.2))
                                        .frame(height: 8)
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            LinearGradient(
                                                colors: [AppColors.primary, AppColors.secondary],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: max(0, UIScreen.main.bounds.width - 80) * audioPlayerManager.progress, height: 8)
                                        .animation(.easeInOut(duration: 0.1), value: audioPlayerManager.progress)
                                }
                                .onTapGesture {
                                    // Future: Add seek functionality
                                }
                                
                                // Time labels
                                HStack {
                                    Text(formatTime(audioPlayerManager.currentTime))
                                        .font(.custom("SF Mono", size: 14, relativeTo: .caption))
                                        .fontWeight(.medium)
                                        .foregroundColor(AppColors.textSecondary)
                                    
                                    Spacer()
                                    
                                    Text(formatTime(currentNote.duration))
                                        .font(.custom("SF Mono", size: 14, relativeTo: .caption))
                                        .fontWeight(.medium)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(AppColors.cardBackground)
                                .shadow(color: AppColors.primary.opacity(0.08), radius: 12, x: 0, y: 6)
                        )
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 140) // Space for bottom controls
                    }
                }
                
                // Enhanced bottom playback controls
                VStack {
                    Spacer()
                    
                    VStack(spacing: 24) {
                        // Enhanced control buttons
                        HStack(spacing: 48) {
                            // Delete button
                            Button(action: {
                                let impact = UIImpactFeedbackGenerator(style: .medium)
                                impact.impactOccurred()
                                showDeleteConfirmation = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.warning.opacity(0.15))
                                        .frame(width: 56, height: 56)
                                    
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(AppColors.warning)
                                }
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            // Enhanced main play/pause button
                            Button(action: {
                                let impact = UIImpactFeedbackGenerator(style: .heavy)
                                impact.impactOccurred()
                                audioPlayerManager.togglePlayback()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [AppColors.primary, AppColors.secondary],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 88, height: 88)
                                        .shadow(color: AppColors.primary.opacity(0.4), radius: 16, x: 0, y: 8)
                                    
                                    Image(systemName: audioPlayerManager.isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 36, weight: .medium))
                                        .foregroundColor(.white)
                                        .contentTransition(.symbolEffect(.replace))
                                }
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            // Share button
                            Button(action: {
                                // Future: Share functionality
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.accent.opacity(0.15))
                                        .frame(width: 56, height: 56)
                                    
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(AppColors.accent)
                                }
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 28)
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .ignoresSafeArea(edges: .bottom)
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                print("👁️ DetailView appeared")
                print("👁️ Starting playback on appear with note: \(currentNote.title)")
                audioPlayerManager.startPlayback(voiceNote: currentNote)
            }
            .onDisappear {
                audioPlayerManager.stopPlayback()
                try? modelContext.save()
            }
            .alert("Delete Recording", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive, action: executeDelete)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this recording? This action cannot be undone.")
            }
        } else {
            // Enhanced loading state
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(AppColors.primary.opacity(0.15))
                        .frame(width: 80, height: 80)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                        .scaleEffect(1.2)
                }
                
                VStack(spacing: 8) {
                    Text("Loading recording...")
                        .font(.custom("SF Pro Display", size: 18, relativeTo: .body))
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Preparing your voice note")
                        .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [AppColors.background, AppColors.background.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .onAppear(perform: fetchNote)
        }
    }
    
    private func saveTitle() {
        if let currentNote = voiceNote {
            currentNote.title = editedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            try? modelContext.save()
        }
        isEditingTitle = false
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func fetchNote() {
        if let fetchedNote = modelContext.model(for: voiceNoteID) as? VoiceNote {
            print("📝 Fetched VoiceNote for DetailView:")
            print("📝 Title: \(fetchedNote.title)")
            print("📝 Filename: \(fetchedNote.filename)")
            print("📝 Created: \(fetchedNote.createdAt)")
            print("📝 Duration: \(fetchedNote.duration)")
            self.voiceNote = fetchedNote
            
            // Start playback AFTER fetching the note
            print("🎯 Starting playback after fetch")
            audioPlayerManager.startPlayback(voiceNote: fetchedNote)
        } else {
            print("❌ Failed to fetch VoiceNote with ID: \(voiceNoteID)")
        }
    }
    
    private func executeDelete() {
        if let voiceNote = voiceNote {
            audioPlayerManager.stopPlayback()
            modelContext.delete(voiceNote)
            
            // Also delete the audio file from disk
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioURL = documentPath.appendingPathComponent(voiceNote.filename)
            do {
                try FileManager.default.removeItem(at: audioURL)
            } catch {
                print("Failed to delete audio file: \(error.localizedDescription)")
            }
            
            dismiss()
        }
    }
}

// MARK: - Metadata Item Component
struct MetadataItem: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
            
            Text(text)
                .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

