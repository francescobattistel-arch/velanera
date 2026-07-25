import Foundation

/// Configurable API base URL and feature flags. Keys never ship in the client.
struct APIConfiguration: Sendable {
    var baseURL: URL
    var useMockResponses: Bool
    var requestTimeout: TimeInterval

    static let defaultBaseURL = URL(string: "https://api.velanera.co/v1")!

    /// Loads configuration from Info.plist with safe defaults for local development.
    static func load(bundle: Bundle = .main) -> APIConfiguration {
        let base = bundle.object(forInfoDictionaryKey: "VELANERA_API_BASE_URL") as? String
        let url = base.flatMap(URL.init(string:)) ?? defaultBaseURL
        let mockFlag = bundle.object(forInfoDictionaryKey: "VELANERA_USE_MOCK_API") as? Bool ?? true
        return APIConfiguration(
            baseURL: url,
            useMockResponses: mockFlag,
            requestTimeout: 30
        )
    }
}
