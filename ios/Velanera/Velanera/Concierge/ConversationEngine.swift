import Foundation

protocol ConversationEngineProtocol: Sendable {
    func respond(to transcript: String, history: [ConciergeMessage]) async throws -> (ConciergeResponse, ConciergeRequest?)
}

/// Orchestrates concierge turns: API reply plus optional staff-review request.
public final class ConversationEngine: ConversationEngineProtocol, @unchecked Sendable {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    public func respond(
        to transcript: String,
        history: [ConciergeMessage]
    ) async throws -> (ConciergeResponse, ConciergeRequest?) {
        let trimmed = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return (
                ConciergeResponse(
                    reply: "I didn’t quite catch that. Please hold the button and speak again.",
                    shouldCreateStaffRequest: false,
                    staffRequestSummary: nil
                ),
                nil
            )
        }

        let response = try await apiClient.sendConciergeMessage(
            ConciergeChatRequestDTO(transcript: trimmed, history: history)
        )

        var staffRequest: ConciergeRequest?
        if response.shouldCreateStaffRequest {
            let summary = response.staffRequestSummary ?? trimmed
            staffRequest = try await apiClient.createConciergeRequest(
                ConciergeRequestDTO(summary: summary, details: trimmed)
            )
        }

        return (response, staffRequest)
    }
}
