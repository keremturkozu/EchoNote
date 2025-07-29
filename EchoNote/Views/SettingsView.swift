import SwiftUI

struct SettingsLanguageOption: Hashable, Identifiable {
    var id: String { identifier }
    let name: String
    let identifier: String
    let flag: String
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Key for UserDefaults
    private let transcriptionLanguageKey = "transcriptionLanguage"
    
    // State for the picker
    @State private var selectedLanguage: String
    
    // Supported Languages
    private let supportedLanguages = [
        SettingsLanguageOption(name: "Türkçe", identifier: "tr-TR", flag: "🇹🇷"),
        SettingsLanguageOption(name: "English (US)", identifier: "en-US", flag: "🇺🇸"),
        SettingsLanguageOption(name: "Deutsch", identifier: "de-DE", flag: "🇩🇪"),
        SettingsLanguageOption(name: "Español", identifier: "es-ES", flag: "🇪🇸"),
        SettingsLanguageOption(name: "Français", identifier: "fr-FR", flag: "🇫🇷"),
        SettingsLanguageOption(name: "Italiano", identifier: "it-IT", flag: "🇮🇹")
    ]
    
    init() {
        // Set the initial state from UserDefaults or default to Turkish
        _selectedLanguage = State(initialValue: UserDefaults.standard.string(forKey: transcriptionLanguageKey) ?? "tr-TR")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
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
                    VStack(spacing: 24) {
                        Spacer(minLength: 20)
                        
                        // Language Settings Section
                        VStack(spacing: 20) {
                            // Section Header
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.primary.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "globe")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(AppColors.primary)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Language Settings")
                                        .font(.custom("SF Pro Display", size: 20, relativeTo: .title3))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text("Choose your preferred language for transcription")
                                        .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            // Language Selection
                            VStack(spacing: 12) {
                                ForEach(supportedLanguages, id: \.identifier) { language in
                                    SettingsLanguageRow(
                                        language: language,
                                        isSelected: selectedLanguage == language.identifier,
                                        onSelect: {
                                            selectedLanguage = language.identifier
                                            UserDefaults.standard.set(selectedLanguage, forKey: transcriptionLanguageKey)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(AppColors.cardBackground)
                                .shadow(color: AppColors.primary.opacity(0.08), radius: 12, x: 0, y: 6)
                        )
                        .padding(.horizontal, 20)
                        
                        // Premium Section
                        VStack(spacing: 20) {
                            // Section Header
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.accent.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(AppColors.accent)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Premium Features")
                                        .font(.custom("SF Pro Display", size: 20, relativeTo: .title3))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text("Unlock advanced features and unlimited recordings")
                                        .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            // Premium Card
                            Button(action: {
                                // TODO: Navigate to Premium View
                            }) {
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Upgrade to Premium")
                                            .font(.custom("SF Pro Display", size: 18, relativeTo: .body))
                                            .foregroundColor(AppColors.textPrimary)
                                        
                                        Text("Unlimited recordings • Advanced AI • Export options")
                                            .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(AppColors.primary.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(AppColors.cardBackground)
                                .shadow(color: AppColors.primary.opacity(0.08), radius: 12, x: 0, y: 6)
                        )
                        .padding(.horizontal, 20)
                        
                        // About Section
                        VStack(spacing: 20) {
                            // Section Header
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.secondary.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(AppColors.secondary)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("About EchoNote")
                                        .font(.custom("SF Pro Display", size: 20, relativeTo: .title3))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text("App information and legal details")
                                        .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            // About Items
                            VStack(spacing: 12) {
                                SettingsRow(
                                    icon: "doc.text",
                                    title: "About EchoNote",
                                    subtitle: "Learn more about the app",
                                    action: {
                                        // TODO: Navigate to About
                                    }
                                )
                                
                                SettingsRow(
                                    icon: "hand.raised",
                                    title: "Privacy Policy",
                                    subtitle: "How we protect your data",
                                    action: {
                                        // TODO: Navigate to Privacy Policy
                                    }
                                )
                                
                                SettingsRow(
                                    icon: "doc.plaintext",
                                    title: "Terms of Service",
                                    subtitle: "Usage terms and conditions",
                                    action: {
                                        // TODO: Navigate to Terms
                                    }
                                )
                                
                                // App Version
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(AppColors.textSecondary.opacity(0.15))
                                            .frame(width: 32, height: 32)
                                        
                                        Image(systemName: "app.badge")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("App Version")
                                            .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                                            .foregroundColor(AppColors.textPrimary)
                                        
                                        Text(appVersion())
                                            .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                            }
                        }
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(AppColors.cardBackground)
                                .shadow(color: AppColors.primary.opacity(0.08), radius: 12, x: 0, y: 6)
                        )
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
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
                    .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                    .foregroundColor(AppColors.primary)
                }
            }
        }
        .preferredColorScheme(.light)
    }
    
    private func appVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }
}

// MARK: - Settings Language Row
struct SettingsLanguageRow: View {
    let language: SettingsLanguageOption
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Flag and language info
                HStack(spacing: 12) {
                    Text(language.flag)
                        .font(.system(size: 24))
                    
                    Text(language.name)
                        .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
                
                // Selection indicator
                ZStack {
                    Circle()
                        .fill(isSelected ? AppColors.primary : AppColors.textSecondary.opacity(0.2))
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? AppColors.primary.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppColors.textSecondary.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(subtitle)
                        .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
} 