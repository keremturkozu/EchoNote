import SwiftUI

struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showPlansView = false
    
    var body: some View {
        ZStack {
            // Background with plant theme
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.98, blue: 0.95),
                    Color(red: 0.90, green: 0.95, blue: 0.90)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Plant decoration elements
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.3))
                        .opacity(0.3)
                        .offset(x: 20, y: -20)
                }
                Spacer()
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with close button
                HStack {
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
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Main content
                VStack(spacing: 32) {
                    // Title
                    VStack(spacing: 12) {
                        Text("Start a Free 3-Day Trial")
                            .font(.custom("SF Pro Display", size: 28, relativeTo: .title))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        
                        Text("Unlock unlimited voice notes with AI transcription")
                            .font(.custom("SF Pro Text", size: 16, relativeTo: .body))
                            .foregroundColor(.black.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    
                    // Timeline
                    VStack(spacing: 24) {
                        // Today
                        TimelinePoint(
                            day: "Today",
                            title: "Get Instant Access",
                            description: "Unlock unlimited voice notes with AI transcription",
                            isActive: true
                        )
                        
                        // Day 3
                        TimelinePoint(
                            day: "Day 3",
                            title: "Trial Reminder Sent",
                            description: "We'll send you a reminder before the trial ends",
                            isActive: false
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Pricing
                    VStack(spacing: 8) {
                        Text("3 days free, then $24.98 per year")
                            .font(.custom("SF Pro Display", size: 18, relativeTo: .title3))
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        Text("Cancel anytime during your trial")
                            .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                            .foregroundColor(.black.opacity(0.6))
                    }
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            UserDefaults.standard.set(true, forKey: "isSubscribed")
                            dismiss()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Redeem Your Free Trial")
                                    .font(.custom("SF Pro Display", size: 18, relativeTo: .body))
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.2, green: 0.7, blue: 0.3),
                                        Color(red: 0.1, green: 0.6, blue: 0.2)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color(red: 0.2, green: 0.7, blue: 0.3).opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        Button(action: {
                            showPlansView = true
                        }) {
                            Text("View All Plans")
                                .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.3))
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
        }
        .sheet(isPresented: $showPlansView) {
            PlansView()
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - Timeline Point
struct TimelinePoint: View {
    let day: String
    let title: String
    let description: String
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Circle indicator
            ZStack {
                Circle()
                    .fill(isActive ? Color(red: 0.2, green: 0.7, blue: 0.3) : Color(red: 0.2, green: 0.7, blue: 0.3).opacity(0.3))
                    .frame(width: 24, height: 24)
                
                if isActive {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(day)
                        .font(.custom("SF Pro Display", size: 14, relativeTo: .caption))
                        .fontWeight(.semibold)
                        .foregroundColor(isActive ? Color(red: 0.2, green: 0.7, blue: 0.3) : .black.opacity(0.6))
                    
                    Spacer()
                }
                
                Text(title)
                    .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                    .foregroundColor(.black.opacity(0.7))
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Plans View
struct PlansView: View {
    @Environment(\.dismiss) private var dismiss
    
    let plans = [
        PlanOption(name: "Weekly", price: "$4.99", period: "/week", popular: false, savings: nil),
        PlanOption(name: "Yearly", price: "$24.98", period: "/year", popular: true, savings: "Save 60%"),
        PlanOption(name: "Lifetime", price: "$99.99", period: "one-time", popular: false, savings: "Best Value")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.98, blue: 0.95)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Text("Choose Your Plan")
                                .font(.custom("SF Pro Display", size: 24, relativeTo: .title2))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Text("Select the plan that works best for you")
                                .font(.custom("SF Pro Text", size: 16, relativeTo: .body))
                                .foregroundColor(.black.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Plans
                        VStack(spacing: 16) {
                            ForEach(plans, id: \.name) { plan in
                                PlanCard(plan: plan)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.3))
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - Plan Option Model
struct PlanOption {
    let name: String
    let price: String
    let period: String
    let popular: Bool
    let savings: String?
}

// MARK: - Plan Card
struct PlanCard: View {
    @Environment(\.dismiss) private var dismiss
    let plan: PlanOption
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.name)
                        .font(.custom("SF Pro Display", size: 20, relativeTo: .title3))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    HStack(alignment: .bottom, spacing: 4) {
                        Text(plan.price)
                            .font(.custom("SF Pro Display", size: 24, relativeTo: .title2))
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.3))
                        
                        Text(plan.period)
                            .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                            .foregroundColor(.black.opacity(0.6))
                    }
                }
                
                Spacer()
                
                if plan.popular {
                    Text("MOST POPULAR")
                        .font(.custom("SF Pro Display", size: 10, relativeTo: .caption2))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.2, green: 0.7, blue: 0.3))
                        )
                }
            }
            
            if let savings = plan.savings {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.3))
                    
                    Text(savings)
                        .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                        .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.3))
                    
                    Spacer()
                }
            }
            
            Button(action: {
                UserDefaults.standard.set(true, forKey: "isSubscribed")
                dismiss()
            }) {
                Text("Choose \(plan.name)")
                    .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                    .fontWeight(.semibold)
                    .foregroundColor(plan.popular ? .white : Color(red: 0.2, green: 0.7, blue: 0.3))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Group {
                            if plan.popular {
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.2, green: 0.7, blue: 0.3),
                                        Color(red: 0.1, green: 0.6, blue: 0.2)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            } else {
                                Color.clear
                            }
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(red: 0.2, green: 0.7, blue: 0.3), lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(plan.popular ? Color(red: 0.2, green: 0.7, blue: 0.3) : Color.clear, lineWidth: 2)
                )
        )
    }
}

#Preview {
    PremiumView()
} 