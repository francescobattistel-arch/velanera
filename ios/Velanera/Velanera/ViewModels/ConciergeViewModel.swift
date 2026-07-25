import Foundation
import CoreGraphics
import Observation
import SwiftData

/// Voice-first AI Concierge experience — no chat composer.
@Observable
@MainActor
final class ConciergeViewModel {
    private let speechRecognizer: SpeechRecognizerProtocol
    private let voicePlayback: VoicePlaybackServiceProtocol
    private let conversationEngine: ConversationEngineProtocol
    private let permissions: PermissionServiceProtocol
    private let analytics: AnalyticsServiceProtocol
    private let apiClient: APIClientProtocol
    private let settingsStore: SettingsStore

    var messages: [ConciergeMessage] = []
    var staffRequests: [ConciergeRequest] = []
    var liveTranscript: String = ""
    var audioLevels: [CGFloat] = Array(repeating: 0.12, count: 24)
    var isRecording = false
    var isProcessing = false
    var permissionDenied = false
    var errorMessage: String?
    var latestStaffRequest: ConciergeRequest?
    var suggestedPrompts: [String] = [
        "Book a table for two on Friday",
        "Recommend a wine with lamb",
        "VIP lounge for Saturday",
        "What's the dress code?"
    ]

    init(
        speechRecognizer: SpeechRecognizerProtocol,
        voicePlayback: VoicePlaybackServiceProtocol,
        conversationEngine: ConversationEngineProtocol,
        permissions: PermissionServiceProtocol,
        analytics: AnalyticsServiceProtocol,
        apiClient: APIClientProtocol,
        settingsStore: SettingsStore
    ) {
        self.speechRecognizer = speechRecognizer
        self.voicePlayback = voicePlayback
        self.conversationEngine = conversationEngine
        self.permissions = permissions
        self.analytics = analytics
        self.apiClient = apiClient
        self.settingsStore = settingsStore
    }

    func onAppear(modelContext: ModelContext) {
        analytics.track(event: .conciergeOpened)
        loadPersistedHistory(modelContext: modelContext)
        if messages.isEmpty {
            messages.append(
                ConciergeMessage(
                    role: .concierge,
                    text: "Welcome to Velanera. Hold the microphone and tell me how I may look after you."
                )
            )
        }
        Task { await refreshStaffRequests() }
    }

    func loadPersistedHistory(modelContext: ModelContext) {
        var descriptor = FetchDescriptor<ConciergeTranscriptEntry>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        descriptor.fetchLimit = 40
        let entries = (try? modelContext.fetch(descriptor)) ?? []
        if !entries.isEmpty {
            messages = entries.map(\.asMessage)
        }
    }

    func refreshStaffRequests() async {
        staffRequests = (try? await apiClient.fetchConciergeRequests()) ?? []
    }

    func beginHoldToTalk() async {
        guard !isRecording, !isProcessing else { return }
        let granted = await permissions.ensureConciergePermissions()
        guard granted else {
            permissionDenied = true
            errorMessage = "Microphone and Speech access are required for the concierge."
            return
        }
        permissionDenied = false
        voicePlayback.stop()
        do {
            try speechRecognizer.startRecording()
            isRecording = true
            HapticFeedback.medium()
            pollTranscript()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func endHoldToTalk(modelContext: ModelContext) async {
        guard isRecording else { return }
        isRecording = false
        let transcript = speechRecognizer.stopRecording()
        liveTranscript = transcript
        audioLevels = Array(repeating: 0.12, count: 24)
        await process(transcript: transcript, modelContext: modelContext)
    }

    func sendSuggestion(_ text: String, modelContext: ModelContext) async {
        guard !isRecording, !isProcessing else { return }
        await process(transcript: text, modelContext: modelContext)
    }

    private func pollTranscript() {
        Task {
            while isRecording {
                liveTranscript = speechRecognizer.transcript
                audioLevels = speechRecognizer.audioLevels
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
        }
    }

    private func process(transcript: String, modelContext: ModelContext) async {
        let trimmed = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "I didn’t catch that. Please try again."
            return
        }

        isProcessing = true
        errorMessage = nil
        analytics.track(event: .conciergeUtterance)

        let guestMessage = ConciergeMessage(role: .guest, text: trimmed)
        messages.append(guestMessage)
        modelContext.insert(ConciergeTranscriptEntry(from: guestMessage))

        do {
            let (response, staffRequest) = try await conversationEngine.respond(
                to: trimmed,
                history: messages
            )
            let reply = ConciergeMessage(
                role: .concierge,
                text: response.reply,
                isSpecialRequest: response.shouldCreateStaffRequest
            )
            messages.append(reply)
            modelContext.insert(ConciergeTranscriptEntry(from: reply))
            latestStaffRequest = staffRequest
            if staffRequest != nil {
                await refreshStaffRequests()
            }
            if settingsStore.settings.conciergeVoiceEnabled {
                voicePlayback.speak(response.reply)
            }
            HapticFeedback.success()
        } catch {
            errorMessage = error.localizedDescription
            HapticFeedback.warning()
        }

        isProcessing = false
        liveTranscript = ""
    }
}
