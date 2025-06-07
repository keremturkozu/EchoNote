import Foundation
import SwiftData

@Model
final class VoiceNote {
    var filename: String
    var title: String
    var createdAt: Date
    var duration: TimeInterval // Ses kaydının süresini saniye cinsinden tutar
    @Attribute(.externalStorage) var transcribedText: String?

    init(filename: String, title: String? = nil, createdAt: Date, duration: TimeInterval) {
        self.filename = filename
        self.createdAt = createdAt
        self.duration = duration
        self.transcribedText = nil
        // Set title after other properties are initialized to use them
        self.title = title ?? "Recording \\(createdAt.formatted(date: .numeric, time: .shortened))"
    }
} 