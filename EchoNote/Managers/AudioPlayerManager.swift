import Foundation
import AVFoundation

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    var audioPlayer: AVAudioPlayer?
    
    @Published var isPlaying = false
    @Published var progress: Double = 0.0
    
    private var progressTimer: Timer?
    
    func startPlayback(voiceNote: VoiceNote) {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentPath.appendingPathComponent(voiceNote.filename)
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            print("Audio file not found at \\(audioURL.path)")
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
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            startProgressTimer()
        } catch {
            print("Playback failed: \\(error.localizedDescription)")
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
        stopProgressTimer()
        audioPlayer = nil
        
        // Deactivate the audio session to allow other audio to play
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \\(error.localizedDescription)")
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
        progressTimer?.invalidate() // Stop any existing timer
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self.progress = player.currentTime / player.duration
        }
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        progress = 0.0
        stopProgressTimer()
    }
} 