import SwiftUI

struct LaunchScreenView: View {
    @Binding var isLaunchComplete: Bool
    @Binding var shouldShowPremium: Bool
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    
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
            
            VStack(spacing: 32) {
                Spacer()
                
                // Main logo and title
                VStack(spacing: 24) {
                    // Animated logo
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.primary, AppColors.secondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: AppColors.primary.opacity(0.3), radius: 20, x: 0, y: 10)
                            .scaleEffect(logoScale)
                            .opacity(logoOpacity)
                        
                        Image(systemName: "waveform")
                            .font(.system(size: 60, weight: .medium))
                            .foregroundColor(.white)
                            .scaleEffect(logoScale)
                            .opacity(logoOpacity)
                    }
                    
                    // App title
                    VStack(spacing: 8) {
                        Text("EchoNote")
                            .font(.custom("SF Pro Display", size: 36, relativeTo: .largeTitle))
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                            .opacity(textOpacity)
                        
                        Text("Voice Notes Reimagined")
                            .font(.custom("SF Pro Text", size: 18, relativeTo: .body))
                            .foregroundColor(AppColors.textSecondary)
                            .opacity(textOpacity)
                    }
                }
                
                Spacer()
                
                // Loading indicator
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                        .scaleEffect(1.2)
                        .opacity(textOpacity)
                    
                    Text("Loading...")
                        .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                        .foregroundColor(AppColors.textSecondary)
                        .opacity(textOpacity)
                }
                
                Spacer()
            }
        }
        .onAppear {
            startAnimations()
        }
        .preferredColorScheme(.light)
    }
    
    private func startAnimations() {
        // Logo animation
        withAnimation(.easeOut(duration: 0.8)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Text animation with delay
        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
            textOpacity = 1.0
        }
        
        // Complete launch after animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isLaunchComplete = true
            }
        }
    }
}

#Preview {
    LaunchScreenView(
        isLaunchComplete: .constant(false),
        shouldShowPremium: .constant(false)
    )
} 