import Foundation

protocol AnalyticsServiceProtocol: Sendable {
    func track(event: AnalyticsEvent)
}

enum AnalyticsEvent: Sendable {
    case screenView(String)
    case bookingStarted(VenueType)
    case bookingConfirmed(VenueType)
    case conciergeOpened
    case conciergeUtterance
    case membershipViewed
    case signIn(AuthProvider)

    var name: String {
        switch self {
        case .screenView: "screen_view"
        case .bookingStarted: "booking_started"
        case .bookingConfirmed: "booking_confirmed"
        case .conciergeOpened: "concierge_opened"
        case .conciergeUtterance: "concierge_utterance"
        case .membershipViewed: "membership_viewed"
        case .signIn: "sign_in"
        }
    }
}

/// Lightweight analytics sink — replace with a vendor SDK without changing call sites.
public final class AnalyticsService: AnalyticsServiceProtocol, @unchecked Sendable {
    public init() {}

    public func track(event: AnalyticsEvent) {
        #if DEBUG
        print("[Analytics] \(event.name)")
        #endif
    }
}
