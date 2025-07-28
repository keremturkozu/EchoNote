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
    
    // For Rename Alert
    @State private var showRenameAlert = false
    @State private var noteToRename: VoiceNote?
    @State private var newName: String = ""

    // For Delete Confirmation Alert
    @State private var showDeleteConfirmation = false
    @State private var noteToDelete: VoiceNote?

    var body: some View {
        NavigationStack {
            ZStack {
                // List of Voice Notes
                if !voiceNotes.isEmpty {
                    List {
                        ForEach(voiceNotes) { note in
                            NavigationLink(value: note.persistentModelID) {
                                VoiceNoteRow(voiceNote: note)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    noteToDelete = note
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    noteToRename = note
                                    newName = note.title
                                    showRenameAlert = true
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                            .contextMenu {
                                Button {
                                    noteToRename = note
                                    newName = note.title
                                    showRenameAlert = true
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive) {
                                    noteToDelete = note
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
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
            .navigationDestination(for: VoiceNote.ID.self) { noteID in
                DetailView(voiceNoteID: noteID)
            }
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
            .alert("Rename Recording", isPresented: $showRenameAlert) {
                TextField("New name", text: $newName)
                Button("Save", action: renameNote)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter a new name for your recording.")
            }
            .alert("Delete Recording", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive, action: executeDelete)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this recording? This action cannot be undone.")
            }
        }
        .preferredColorScheme(.dark)
    }

    private func renameNote() {
        if let note = noteToRename {
            note.title = newName
            try? modelContext.save()
        }
    }

    private func executeDelete() {
        if let note = noteToDelete {
            modelContext.delete(note)
            
            // Also delete the audio file from disk
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioURL = documentPath.appendingPathComponent(note.filename)
            
            do {
                try FileManager.default.removeItem(at: audioURL)
            } catch {
                print("Failed to delete audio file during context menu delete: \\(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: VoiceNote.self, inMemory: true)
}
