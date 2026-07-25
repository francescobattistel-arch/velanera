import Foundation
import AVFoundation

protocol VoicePlaybackServiceProtocol: AnyObject, Sendable {
    @MainActor func speak(_ text: String)
    @MainActor func stop()
}

/// Speaks concierge replies with a warm, intimate female host voice.
/// Avoids Samantha (iPhone default) so the host does not sound unchanged.
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
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.78
        utterance.pitchMultiplier = 0.88
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

    /// Prefer non-default female accents (Karen / Moira / Tessa) over Samantha.
    private static func preferredHostVoice() -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        let preferredNames = [
            "Karen", "Moira", "Tessa", "Fiona", "Kate", "Serena", "Ava", "Zoe"
        ]
        let blocked = ["Samantha", "Alex", "Daniel", "Arthur", "Aaron", "Fred"]

        for name in preferredNames {
            if let match = voices.first(where: { voice in
                voice.name.localizedCaseInsensitiveContains(name)
                    && voice.language.hasPrefix("en")
                    && !blocked.contains(where: { voice.name.localizedCaseInsensitiveContains($0) })
            }) {
                return match
            }
        }

        let english = voices.filter { voice in
            guard voice.language.hasPrefix("en") else { return false }
            let n = voice.name.lowercased()
            if blocked.contains(where: { n.contains($0.lowercased()) }) { return false }
            if n.contains("male") && !n.contains("female") { return false }
            return true
        }

        return english.first(where: { $0.language.hasPrefix("en-AU") })
            ?? english.first(where: { $0.language.hasPrefix("en-IE") })
            ?? english.first(where: { $0.quality == .enhanced })
            ?? english.first(where: { $0.language.hasPrefix("en-GB") })
            ?? english.first
            ?? AVSpeechSynthesisVoice(language: "en-AU")
            ?? AVSpeechSynthesisVoice(language: "en-GB")
            ?? AVSpeechSynthesisVoice(language: "en-US")
    }
}
