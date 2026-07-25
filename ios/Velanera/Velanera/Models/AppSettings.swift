import Foundation

/// User-facing preferences persisted locally and syncable later.
struct AppSettings: Codable, Hashable, Sendable {
    var notificationsEnabled: Bool
    var marketingEmailsEnabled: Bool
    var conciergeVoiceEnabled: Bool
    var reduceMotion: Bool
    var preferredLanguageCode: String
    var dietaryExclusions: [Allergen]

    static let `default` = AppSettings(
        notificationsEnabled: true,
        marketingEmailsEnabled: false,
        conciergeVoiceEnabled: true,
        reduceMotion: false,
        preferredLanguageCode: "en-GB",
        dietaryExclusions: []
    )
}
