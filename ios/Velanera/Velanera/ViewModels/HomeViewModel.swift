import Foundation
import Observation

/// Drives the Home tab feed.
@Observable
@MainActor
final class HomeViewModel {
    private let apiClient: APIClientProtocol
    private let analytics: AnalyticsServiceProtocol

    var featuredDishes: [MenuItem] = []
    var chefSpecials: [MenuItem] = []
    var events: [VenueEvent] = []
    var gallerySymbols: [String] = []
    var hours: OpeningHours?
    var isLoading = false
    var errorMessage: String?

    init(apiClient: APIClientProtocol, analytics: AnalyticsServiceProtocol) {
        self.apiClient = apiClient
        self.analytics = analytics
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        analytics.track(event: .screenView("home"))
        do {
            let feed = try await apiClient.fetchHomeFeed()
            featuredDishes = feed.featuredDishes
            chefSpecials = feed.chefSpecials
            events = feed.events
            gallerySymbols = feed.gallerySymbols
            hours = feed.hours
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
