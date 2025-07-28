import Foundation
import Speech
import AVFoundation

class SpeechRecognitionManager {
    
    private let transcriptionLanguageKey = "transcriptionLanguage"
    
    public func transcribe(audioURL: URL, completion: @escaping (String?) -> Void) {
        
        // 1. Request authorization
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus != .authorized {
                    print("Speech recognition authorization denied.")
                    completion(nil)
                    return
                }
                
                // 2. Get the selected language from UserDefaults, defaulting to Turkish
                let languageIdentifier = UserDefaults.standard.string(forKey: self.transcriptionLanguageKey) ?? "tr-TR"
                let locale = Locale(identifier: languageIdentifier)
                
                // 3. Create a recognizer for the selected locale
                guard let recognizer = SFSpeechRecognizer(locale: locale), recognizer.isAvailable else {
                    print("Speech recognizer is not available for the specified locale or on this device.")
                    completion(nil)
                    return
                }
                
                // 4. Create a recognition request
                let request = SFSpeechURLRecognitionRequest(url: audioURL)
                request.shouldReportPartialResults = false // We only want the final result
                
                // 5. Start recognition task
                recognizer.recognitionTask(with: request) { (result, error) in
                    guard let result = result, error == nil else {
                        if error != nil {
                            print("Recognition failed.")
                        }
                        completion(nil)
                        return
                    }
                    
                    if result.isFinal {
                        completion(result.bestTranscription.formattedString)
                    }
                }
            }
        }
    }
} 