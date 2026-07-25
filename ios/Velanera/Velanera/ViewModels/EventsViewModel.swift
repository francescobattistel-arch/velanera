import Foundation
import Observation

/// Venue-wide events calendar and RSVP.
@Observable
@MainActor
final class EventsViewModel {
    private let apiClient: APIClientProtocol
    private let analytics: AnalyticsServiceProtocol

    var events: [VenueEvent] = []
    var selectedKind: VenueEvent.Kind?
    var isLoading = false
    var errorMessage: String?
    var lastRSVP: EventRSVP?
    var isSubmittingRSVP = false

    init(apiClient: APIClientProtocol, analytics: AnalyticsServiceProtocol) {
        self.apiClient = apiClient
        self.analytics = analytics
    }

    var filteredEvents: [VenueEvent] {
        let base = events.sorted { $0.date < $1.date }
        guard let selectedKind else { return base }
        return base.filter { $0.kind == selectedKind }
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        analytics.track(event: .screenView("events"))
        do {
            events = try await apiClient.fetchEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func event(id: UUID) -> VenueEvent? {
        events.first { $0.id == id }
    }

    func rsvp(event: VenueEvent, name: String, guests: Int) async {
        isSubmittingRSVP = true
        errorMessage = nil
        do {
            lastRSVP = try await apiClient.rsvpEvent(
                EventRSVPRequestDTO(eventID: event.id, guestName: name, guestCount: guests)
            )
            HapticFeedback.success()
        } catch {
            errorMessage = error.localizedDescription
            HapticFeedback.warning()
        }
        isSubmittingRSVP = false
    }
}
