import SwiftUI

struct LanguageSelectionView: View {
    @Binding var isLanguageSelectionComplete: Bool
    @State private var selectedLanguage = "English"
    @State private var showSettingsInfo = false
    
    private let languages = [
        OnBoardingLanguageOption(name: "English", code: "en-US", flag: "🇺🇸", description: "Most accurate for English speech"),
        OnBoardingLanguageOption(name: "Turkish", code: "tr-TR", flag: "🇹🇷", description: "Optimized for Turkish language"),
        OnBoardingLanguageOption(name: "Spanish", code: "es-ES", flag: "🇪🇸", description: "Best for Spanish speakers"),
        OnBoardingLanguageOption(name: "French", code: "fr-FR", flag: "🇫🇷", description: "Optimized for French language"),
        OnBoardingLanguageOption(name: "German", code: "de-DE", flag: "🇩🇪", description: "Best for German speakers"),
        OnBoardingLanguageOption(name: "Italian", code: "it-IT", flag: "🇮🇹", description: "Optimized for Italian language")
    ]
    
    var body: some View {
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
                VStack(spacing: 32) {
                    Spacer(minLength: 40)
                    
                    // Header section
                    VStack(spacing: 24) {
                        // Icon and title
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppColors.primary.opacity(0.2), AppColors.secondary.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "globe")
                                    .font(.system(size: 50, weight: .medium))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [AppColors.primary, AppColors.secondary],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            
                            VStack(spacing: 12) {
                                Text("Choose Your Language")
                                    .font(.custom("SF Pro Display", size: 28, relativeTo: .title))
                                    .foregroundColor(AppColors.textPrimary)
                                    .multilineTextAlignment(.center)
                                
                                Text("Select your preferred language for the best transcription experience")
                                    .font(.custom("SF Pro Text", size: 16, relativeTo: .body))
                                    .foregroundColor(AppColors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                        }
                        
                        // Why language matters card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.accent.opacity(0.15))
                                        .frame(width: 32, height: 32)
                                    
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppColors.accent)
                                }
                                
                                Text("Why Language Matters")
                                    .font(.custom("SF Pro Display", size: 18, relativeTo: .body))
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                BenefitRow(
                                    icon: "checkmark.circle.fill",
                                    text: "Higher transcription accuracy",
                                    color: AppColors.success
                                )
                                
                                BenefitRow(
                                    icon: "checkmark.circle.fill",
                                    text: "Better understanding of context",
                                    color: AppColors.success
                                )
                                
                                BenefitRow(
                                    icon: "checkmark.circle.fill",
                                    text: "Improved punctuation and formatting",
                                    color: AppColors.success
                                )
                                
                                BenefitRow(
                                    icon: "checkmark.circle.fill",
                                    text: "Faster processing speed",
                                    color: AppColors.success
                                )
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(AppColors.cardBackground)
                                .shadow(color: AppColors.primary.opacity(0.08), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // Language selection
                    VStack(spacing: 16) {
                        Text("Available Languages")
                            .font(.custom("SF Pro Display", size: 20, relativeTo: .title3))
                            .foregroundColor(AppColors.textPrimary)
                        
                        VStack(spacing: 12) {
                            ForEach(languages, id: \.code) { language in
                                LanguageRow(
                                    language: language,
                                    isSelected: selectedLanguage == language.name,
                                    onSelect: {
                                        selectedLanguage = language.name
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Settings info
                    VStack(spacing: 16) {
                        Button(action: {
                            showSettingsInfo.toggle()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(AppColors.primary)
                                
                                Text("You can change this later in Settings")
                                    .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                                    .foregroundColor(AppColors.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(AppColors.primary.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            
            // Bottom button
            VStack {
                Spacer()
                
                Button(action: {
                    // Save language preference to both keys for compatibility
                    UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
                    UserDefaults.standard.set(selectedLanguage, forKey: "transcriptionLanguage")
                    UserDefaults.standard.set(true, forKey: "isLanguageSelectionComplete")
                    isLanguageSelectionComplete = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("Continue with \(selectedLanguage)")
                            .font(.custom("SF Pro Display", size: 18, relativeTo: .body))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showSettingsInfo) {
            SettingsInfoView()
        }
        .onAppear {
            // Initialize selectedLanguage from UserDefaults if available
            if let savedLanguage = UserDefaults.standard.string(forKey: "transcriptionLanguage") {
                selectedLanguage = savedLanguage
            }
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - Language Row Component
struct LanguageRow: View {
    let language: OnBoardingLanguageOption
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Flag and language info
                HStack(spacing: 12) {
                    Text(language.flag)
                        .font(.system(size: 24))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(language.name)
                            .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(language.description)
                            .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                            .foregroundColor(AppColors.textSecondary)
                    }
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
                    .fill(isSelected ? AppColors.primary.opacity(0.1) : AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 2)
                    )
            )
            .shadow(color: AppColors.primary.opacity(isSelected ? 0.1 : 0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Benefit Row Component
struct BenefitRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
            
            Text(text)
                .font(.custom("SF Pro Text", size: 14, relativeTo: .body))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
        }
    }
}

// MARK: - Settings Info View
struct SettingsInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [AppColors.background, AppColors.background.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer(minLength: 40)
                    
                    // Icon
                    ZStack {
                        Circle()
                            .fill(AppColors.primary.opacity(0.15))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundColor(AppColors.primary)
                    }
                    
                    // Content
                    VStack(spacing: 16) {
                        Text("Change Language Later")
                            .font(.custom("SF Pro Display", size: 24, relativeTo: .title2))
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        VStack(spacing: 12) {
                            Text("You can change your language preference at any time:")
                                .font(.custom("SF Pro Text", size: 16, relativeTo: .body))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                InstructionRow(number: "1", text: "Go to Settings in the app")
                                InstructionRow(number: "2", text: "Tap on 'Language Settings'")
                                InstructionRow(number: "3", text: "Select your preferred language")
                                InstructionRow(number: "4", text: "Changes apply to new recordings")
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
            }
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
}

// MARK: - Instruction Row Component
struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.15))
                    .frame(width: 24, height: 24)
                
                Text(number)
                    .font(.custom("SF Pro Display", size: 12, relativeTo: .caption))
                    .foregroundColor(AppColors.primary)
            }
            
            Text(text)
                .font(.custom("SF Pro Text", size: 14, relativeTo: .body))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
        }
    }
}

// MARK: - Language Option Model
struct OnBoardingLanguageOption {
    let name: String
    let code: String
    let flag: String
    let description: String
}

#Preview {
    LanguageSelectionView(isLanguageSelectionComplete: .constant(false))
} 