import Foundation

/// Contract for the single networking façade used across the app.
///
/// Every feature ViewModel depends on this protocol — never on concrete URLSession details.
/// Swap `useMockResponses` or inject a test double without touching UI.
protocol APIClientProtocol: Sendable {
    func fetchHomeFeed() async throws -> HomeFeedResponse
    func fetchMenu() async throws -> [MenuItem]
    func fetchMenuItem(id: UUID) async throws -> MenuItem
    func fetchChef() async throws -> ChefProfile
    func fetchLoungeOfferings() async throws -> [LoungeOffering]
    func fetchLoungeOffering(id: UUID) async throws -> LoungeOffering
    func fetchEvents() async throws -> [VenueEvent]
    func fetchEvent(id: UUID) async throws -> VenueEvent
    func fetchGallery() async throws -> [GalleryAsset]
    func fetchOpeningHours() async throws -> OpeningHours
    func fetchAvailability(_ query: AvailabilityQueryDTO) async throws -> [AvailabilitySlot]
    func createReservation(_ request: ReservationRequestDTO) async throws -> Reservation
    func updateReservation(id: UUID, update: ReservationUpdateDTO) async throws -> Reservation
    func cancelReservation(id: UUID) async throws -> Reservation
    func fetchMembership() async throws -> Membership
    func fetchMembershipTiers() async throws -> [MembershipTierInfo]
    func fetchProfile() async throws -> UserProfile
    func updateProfile(_ update: ProfileUpdateDTO) async throws -> UserProfile
    func sendConciergeMessage(_ request: ConciergeChatRequestDTO) async throws -> ConciergeResponse
    func createConciergeRequest(_ request: ConciergeRequestDTO) async throws -> ConciergeRequest
    func fetchConciergeRequests() async throws -> [ConciergeRequest]
    func fetchExclusiveEvents() async throws -> [VenueEvent]
    func rsvpEvent(_ request: EventRSVPRequestDTO) async throws -> EventRSVP
    func confirmPayment(_ request: PaymentConfirmDTO) async throws -> PaymentReceipt
    func registerPushToken(_ request: PushTokenDTO) async throws -> PushRegistrationResponse
}
