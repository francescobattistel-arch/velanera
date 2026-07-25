import Foundation
import AVFoundation

protocol VoicePlaybackServiceProtocol: AnyObject, Sendable {
    @MainActor func speak(_ text: String)
    @MainActor func stop()
}

/// Speaks concierge replies with a warm, intimate female host voice.
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
        utterance.voice = Self.preferredHostVoice()
        // Slower and slightly lower — soft late-evening presence
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.82
        utterance.pitchMultiplier = 0.9
        utterance.preUtteranceDelay = 0.2
        utterance.postUtteranceDelay = 0.15

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

    /// Prefers enhanced/premium female English voices when installed on device.
    private static func preferredHostVoice() -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        let preferredNames = [
            "Samantha", "Ava", "Zoe", "Allison", "Susan", "Karen", "Moira", "Tessa", "Fiona"
        ]

        for name in preferredNames {
            if let match = voices.first(where: {
                $0.name.localizedCaseInsensitiveContains(name) && $0.language.hasPrefix("en")
            }) {
                return match
            }
        }

        let englishFemale = voices.filter { voice in
            guard voice.language.hasPrefix("en") else { return false }
            // Prefer higher-quality voices; avoid obviously male identifiers.
            let n = voice.name.lowercased()
            if n.contains("male") && !n.contains("female") { return false }
            return true
        }

        return englishFemale.first(where: { $0.quality == .enhanced })
            ?? englishFemale.first(where: { $0.language.hasPrefix("en-GB") })
            ?? englishFemale.first
            ?? AVSpeechSynthesisVoice(language: "en-GB")
            ?? AVSpeechSynthesisVoice(language: "en-US")
    }
}
