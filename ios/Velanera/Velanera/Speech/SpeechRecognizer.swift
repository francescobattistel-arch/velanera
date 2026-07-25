import Foundation
import CoreGraphics
import Speech
import AVFoundation

protocol SpeechRecognizerProtocol: AnyObject, Sendable {
    @MainActor var transcript: String { get }
    @MainActor var audioLevels: [CGFloat] { get }
    @MainActor func requestAuthorization() async -> Bool
    @MainActor func startRecording() throws
    @MainActor func stopRecording() -> String
}

/// Live speech-to-text powered by Apple's Speech framework.
@MainActor
public final class SpeechRecognizer: NSObject, SpeechRecognizerProtocol {
    private(set) public var transcript: String = ""
    private(set) public var audioLevels: [CGFloat] = Array(repeating: 0.15, count: 24)

    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-GB"))
    private var levelTimer: Timer?

    public func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    public func startRecording() throws {
        stopEngineIfNeeded()
        transcript = ""

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else {
            throw APIError.serverMessage("Unable to create speech request.")
        }
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.addsPunctuation = true

        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            self?.updateLevels(from: buffer)
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self else { return }
            if let result {
                Task { @MainActor in
                    self.transcript = result.bestTranscription.formattedString
                }
            }
            if error != nil || (result?.isFinal ?? false) {
                Task { @MainActor in
                    self.audioEngine.stop()
                    input.removeTap(onBus: 0)
                }
            }
        }

        audioEngine.prepare()
        try audioEngine.start()
        startLevelSimulation()
    }

    public func stopRecording() -> String {
        recognitionRequest?.endAudio()
        stopEngineIfNeeded()
        levelTimer?.invalidate()
        levelTimer = nil
        audioLevels = Array(repeating: 0.12, count: 24)
        return transcript
    }

    private func stopEngineIfNeeded() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
    }

    private func startLevelSimulation() {
        levelTimer?.invalidate()
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.audioEngine.isRunning else { return }
                self.audioLevels = self.audioLevels.map { _ in CGFloat.random(in: 0.12...0.95) }
            }
        }
    }

    nonisolated private func updateLevels(from buffer: AVAudioPCMBuffer) {
        guard let channel = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        guard frameLength > 0 else { return }
        var sum: Float = 0
        for index in 0..<frameLength {
            let sample = channel[index]
            sum += sample * sample
        }
        let rms = sqrt(sum / Float(frameLength))
        let normalized = CGFloat(min(max(rms * 8, 0.08), 1))
        Task { @MainActor in
            var next = audioLevels
            if !next.isEmpty {
                next.removeFirst()
                next.append(normalized)
                audioLevels = next
            }
        }
    }
}
