import Foundation
import AVFoundation

protocol VoicePlaybackServiceProtocol: AnyObject, Sendable {
    @MainActor func speak(_ text: String)
    @MainActor func stop()
}

/// Speaks concierge replies with a calm, premium voice.
@MainActor
public final class VoicePlaybackService: NSObject, VoicePlaybackServiceProtocol, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()

    public override init() {
        super.init()
        synthesizer.delegate = self
    }

    public func speak(_ text: String) {
        stop()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
            ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.92
        utterance.pitchMultiplier = 0.98
        utterance.preUtteranceDelay = 0.15
        utterance.postUtteranceDelay = 0.1

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            // Playback may still succeed with the current session.
        }

        synthesizer.speak(utterance)
    }

    public func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}
