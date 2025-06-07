import SwiftUI

struct DetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Using @Bindable to allow editing the title directly
    @Bindable var voiceNote: VoiceNote
    @StateObject private var audioPlayerManager = AudioPlayerManager()

    var body: some View {
        VStack {
            // Editable Title
            TextField("Title", text: $voiceNote.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .multilineTextAlignment(.center)
            
            // Transcribed Text View
            ScrollView {
                if let transcribedText = voiceNote.transcribedText {
                    Text(transcribedText)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    VStack(spacing: 10) {
                        ProgressView()
                            .progressViewStyle(.circular)
                        Text("Transcribing...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            
            Spacer()
            
            // Playback Controls Footer
            VStack(spacing: 15) {
                ProgressView(value: audioPlayerManager.progress)
                    .progressViewStyle(.linear)
                    .tint(.white)
                    .padding(.horizontal)
                
                HStack(spacing: 30) {
                    Button(action: deleteNote) {
                        Image(systemName: "trash.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        audioPlayerManager.togglePlayback()
                    }) {
                        Image(systemName: audioPlayerManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                    
                    // A spacer to balance the delete button
                    Image(systemName: "trash.fill").font(.title).hidden()
                }
            }
            .padding(.vertical)
            .background(Color.black.opacity(0.3))
        }
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onAppear {
            audioPlayerManager.startPlayback(voiceNote: voiceNote)
        }
        .onDisappear {
            audioPlayerManager.stopPlayback()
            // Explicitly save the context to persist any title changes
            try? modelContext.save()
        }
    }
    
    private func deleteNote() {
        audioPlayerManager.stopPlayback()
        modelContext.delete(voiceNote)
        
        // Also delete the audio file from disk
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentPath.appendingPathComponent(voiceNote.filename)
        do {
            try FileManager.default.removeItem(at: audioURL)
        } catch {
            print("Failed to delete audio file: \\(error.localizedDescription)")
        }
        
        dismiss()
    }
} 