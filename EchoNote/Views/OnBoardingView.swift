import SwiftUI

struct OnBoardingView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0
    
    private let onboardingPages = [
        OnBoardingPage(
            title: "Transform Your Thoughts",
            subtitle: "Capture ideas instantly with crystal-clear voice recordings",
            description: "Turn your spoken words into powerful, searchable notes that you can access anywhere, anytime.",
            icon: "brain.head.profile",
            gradientColors: [AppColors.primary, AppColors.secondary]
        ),
        OnBoardingPage(
            title: "AI-Powered Transcription",
            subtitle: "Accurate speech-to-text in real-time",
            description: "Our advanced AI technology converts your voice to text with remarkable accuracy, making your notes instantly searchable and shareable.",
            icon: "text.bubble.fill",
            gradientColors: [AppColors.accent, AppColors.primary]
        ),
        OnBoardingPage(
            title: "Organize & Discover",
            subtitle: "Smart organization for your voice notes",
            description: "Keep your recordings organized with automatic categorization, smart search, and seamless integration across all your devices.",
            icon: "folder.fill",
            gradientColors: [AppColors.secondary, AppColors.accent]
        ),
        OnBoardingPage(
            title: "Ready to Start?",
            subtitle: "Begin your voice journey today",
            description: "Join thousands of users who have transformed how they capture and organize their thoughts with EchoNote.",
            icon: "sparkles",
            gradientColors: [AppColors.primary, AppColors.secondary, AppColors.accent]
        )
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
            
            VStack(spacing: 0) {
                // Content area
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        OnBoardingPageView(page: onboardingPages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                // Bottom controls
                VStack(spacing: 24) {
                    // Dot indicators
                    HStack(spacing: 12) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            Circle()
                                .fill(
                                    currentPage == index 
                                        ? AppColors.primary 
                                        : AppColors.textSecondary.opacity(0.3)
                                )
                                .frame(width: currentPage == index ? 12 : 8, height: currentPage == index ? 12 : 8)
                                .animation(.easeInOut(duration: 0.2), value: currentPage)
                        }
                    }
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        if currentPage < onboardingPages.count - 1 {
                            // Next button
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage += 1
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Text("Continue")
                                        .font(.custom("SF Pro Display", size: 18, relativeTo: .body))
                                        .fontWeight(.semibold)
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .semibold))
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
                            
                            // Skip button
                            Button(action: {
                                UserDefaults.standard.set(true, forKey: "isOnboardingComplete")
                                isOnboardingComplete = true
                            }) {
                                Text("Skip")
                                    .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        } else {
                            // Get Started button
                            Button(action: {
                                UserDefaults.standard.set(true, forKey: "isOnboardingComplete")
                                isOnboardingComplete = true
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    Text("Get Started")
                                        .font(.custom("SF Pro Display", size: 18, relativeTo: .body))
                                        .fontWeight(.semibold)
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
                        }
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - OnBoarding Page View
struct OnBoardingPageView: View {
    let page: OnBoardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer(minLength: 60)
            
            // Icon section
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: page.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: page.gradientColors.first?.opacity(0.3) ?? AppColors.primary.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: page.icon)
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(.white)
                }
            }
            
            // Text content
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text(page.title)
                        .font(.custom("SF Pro Display", size: 32, relativeTo: .largeTitle))
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(page.subtitle)
                        .font(.custom("SF Pro Display", size: 20, relativeTo: .title3))
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                
                Text(page.description)
                    .font(.custom("SF Pro Text", size: 16, relativeTo: .body))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - OnBoarding Page Model
struct OnBoardingPage {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let gradientColors: [Color]
}

#Preview {
    OnBoardingView(isOnboardingComplete: .constant(false))
} 