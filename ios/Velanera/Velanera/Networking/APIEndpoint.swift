import Foundation

/// Declarative API routes used by every feature through `APIClient`.
enum APIEndpoint: Sendable {
    case homeFeed
    case menu
    case lounge
    case events
    case openingHours
    case createReservation(ReservationRequestDTO)
    case membership
    case profile
    case conciergeChat(ConciergeChatRequestDTO)
    case createConciergeRequest(ConciergeRequestDTO)
    case exclusiveEvents

    var path: String {
        switch self {
        case .homeFeed: "/home"
        case .menu: "/menu"
        case .lounge: "/lounge"
        case .events: "/events"
        case .openingHours: "/hours"
        case .createReservation: "/reservations"
        case .membership: "/membership"
        case .profile: "/profile"
        case .conciergeChat: "/concierge/chat"
        case .createConciergeRequest: "/concierge/requests"
        case .exclusiveEvents: "/membership/events"
        }
    }

    var method: String {
        switch self {
        case .createReservation, .conciergeChat, .createConciergeRequest:
            "POST"
        default:
            "GET"
        }
    }

    var body: Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        switch self {
        case .createReservation(let dto):
            return try? encoder.encode(dto)
        case .conciergeChat(let dto):
            return try? encoder.encode(dto)
        case .createConciergeRequest(let dto):
            return try? encoder.encode(dto)
        default:
            return nil
        }
    }
}

struct ReservationRequestDTO: Codable, Sendable {
    var venue: VenueType
    var date: Date
    var guestCount: Int
    var specialRequests: String
    var contactName: String
    var contactEmail: String
}

struct ConciergeChatRequestDTO: Codable, Sendable {
    var transcript: String
    var history: [ConciergeMessage]
}

struct ConciergeRequestDTO: Codable, Sendable {
    var summary: String
    var details: String
}

struct HomeFeedResponse: Codable, Sendable {
    var featuredDishes: [MenuItem]
    var chefSpecials: [MenuItem]
    var events: [VenueEvent]
    var gallerySymbols: [String]
    var hours: OpeningHours
}
