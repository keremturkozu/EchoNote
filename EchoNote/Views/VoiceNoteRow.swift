import SwiftUI

struct VoiceNoteRow: View {
    let voiceNote: VoiceNote

    private var formattedDuration: String {
        let minutes = Int(voiceNote.duration) / 60
        let seconds = Int(voiceNote.duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "waveform.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(voiceNote.title)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text(voiceNote.createdAt, style: .date)
                        .font(.caption2)
                    
                    Text("·")
                    
                    Text(formattedDuration)
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
} 