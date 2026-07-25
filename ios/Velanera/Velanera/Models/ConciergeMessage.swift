import Foundation

enum ConciergeRole: String, Codable, Sendable {
    case guest
    case concierge
    case system
}

/// A single turn in the voice concierge conversation.
struct ConciergeMessage: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var role: ConciergeRole
    var text: String
    var createdAt: Date
    var isSpecialRequest: Bool

    init(
        id: UUID = UUID(),
        role: ConciergeRole,
        text: String,
        createdAt: Date = .now,
        isSpecialRequest: Bool = false
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
        self.isSpecialRequest = isSpecialRequest
    }
}

/// Staff-reviewable bespoke request created by the concierge.
struct ConciergeRequest: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var summary: String
    var details: String
    var createdAt: Date
    var status: ReservationStatus

    init(
        id: UUID = UUID(),
        summary: String,
        details: String,
        createdAt: Date = .now,
        status: ReservationStatus = .staffReview
    ) {
        self.id = id
        self.summary = summary
        self.details = details
        self.createdAt = createdAt
        self.status = status
    }
}

/// Response payload from the concierge conversation API.
struct ConciergeResponse: Codable, Sendable {
    var reply: String
    var shouldCreateStaffRequest: Bool
    var staffRequestSummary: String?
}
