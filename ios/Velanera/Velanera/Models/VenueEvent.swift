import Foundation

/// Public event, DJ night, or exclusive membership gathering.
struct VenueEvent: Identifiable, Codable, Hashable, Sendable {
    enum Kind: String, Codable, CaseIterable, Sendable {
        case dining
        case dj
        case liveMusic
        case tasting
        case privateHire
        case membersOnly

        var displayName: String {
            switch self {
            case .dining: "Dining"
            case .dj: "DJ Night"
            case .liveMusic: "Live Music"
            case .tasting: "Tasting"
            case .privateHire: "Private Hire"
            case .membersOnly: "Members"
            }
        }
    }

    let id: UUID
    var title: String
    var subtitle: String
    var detail: String
    var date: Date
    var endDate: Date?
    var kind: Kind
    var isMembersOnly: Bool
    var symbolName: String
    var venueLabel: String
    var capacity: Int
    var remainingSpaces: Int
    var dressCode: String
    var rsvpRequired: Bool

    var isSoldOut: Bool { remainingSpaces <= 0 }

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        detail: String = "",
        date: Date,
        endDate: Date? = nil,
        kind: Kind = .dining,
        isMembersOnly: Bool = false,
        symbolName: String = "music.note",
        venueLabel: String = "Velanera",
        capacity: Int = 80,
        remainingSpaces: Int = 40,
        dressCode: String = "Smart elegance",
        rsvpRequired: Bool = true
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.detail = detail.isEmpty ? subtitle : detail
        self.date = date
        self.endDate = endDate
        self.kind = kind
        self.isMembersOnly = isMembersOnly
        self.symbolName = symbolName
        self.venueLabel = venueLabel
        self.capacity = capacity
        self.remainingSpaces = remainingSpaces
        self.dressCode = dressCode
        self.rsvpRequired = rsvpRequired
    }
}
