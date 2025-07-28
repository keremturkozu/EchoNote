import Foundation
import AVFoundation

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    private var audioPlayer: AVAudioPlayer?
    
    @Published var isPlaying = false
    @Published var progress: Double = 0.0
    
    private var progressTimer: Timer?
    
    override init() {
        super.init()
    }
    
    func startPlayback(voiceNote: VoiceNote) {
        // Stop any current playback first
        stopPlayback()
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentPath.appendingPathComponent(voiceNote.filename)
        
        print("🎵 Starting playback for VoiceNote:")
        print("🎵 Title: \(voiceNote.title)")
        print("🎵 Filename: \(voiceNote.filename)")
        print("🎵 Created: \(voiceNote.createdAt)")
        print("🎵 Full path: \(audioURL.path)")
        print("🎵 File exists: \(FileManager.default.fileExists(atPath: audioURL.path))")
        
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            print("❌ Audio file not found at \\(audioURL.path)")
            return
        }
        
        let playbackSession = AVAudioSession.sharedInstance()
        do {
            try playbackSession.setCategory(.playback, mode: .default)
            try playbackSession.setActive(true)
        } catch {
            print("Setting up playback session failed: \\(error.localizedDescription)")
        }
        
        do {
            // Force fresh load of audio data to avoid caching issues
            let audioData = try Data(contentsOf: audioURL)
            print("🎵 Loaded audio data: \(audioData.count) bytes")
            
            // Create completely new AVAudioPlayer instance
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
            print("🎵 AVAudioPlayer created successfully")
            print("🎵 Audio duration: \(audioPlayer?.duration ?? 0) seconds")
            
            audioPlayer?.play()
            isPlaying = true
            startProgressTimer()
            
            print("🎵 Playback started successfully")
        } catch {
            print("❌ Playback failed: \(error.localizedDescription)")
        }
    }
    
    func stopPlayback() {
        print("🛑 Stopping current playback...")
        
        progressTimer?.invalidate()
        progressTimer = nil
        
        if let player = audioPlayer {
            player.stop()
            player.delegate = nil
            print("🛑 AudioPlayer stopped and delegate removed")
        }
        audioPlayer = nil
        
        isPlaying = false
        progress = 0.0
        
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            print("🛑 Audio session deactivated")
        } catch {
            print("❌ Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
    
    func togglePlayback() {
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            player.pause()
            isPlaying = false
            stopProgressTimer()
        } else {
            player.play()
            isPlaying = true
            startProgressTimer()
        }
    }
    
    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self.progress = player.currentTime / player.duration
        }
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        progress = 0.0
        stopProgressTimer()
    }
} 