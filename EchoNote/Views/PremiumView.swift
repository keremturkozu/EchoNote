import SwiftUI

struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                
                // Header
                VStack {
                    Image(systemName: "star.shield.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.yellow)
                    Text("Unlock EchoNote Premium")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                // Feature List
                VStack(alignment: .leading, spacing: 15) {
                    FeatureRow(icon: "mic.badge.plus", text: "Unlimited Recordings")
                    FeatureRow(icon: "icloud.and.arrow.up.fill", text: "Cloud Sync (Coming Soon)")
                    FeatureRow(icon: "waveform.path.ecg", text: "Advanced Editing (Coming Soon)")
                    FeatureRow(icon: "person.2.fill", text: "Priority Support")
                }
                .padding()

                Spacer()

                // Purchase Buttons
                VStack(spacing: 15) {
                    // TODO: Replace with real subscription data from StoreKit
                    Button(action: { /* Purchase Action */ }) {
                        Text("Unlock Premium - $9.99/year")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                    
                    Button(action: { /* Restore Purchase Action */ }) {
                        Text("Restore Purchases")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 30)

            }
            .padding(.bottom, 20)
            
            // Dismiss Button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.yellow)
                .frame(width: 30)
            Text(text)
                .font(.body)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    PremiumView()
} 