import SwiftUI

struct LanguageOption: Hashable, Identifiable {
    var id: String { identifier }
    let name: String
    let identifier: String
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Key for UserDefaults
    private let transcriptionLanguageKey = "transcriptionLanguage"
    
    // State for the picker
    @State private var selectedLanguage: String
    
    // Supported Languages
    private let supportedLanguages = [
        LanguageOption(name: "Türkçe", identifier: "tr-TR"),
        LanguageOption(name: "English (US)", identifier: "en-US"),
        LanguageOption(name: "Deutsch", identifier: "de-DE"),
        LanguageOption(name: "Español", identifier: "es-ES")
    ]
    
    init() {
        // Set the initial state from UserDefaults or default to Turkish
        _selectedLanguage = State(initialValue: UserDefaults.standard.string(forKey: transcriptionLanguageKey) ?? "tr-TR")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Transcription")) {
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(supportedLanguages) { language in
                            Text(language.name).tag(language.identifier)
                        }
                    }
                    .onChange(of: selectedLanguage) {
                        // Save the new language selection
                        UserDefaults.standard.set(selectedLanguage, forKey: transcriptionLanguageKey)
                    }
                }
                
                Section(header: Text("Premium Membership")) {
                    // TODO: Link to Premium View
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Upgrade to Premium")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("About")) {
                    NavigationLink("About EchoNote", destination: Text("App Info Here"))
                    NavigationLink("Privacy Policy", destination: Text("Privacy Policy Here"))
                    NavigationLink("Terms of Service", destination: Text("Terms of Service Here"))
                }
                
                Section {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text(appVersion())
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func appVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }
}

#Preview {
    SettingsView()
} 