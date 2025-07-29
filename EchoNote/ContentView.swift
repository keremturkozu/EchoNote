//
//  ContentView.swift
//  EchoNote
//
//  Created by Kerem Türközü on 7.06.2025.
//

import SwiftUI
import SwiftData

// MARK: - Custom Color Theme
struct AppColors {
    static let primary = Color(red: 0.2, green: 0.6, blue: 0.9) // Modern blue
    static let secondary = Color(red: 0.95, green: 0.4, blue: 0.6) // Soft pink
    static let accent = Color(red: 0.3, green: 0.8, blue: 0.6) // Mint green
    static let background = Color(red: 0.98, green: 0.97, blue: 0.95) // Warm light gray
    static let cardBackground = Color.white
    static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.15) // Dark blue-gray
    static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.5) // Medium gray
    static let success = Color(red: 0.2, green: 0.7, blue: 0.4) // Green
    static let warning = Color(red: 0.95, green: 0.6, blue: 0.2) // Orange
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VoiceNote.createdAt, order: .reverse) private var voiceNotes: [VoiceNote]
    @State private var isShowingRecordingView = false
    @State private var isShowingSettingsView = false
    @State private var isOnboardingComplete = false
    @State private var isLanguageSelectionComplete = false
    
    // For Rename Alert
    @State private var showRenameAlert = false
    @State private var noteToRename: VoiceNote?
    @State private var newName: String = ""

    // For Delete Confirmation Alert
    @State private var showDeleteConfirmation = false
    @State private var noteToDelete: VoiceNote?
    
    // For Navigation
    @State private var selectedNoteID: PersistentIdentifier?

    var body: some View {
        Group {
            if !isOnboardingComplete {
                OnBoardingView(isOnboardingComplete: $isOnboardingComplete)
            } else if !isLanguageSelectionComplete {
                LanguageSelectionView(isLanguageSelectionComplete: $isLanguageSelectionComplete)
            } else {
                NavigationStack {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [
                        AppColors.background,
                        AppColors.background.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // List of Voice Notes
                if !voiceNotes.isEmpty {
                    List {
                        ForEach(voiceNotes) { note in
                            Button(action: {
                                print("Button tapped for note: \(note.title)")
                                // Enhanced haptic feedback
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                                // Manual navigation
                                DispatchQueue.main.async {
                                    // Try to trigger navigation
                                    selectedNoteID = note.persistentModelID
                                }
                            }) {
                                VoiceNoteRow(voiceNote: note)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    noteToDelete = note
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                                
                                Button {
                                    noteToRename = note
                                    newName = note.title
                                    showRenameAlert = true
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                .tint(AppColors.primary)
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
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                } else {
                    // Enhanced empty state with gamification style
                    VStack(spacing: 32) {
                        // Animated icon with gradient
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColors.primary.opacity(0.2), AppColors.secondary.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 140, height: 140)
                            
                            Image(systemName: "mic.badge.plus")
                                .font(.system(size: 60, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [AppColors.primary, AppColors.secondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        VStack(spacing: 16) {
                            Text("Start Your Voice Journey")
                                .font(.custom("SF Pro Display", size: 32, relativeTo: .title))
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text("Transform your thoughts into powerful voice recordings with crystal-clear quality and instant transcription.")
                                .font(.custom("SF Pro Text", size: 18, relativeTo: .body))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, 20)
                        }
                        
                        // Gamified CTA Button
                        Button(action: {
                            isShowingRecordingView.toggle()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                Text("Create Your First Recording")
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
                            .shadow(color: AppColors.primary.opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    .padding(.horizontal, 32)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // Enhanced Floating Action Button (FAB)
                if !voiceNotes.isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                let impact = UIImpactFeedbackGenerator(style: .medium)
                                impact.impactOccurred()
                                isShowingRecordingView.toggle()
                            }) {
                                ZStack {
                                    // Animated background
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [AppColors.primary, AppColors.secondary],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 68, height: 68)
                                        .shadow(color: AppColors.primary.opacity(0.4), radius: 16, x: 0, y: 8)
                                    
                                    Image(systemName: "plus")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .padding(.trailing, 24)
                            .padding(.bottom, 20) // Moved down a bit more
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    // Enhanced EchoNote title with gradient and modern design
                    HStack(spacing: 8) {
                        // Icon with gradient background
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColors.primary, AppColors.secondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "waveform.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        // Title with gradient text
                        Text("EchoNote")
                            .font(.custom("SF Pro Display", size: 24, relativeTo: .title))
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColors.textPrimary, AppColors.primary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingSettingsView.toggle()
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .background(
                NavigationLink(
                    destination: selectedNoteID != nil ? DetailView(voiceNoteID: selectedNoteID!) : nil,
                    isActive: Binding(
                        get: { selectedNoteID != nil },
                        set: { if !$0 { selectedNoteID = nil } }
                    )
                ) {
                    EmptyView()
                }
            )
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
                .preferredColorScheme(.light) // Force light mode
            }
        }
        .onAppear {
            // Check if onboarding is complete
            isOnboardingComplete = UserDefaults.standard.bool(forKey: "isOnboardingComplete")
            isLanguageSelectionComplete = UserDefaults.standard.bool(forKey: "isLanguageSelectionComplete")
        }
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
