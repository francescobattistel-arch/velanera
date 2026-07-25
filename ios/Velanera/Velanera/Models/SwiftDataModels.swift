import Foundation
import SwiftData

/// Locally persisted reservation for offline profile history.
@Model
final class PersistedReservation {
    @Attribute(.unique) var id: UUID
    var venueRaw: String
    var date: Date
    var guestCount: Int
    var specialRequests: String
    var statusRaw: String
    var contactName: String
    var contactEmail: String

    init(from reservation: Reservation) {
        self.id = reservation.id
        self.venueRaw = reservation.venue.rawValue
        self.date = reservation.date
        self.guestCount = reservation.guestCount
        self.specialRequests = reservation.specialRequests
        self.statusRaw = reservation.status.rawValue
        self.contactName = reservation.contactName
        self.contactEmail = reservation.contactEmail
    }

    var asReservation: Reservation {
        Reservation(
            id: id,
            venue: VenueType(rawValue: venueRaw) ?? .restaurant,
            date: date,
            guestCount: guestCount,
            specialRequests: specialRequests,
            status: ReservationStatus(rawValue: statusRaw) ?? .pending,
            contactName: contactName,
            contactEmail: contactEmail
        )
    }
}

/// Favourite dish reference stored on device.
@Model
final class FavouriteDish {
    @Attribute(.unique) var dishID: UUID
    var name: String
    var savedAt: Date

    init(dishID: UUID, name: String, savedAt: Date = .now) {
        self.dishID = dishID
        self.name = name
        self.savedAt = savedAt
    }
}

/// Persisted voice concierge transcript line.
@Model
final class ConciergeTranscriptEntry {
    @Attribute(.unique) var id: UUID
    var roleRaw: String
    var text: String
    var createdAt: Date
    var isSpecialRequest: Bool

    init(from message: ConciergeMessage) {
        self.id = message.id
        self.roleRaw = message.role.rawValue
        self.text = message.text
        self.createdAt = message.createdAt
        self.isSpecialRequest = message.isSpecialRequest
    }

    var asMessage: ConciergeMessage {
        ConciergeMessage(
            id: id,
            role: ConciergeRole(rawValue: roleRaw) ?? .system,
            text: text,
            createdAt: createdAt,
            isSpecialRequest: isSpecialRequest
        )
    }
}

/// Lightweight local profile cache.
@Model
final class PersistedUserProfile {
    @Attribute(.unique) var id: UUID
    var displayName: String
    var email: String
    var authProviderRaw: String
    var notificationsEnabled: Bool

    init(from profile: UserProfile) {
        self.id = profile.id
        self.displayName = profile.displayName
        self.email = profile.email
        self.authProviderRaw = profile.authProvider.rawValue
        self.notificationsEnabled = profile.notificationsEnabled
    }

    var asProfile: UserProfile {
        UserProfile(
            id: id,
            displayName: displayName,
            email: email,
            authProvider: AuthProvider(rawValue: authProviderRaw) ?? .none,
            notificationsEnabled: notificationsEnabled
        )
    }
}
