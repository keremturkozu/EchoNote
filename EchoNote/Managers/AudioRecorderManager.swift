import Foundation
import AVFoundation

struct Recording {
    let fileURL: URL
    let createdAt: Date
    let duration: TimeInterval
}

class AudioRecorderManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder?
    var creationDate: Date?
    
    @Published var isRecording = false
    
    override init() {
        super.init()
    }
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session: \\(error.localizedDescription)")
        }
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath.appendingPathComponent("\\(UUID().uuidString).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitRateKey: 192000,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            creationDate = Date()
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Could not start recording: \\(error.localizedDescription)")
            _ = stopRecording()
        }
    }
    
    @discardableResult
    func stopRecording(delete: Bool = false) -> Recording? {
        guard let recorder = audioRecorder else { return nil }
        
        let duration = recorder.currentTime
        let url = recorder.url
        recorder.stop()
        
        isRecording = false
        
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setActive(false)
        } catch {
            print("Failed to deactivate audio session: \\(error.localizedDescription)")
        }
        
        if delete {
            do {
                try FileManager.default.removeItem(at: url)
                return nil
            } catch {
                print("Failed to delete recording: \\(error.localizedDescription)")
            }
        }
        
        return Recording(fileURL: url, createdAt: creationDate ?? Date(), duration: duration)
    }
    
    // MARK: - AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            _ = stopRecording()
        }
    }
} 