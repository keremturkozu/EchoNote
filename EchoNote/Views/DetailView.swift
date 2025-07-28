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

    var body: some View {
        // Show a loading indicator until the note is fetched
        if let currentNote = voiceNote {
            VStack {
                // Editable Title
                TextField("Title", text: .init(get: {
                    currentNote.title
                }, set: { newTitle in
                    self.voiceNote?.title = newTitle
                }))
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .multilineTextAlignment(.center)
                
                // Transcribed Text View
                ScrollView {
                    if let transcribedText = currentNote.transcribedText {
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
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
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
            ProgressView()
                .onAppear(perform: fetchNote)
        }
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
                print("Failed to delete audio file: \\(error.localizedDescription)")
            }
            
            dismiss()
        }
    }
} 