import Foundation
import Observation

/// Lounge offerings, DJs, and private experiences.
@Observable
@MainActor
final class LoungeViewModel {
    private let apiClient: APIClientProtocol

    var offerings: [LoungeOffering] = []
    var events: [VenueEvent] = []
    var gallery: [GalleryAsset] = []
    var isLoading = false
    var errorMessage: String?

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func offerings(for kind: LoungeOffering.Kind) -> [LoungeOffering] {
        offerings.filter { $0.kind == kind }
    }

    var upcomingDJs: [VenueEvent] {
        events.filter { $0.kind == .dj }.sorted { $0.date < $1.date }
    }

    var bottleService: [LoungeOffering] {
        offerings(for: .bottleService)
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            async let lounge = apiClient.fetchLoungeOfferings()
            async let venueEvents = apiClient.fetchEvents()
            async let assets = apiClient.fetchGallery()
            offerings = try await lounge
            events = try await venueEvents
            gallery = try await assets.filter { $0.collection == .lounge }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
