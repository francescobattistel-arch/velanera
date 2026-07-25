import Foundation

/// Guest RSVP against a venue event.
struct EventRSVP: Identifiable, Codable, Hashable, Sendable {
    enum Status: String, Codable, Sendable {
        case requested
        case confirmed
        case waitlisted
        case declined
    }

    let id: UUID
    var eventID: UUID
    var guestName: String
    var guestCount: Int
    var status: Status
    var createdAt: Date

    init(
        id: UUID = UUID(),
        eventID: UUID,
        guestName: String,
        guestCount: Int,
        status: Status = .requested,
        createdAt: Date = .now
    ) {
        self.id = id
        self.eventID = eventID
        self.guestName = guestName
        self.guestCount = guestCount
        self.status = status
        self.createdAt = createdAt
    }
}
