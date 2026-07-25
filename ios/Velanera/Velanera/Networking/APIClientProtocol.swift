import Foundation

/// Contract for the single networking façade used across the app.
protocol APIClientProtocol: Sendable {
    func fetchHomeFeed() async throws -> HomeFeedResponse
    func fetchMenu() async throws -> [MenuItem]
    func fetchLoungeOfferings() async throws -> [LoungeOffering]
    func fetchEvents() async throws -> [VenueEvent]
    func fetchOpeningHours() async throws -> OpeningHours
    func createReservation(_ request: ReservationRequestDTO) async throws -> Reservation
    func fetchMembership() async throws -> Membership
    func fetchProfile() async throws -> UserProfile
    func sendConciergeMessage(_ request: ConciergeChatRequestDTO) async throws -> ConciergeResponse
    func createConciergeRequest(_ request: ConciergeRequestDTO) async throws -> ConciergeRequest
    func fetchExclusiveEvents() async throws -> [VenueEvent]
}
