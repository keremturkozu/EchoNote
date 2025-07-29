import SwiftUI

struct VoiceNoteRow: View {
    let voiceNote: VoiceNote
    @State private var isPressed = false

    private var formattedDuration: String {
        let minutes = Int(voiceNote.duration) / 60
        let seconds = Int(voiceNote.duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        let now = Date()
        
        // Check if it's today
        if calendar.isDate(voiceNote.createdAt, inSameDayAs: now) {
            formatter.timeStyle = .short
            return "Today, \(formatter.string(from: voiceNote.createdAt))"
        }
        
        // Check if it's yesterday
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(voiceNote.createdAt, inSameDayAs: yesterday) {
            formatter.timeStyle = .short
            return "Yesterday, \(formatter.string(from: voiceNote.createdAt))"
        }
        
        // For older dates
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: voiceNote.createdAt)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Enhanced Waveform Icon with proper sizing
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primary.opacity(0.15), AppColors.secondary.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: "waveform")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Content with improved typography
            VStack(alignment: .leading, spacing: 8) {
                // Title with modern font
                Text(voiceNote.title)
                    .font(.custom("SF Pro Display", size: 18, relativeTo: .headline))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                // Transcription preview with better styling
                if let transcribedText = voiceNote.transcribedText, !transcribedText.isEmpty {
                    Text(transcribedText)
                        .font(.custom("SF Pro Text", size: 15, relativeTo: .body))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)
                } else {
                    HStack(spacing: 6) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accent))
                            .scaleEffect(0.7)
                        Text("Processing...")
                            .font(.custom("SF Pro Text", size: 15, relativeTo: .body))
                            .foregroundColor(AppColors.textSecondary.opacity(0.7))
                            .italic()
                    }
                }
                
                // Enhanced metadata with icons
                HStack(spacing: 16) {
                    Label {
                        Text(formattedDate)
                            .font(.custom("SF Pro Text", size: 13, relativeTo: .caption))
                            .fontWeight(.medium)
                    } icon: {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(AppColors.textSecondary)
                    
                    Label {
                        Text(formattedDuration)
                            .font(.custom("SF Pro Text", size: 13, relativeTo: .caption))
                            .fontWeight(.semibold)
                    } icon: {
                        Image(systemName: "timer")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(AppColors.accent)
                }
            }
            
            Spacer()
            
            // Custom chevron that matches the row design
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.textSecondary.opacity(0.3))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppColors.cardBackground)
                .shadow(
                    color: AppColors.primary.opacity(0.08),
                    radius: 12,
                    x: 0,
                    y: 4
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        // Removed onTapGesture to allow parent Button to handle taps
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
} 