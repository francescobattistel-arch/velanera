import Foundation

enum MembershipTier: String, Codable, CaseIterable, Sendable {
    case guest
    case house
    case black
    case founder

    var displayName: String {
        switch self {
        case .guest: "Guest"
        case .house: "House"
        case .black: "Black"
        case .founder: "Founder"
        }
    }

    var benefits: [String] {
        switch self {
        case .guest:
            ["Priority booking reminders", "Seasonal event invitations"]
        case .house:
            ["Preferred restaurant seating", "Lounge entry on selected nights", "Birthday amenity"]
        case .black:
            ["VIP table priority", "Exclusive tasting events", "Concierge line", "Complimentary welcome cocktail"]
        case .founder:
            ["Highest priority access", "Private area holds", "Bespoke celebrations", "Founders' dinners"]
        }
    }
}

/// Digital membership profile for the guest wallet card.
struct Membership: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var memberName: String
    var tier: MembershipTier
    var loyaltyPoints: Int
    var joinedAt: Date
    var qrPayload: String
    var exclusiveEventIDs: [UUID]

    init(
        id: UUID = UUID(),
        memberName: String,
        tier: MembershipTier,
        loyaltyPoints: Int,
        joinedAt: Date,
        qrPayload: String,
        exclusiveEventIDs: [UUID] = []
    ) {
        self.id = id
        self.memberName = memberName
        self.tier = tier
        self.loyaltyPoints = loyaltyPoints
        self.joinedAt = joinedAt
        self.qrPayload = qrPayload
        self.exclusiveEventIDs = exclusiveEventIDs
    }
}
