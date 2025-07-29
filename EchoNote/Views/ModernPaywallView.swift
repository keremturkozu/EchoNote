import SwiftUI

struct ModernPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var revenueCatManager = RevenueCatManager.shared
    @State private var showErrorAlert = false
    @State private var selectedPlan: SubscriptionPlan?
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    AppColors.background,
                    AppColors.background.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header with close button
                    HStack {
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.9))
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Main content
                    VStack(spacing: 32) {
                        // Illustration and Title
                        VStack(spacing: 24) {
                            // Illustration placeholder (you can replace with your own image)
                            ZStack {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                AppColors.primary.opacity(0.1),
                                                AppColors.secondary.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(height: 200)
                                
                                VStack(spacing: 16) {
                                    Image(systemName: "waveform.circle.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(AppColors.primary)
                                    
                                    Text("Voice Notes Reimagined")
                                        .font(.custom("SF Pro Display", size: 18, relativeTo: .body))
                                        .foregroundColor(AppColors.textPrimary)
                                        .fontWeight(.medium)
                                }
                            }
                            
                            // Title
                            Text("Unlock Your Smartest Voice Experience")
                                .font(.custom("SF Pro Display", size: 28, relativeTo: .title))
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        
                        // Feature Comparison Table
                        VStack(spacing: 20) {
                            // Table Header
                            HStack(spacing: 0) {
                                // FREE Column
                                VStack(spacing: 16) {
                                    Text("FREE")
                                        .font(.custom("SF Pro Display", size: 18, relativeTo: .title3))
                                        .fontWeight(.bold)
                                        .foregroundColor(AppColors.textPrimary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.white)
                                    
                                    // Features
                                    VStack(spacing: 12) {
                                        FeatureRow(feature: "Basic Recording", isAvailable: true)
                                        FeatureRow(feature: "AI Transcription", isAvailable: false)
                                        FeatureRow(feature: "Unlimited Notes", isAvailable: false)
                                        FeatureRow(feature: "Cloud Sync", isAvailable: false)
                                        FeatureRow(feature: "Advanced Editing", isAvailable: false)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 20)
                                }
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                
                                // PRO Column
                                VStack(spacing: 16) {
                                    ZStack {
                                        Text("PRO")
                                            .font(.custom("SF Pro Display", size: 18, relativeTo: .title3))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(
                                                LinearGradient(
                                                    colors: [AppColors.primary, AppColors.secondary],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                        

                                    }
                                    
                                    // Features
                                    VStack(spacing: 12) {
                                        FeatureRow(feature: "Basic Recording", isAvailable: true, isPro: true)
                                        FeatureRow(feature: "AI Transcription", isAvailable: true, isPro: true)
                                        FeatureRow(feature: "Unlimited Notes", isAvailable: true, isPro: true)
                                        FeatureRow(feature: "Cloud Sync", isAvailable: true, isPro: true)
                                        FeatureRow(feature: "Advanced Editing", isAvailable: true, isPro: true)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 20)
                                }
                                .background(
                                    LinearGradient(
                                        colors: [AppColors.primary.opacity(0.05), AppColors.secondary.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(AppColors.primary, lineWidth: 2)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Pricing and CTA
                        VStack(spacing: 20) {
                            // Pricing info
                            VStack(spacing: 8) {
                                Text("Try free for 3 days, then $24.98/yr")
                                    .font(.custom("SF Pro Display", size: 18, relativeTo: .title3))
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Text("Cancel anytime during your trial")
                                    .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            // CTA Button
                            Button(action: {
                                Task {
                                    if let annualPlan = revenueCatManager.availablePackages.first(where: { $0.title == "Annual" }) {
                                        let success = await revenueCatManager.purchase(package: annualPlan.package)
                                        if success {
                                            dismiss()
                                        } else {
                                            showErrorAlert = true
                                        }
                                    }
                                }
                            }) {
                                HStack(spacing: 12) {
                                    if revenueCatManager.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                    
                                    Text("Redeem my free trial")
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
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: AppColors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .disabled(revenueCatManager.isLoading)
                            
                            // Restore purchases
                            Button(action: {
                                Task {
                                    let success = await revenueCatManager.restorePurchases()
                                    if success {
                                        dismiss()
                                    } else {
                                        showErrorAlert = true
                                    }
                                }
                            }) {
                                Text("Restore purchases")
                                    .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                                    .foregroundColor(AppColors.primary)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .onAppear {
            revenueCatManager.fetchPackages()
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(revenueCatManager.errorMessage ?? "An error occurred. Please try again.")
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let feature: String
    let isAvailable: Bool
    let isPro: Bool
    
    init(feature: String, isAvailable: Bool, isPro: Bool = false) {
        self.feature = feature
        self.isAvailable = isAvailable
        self.isPro = isPro
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isAvailable ? "checkmark.circle.fill" : "minus.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isAvailable ? (isPro ? AppColors.primary : AppColors.success) : AppColors.textSecondary)
            
            Text(feature)
                .font(.custom("SF Pro Text", size: 14, relativeTo: .body))
                .foregroundColor(isPro ? AppColors.textPrimary : AppColors.textSecondary)
                .fontWeight(isPro ? .medium : .regular)
            
            Spacer()
        }
    }
}

#Preview {
    ModernPaywallView()
} 