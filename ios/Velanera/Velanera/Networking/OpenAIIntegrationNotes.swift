import Foundation

/// OpenAI integration notes for the Velanera Concierge.
///
/// IMPORTANT: Never place OpenAI API keys in the iOS client.
/// The production path is:
/// 1. App → Velanera backend (`APIClient` → `/concierge/chat`)
/// 2. Backend (Cloudflare Worker in `workers/concierge/`) attaches secrets and calls OpenAI Chat Completions
/// 3. Backend returns `ConciergeResponse` to the app
///
/// The web prototype uses the same worker when `CONCIERGE_API_BASE` is configured.
/// Toggle `APIConfiguration.useMockResponses` to `false` once the backend is live.
public enum OpenAIIntegrationNotes {
    public static let intendedBackendModel = "gpt-4.1"
    public static let systemPromptOwner = "server"
    public static let clientMustNotHoldAPIKeys = true
    public static let workerPath = "/concierge/chat"

    /// Placeholder request shape the backend should accept.
    public struct BackendConciergeEnvelope: Codable, Sendable {
        public var transcript: String
        public var history: [ConciergeMessage]
        public var systemPromptVersion: String
    }
}
