import Foundation

/// Scaffold for future OpenAI Responses API integration.
///
/// IMPORTANT: Never place OpenAI API keys in the iOS client.
/// The production path is:
/// 1. App → Velanera backend (`APIClient` → `/concierge/chat`)
/// 2. Backend attaches secrets and calls OpenAI Responses API
/// 3. Backend returns `ConciergeResponse` to the app
///
/// Toggle `APIConfiguration.useMockResponses` to `false` once the backend is live.
public enum OpenAIIntegrationNotes {
    public static let intendedBackendModel = "gpt-4.1"
    public static let systemPromptOwner = "server"
    public static let clientMustNotHoldAPIKeys = true

    /// Placeholder request shape the backend should accept.
    public struct BackendConciergeEnvelope: Codable, Sendable {
        public var transcript: String
        public var history: [ConciergeMessage]
        public var systemPromptVersion: String
    }
}
