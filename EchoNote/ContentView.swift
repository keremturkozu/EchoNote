//
//  ContentView.swift
//  EchoNote
//
//  Created by Kerem Türközü on 7.06.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VoiceNote.createdAt, order: .reverse) private var voiceNotes: [VoiceNote]
    @State private var isShowingRecordingView = false
    @State private var isShowingSettingsView = false

    var body: some View {
        NavigationStack {
            ZStack {
                // List of Voice Notes
                if !voiceNotes.isEmpty {
                    List {
                        ForEach(voiceNotes) { note in
                            NavigationLink(destination: DetailView(voiceNote: note)) {
                                VoiceNoteRow(voiceNote: note)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(.plain)
                } else {
                    // Placeholder for empty list
                    VStack {
                        Image(systemName: "mic.slash.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        Text("No recordings yet.")
                            .font(.title2)
                        Text("Tap the + button to start a new recording.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }

                // Floating Action Button (FAB)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isShowingRecordingView.toggle()
                        }) {
                            Image(systemName: "plus")
                                .font(.title.weight(.semibold))
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 4, x: 0, y: 4)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("EchoNote")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingSettingsView.toggle()
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $isShowingRecordingView) {
                RecordingView()
            }
            .sheet(isPresented: $isShowingSettingsView) {
                SettingsView()
            }
        }
        .preferredColorScheme(.dark)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let noteToDelete = voiceNotes[index]
                // Also delete the audio file from disk
                let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let audioURL = documentPath.appendingPathComponent(noteToDelete.filename)
                
                do {
                    try FileManager.default.removeItem(at: audioURL)
                } catch {
                    print("Failed to delete audio file during list swipe: \\(error.localizedDescription)")
                }

                modelContext.delete(noteToDelete)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: VoiceNote.self, inMemory: true)
}
