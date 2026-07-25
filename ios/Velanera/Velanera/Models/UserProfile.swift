import Foundation

/// Authenticated or anonymous guest profile.
struct UserProfile: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var displayName: String
    var email: String
    var authProvider: AuthProvider
    var notificationsEnabled: Bool
    var favouriteDishIDs: [UUID]

    init(
        id: UUID = UUID(),
        displayName: String,
        email: String,
        authProvider: AuthProvider = .none,
        notificationsEnabled: Bool = true,
        favouriteDishIDs: [UUID] = []
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.authProvider = authProvider
        self.notificationsEnabled = notificationsEnabled
        self.favouriteDishIDs = favouriteDishIDs
    }
}

enum AuthProvider: String, Codable, Sendable {
    case none
    case apple
    case google
}
