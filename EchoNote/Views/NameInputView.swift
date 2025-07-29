import SwiftUI

struct NameInputView: View {
    @Binding var recordingName: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
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
                
                VStack(spacing: 32) {
                    Spacer(minLength: 60)
                    
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
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50, weight: .medium))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [AppColors.primary, AppColors.secondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        VStack(spacing: 8) {
                            Text("Recording Complete!")
                                .font(.custom("SF Pro Display", size: 28, relativeTo: .title))
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Give your recording a name")
                                .font(.custom("SF Pro Text", size: 16, relativeTo: .body))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    
                    // Name input field
                    VStack(spacing: 16) {
                        TextField("Enter recording name", text: $recordingName)
                            .font(.custom("SF Pro Display", size: 18, relativeTo: .body))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(AppColors.cardBackground)
                                    .shadow(color: AppColors.primary.opacity(0.08), radius: 8, x: 0, y: 4)
                            )
                            .focused($isTextFieldFocused)
                            .onSubmit {
                                if !recordingName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    onSave()
                                }
                            }
                        
                        Text("This name will appear in your recordings list")
                            .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            if !recordingName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                onSave()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Save Recording")
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
                            .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .disabled(recordingName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(recordingName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
                        
                        Button(action: onCancel) {
                            Text("Cancel")
                                .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if !recordingName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            onSave()
                        }
                    }
                    .font(.custom("SF Pro Display", size: 16, relativeTo: .body))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primary)
                    .disabled(recordingName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    NameInputView(
        recordingName: .constant("My Recording"),
        onSave: {},
        onCancel: {}
    )
} 