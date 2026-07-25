import Foundation

/// Declarative API routes used by every feature through `APIClient`.
enum APIEndpoint: Sendable {
    case homeFeed
    case menu
    case menuItem(UUID)
    case chef
    case lounge
    case loungeOffering(UUID)
    case events
    case event(UUID)
    case gallery
    case openingHours
    case availability(AvailabilityQueryDTO)
    case createReservation(ReservationRequestDTO)
    case updateReservation(UUID, ReservationUpdateDTO)
    case cancelReservation(UUID)
    case membership
    case membershipTiers
    case profile
    case updateProfile(ProfileUpdateDTO)
    case conciergeChat(ConciergeChatRequestDTO)
    case createConciergeRequest(ConciergeRequestDTO)
    case conciergeRequests
    case exclusiveEvents
    case rsvpEvent(EventRSVPRequestDTO)
    case confirmPayment(PaymentConfirmDTO)
    case registerPushToken(PushTokenDTO)

    var path: String {
        switch self {
        case .homeFeed: "/home"
        case .menu: "/menu"
        case .menuItem(let id): "/menu/\(id.uuidString)"
        case .chef: "/chef"
        case .lounge: "/lounge"
        case .loungeOffering(let id): "/lounge/\(id.uuidString)"
        case .events: "/events"
        case .event(let id): "/events/\(id.uuidString)"
        case .gallery: "/gallery"
        case .openingHours: "/hours"
        case .availability: "/reservations/availability"
        case .createReservation: "/reservations"
        case .updateReservation(let id, _): "/reservations/\(id.uuidString)"
        case .cancelReservation(let id): "/reservations/\(id.uuidString)/cancel"
        case .membership: "/membership"
        case .membershipTiers: "/membership/tiers"
        case .profile: "/profile"
        case .updateProfile: "/profile"
        case .conciergeChat: "/concierge/chat"
        case .createConciergeRequest: "/concierge/requests"
        case .conciergeRequests: "/concierge/requests"
        case .exclusiveEvents: "/membership/events"
        case .rsvpEvent: "/events/rsvp"
        case .confirmPayment: "/payments/confirm"
        case .registerPushToken: "/devices/push-token"
        }
    }

    var method: String {
        switch self {
        case .createReservation, .conciergeChat, .createConciergeRequest,
             .rsvpEvent, .confirmPayment, .registerPushToken, .availability:
            "POST"
        case .updateReservation, .updateProfile:
            "PATCH"
        case .cancelReservation:
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
        case .updateReservation(_, let dto):
            return try? encoder.encode(dto)
        case .conciergeChat(let dto):
            return try? encoder.encode(dto)
        case .createConciergeRequest(let dto):
            return try? encoder.encode(dto)
        case .availability(let dto):
            return try? encoder.encode(dto)
        case .updateProfile(let dto):
            return try? encoder.encode(dto)
        case .rsvpEvent(let dto):
            return try? encoder.encode(dto)
        case .confirmPayment(let dto):
            return try? encoder.encode(dto)
        case .registerPushToken(let dto):
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
    var contactPhone: String
    var offeringID: UUID?
    var occasion: String
}

struct ReservationUpdateDTO: Codable, Sendable {
    var date: Date?
    var guestCount: Int?
    var specialRequests: String?
    var status: ReservationStatus?
}

struct ConciergeChatRequestDTO: Codable, Sendable {
    var transcript: String
    var history: [ConciergeMessage]
}

struct ConciergeRequestDTO: Codable, Sendable {
    var summary: String
    var details: String
}

struct AvailabilityQueryDTO: Codable, Sendable {
    var venue: VenueType
    var date: Date
    var guestCount: Int
}

struct ProfileUpdateDTO: Codable, Sendable {
    var displayName: String
    var email: String
    var phone: String?
    var notificationsEnabled: Bool
}

struct EventRSVPRequestDTO: Codable, Sendable {
    var eventID: UUID
    var guestName: String
    var guestCount: Int
}

struct PaymentConfirmDTO: Codable, Sendable {
    var sessionID: String
    var tier: MembershipTier
}

struct PushTokenDTO: Codable, Sendable {
    var token: String
    var platform: String
}

struct HomeFeedResponse: Codable, Sendable {
    var featuredDishes: [MenuItem]
    var chefSpecials: [MenuItem]
    var events: [VenueEvent]
    var gallery: [GalleryAsset]
    var hours: OpeningHours
}

struct MembershipTiersResponse: Codable, Sendable {
    var tiers: [MembershipTierInfo]
}

struct MembershipTierInfo: Codable, Hashable, Sendable, Identifiable {
    var id: MembershipTier { tier }
    var tier: MembershipTier
    var annualFee: Decimal
    var tagline: String
    var benefits: [String]
}

struct PaymentReceipt: Codable, Hashable, Sendable, Identifiable {
    let id: String
    var tier: MembershipTier
    var amount: Decimal
    var currencyCode: String
    var confirmedAt: Date
    var status: String
}

struct PushRegistrationResponse: Codable, Sendable {
    var accepted: Bool
}
