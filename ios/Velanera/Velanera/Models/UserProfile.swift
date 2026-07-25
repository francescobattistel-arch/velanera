import Foundation

/// Authenticated or anonymous guest profile.
struct UserProfile: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var displayName: String
    var email: String
    var phone: String
    var authProvider: AuthProvider
    var notificationsEnabled: Bool
    var favouriteDishIDs: [UUID]
    var dietaryExclusions: [Allergen]

    init(
        id: UUID = UUID(),
        displayName: String,
        email: String,
        phone: String = "",
        authProvider: AuthProvider = .none,
        notificationsEnabled: Bool = true,
        favouriteDishIDs: [UUID] = [],
        dietaryExclusions: [Allergen] = []
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.phone = phone
        self.authProvider = authProvider
        self.notificationsEnabled = notificationsEnabled
        self.favouriteDishIDs = favouriteDishIDs
        self.dietaryExclusions = dietaryExclusions
    }
}

enum AuthProvider: String, Codable, Sendable {
    case none
    case apple
    case google
}
