import Foundation
import AVFoundation

protocol VoicePlaybackServiceProtocol: AnyObject, Sendable {
    @MainActor func speak(_ text: String)
    @MainActor func stop()
}

/// Speaks concierge replies with a distinctly non-default host voice.
/// Never uses Samantha (iPhone en-US default). Prefers Italian Alice for a
/// Mediterranean host presence when speaking English.
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
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.84
        utterance.pitchMultiplier = 1.05
        utterance.preUtteranceDelay = 0.15
        utterance.postUtteranceDelay = 0.12

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

    private static func preferredHostVoice() -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices()

        func named(_ name: String) -> AVSpeechSynthesisVoice? {
            voices.first { $0.name.compare(name, options: [.caseInsensitive]) == .orderedSame }
        }

        // Italian Alice → Irish Moira → Australian Karen → South African Tessa
        // Never Samantha (en-US stock).
        return named("Alice")
            ?? voices.first(where: { $0.language.hasPrefix("it-IT") && $0.name.localizedCaseInsensitiveContains("Alice") })
            ?? voices.first(where: { $0.language.hasPrefix("it") })
            ?? named("Moira")
            ?? voices.first(where: { $0.language.hasPrefix("en-IE") })
            ?? named("Karen")
            ?? voices.first(where: { $0.language.hasPrefix("en-AU") })
            ?? named("Tessa")
            ?? voices.first(where: { $0.language.hasPrefix("en-ZA") })
            ?? AVSpeechSynthesisVoice(language: "it-IT")
            ?? AVSpeechSynthesisVoice(language: "en-IE")
            ?? AVSpeechSynthesisVoice(language: "en-AU")
    }
}
