import Foundation
import AVFoundation
import Speech

protocol PermissionServiceProtocol: Sendable {
    func requestMicrophoneAccess() async -> Bool
    func requestSpeechAccess() async -> Bool
    func ensureConciergePermissions() async -> Bool
}

/// Coordinates microphone and speech recognition permissions.
public final class PermissionService: PermissionServiceProtocol, @unchecked Sendable {
    public init() {}

    public func requestMicrophoneAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    public func requestSpeechAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    public func ensureConciergePermissions() async -> Bool {
        let mic = await requestMicrophoneAccess()
        let speech = await requestSpeechAccess()
        return mic && speech
    }
}
