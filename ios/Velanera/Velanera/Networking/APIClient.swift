import Foundation

/// Single networking façade. Every feature talks to the backend through this type.
///
/// When `useMockResponses` is enabled, requests never leave the device.
/// Production traffic uses `URLSession` against the configured base URL.
/// API keys must never be embedded in the client — attach them server-side.
public final class APIClient: APIClientProtocol, @unchecked Sendable {
    private let configuration: APIConfiguration
    private let session: URLSession
    private let mockResponder: MockAPIResponder
    private let authTokenProvider: @Sendable () -> String?

    /// Creates a client with injectable session, configuration, and optional bearer token.
    public init(
        configuration: APIConfiguration = .load(),
        session: URLSession = .shared,
        mockResponder: MockAPIResponder = MockAPIResponder(),
        authTokenProvider: @escaping @Sendable () -> String? = { nil }
    ) {
        self.configuration = configuration
        self.session = session
        self.mockResponder = mockResponder
        self.authTokenProvider = authTokenProvider
    }

    public func fetchHomeFeed() async throws -> HomeFeedResponse { try await send(.homeFeed) }
    public func fetchMenu() async throws -> [MenuItem] { try await send(.menu) }
    public func fetchMenuItem(id: UUID) async throws -> MenuItem { try await send(.menuItem(id)) }
    public func fetchChef() async throws -> ChefProfile { try await send(.chef) }
    public func fetchLoungeOfferings() async throws -> [LoungeOffering] { try await send(.lounge) }
    public func fetchLoungeOffering(id: UUID) async throws -> LoungeOffering { try await send(.loungeOffering(id)) }
    public func fetchEvents() async throws -> [VenueEvent] { try await send(.events) }
    public func fetchEvent(id: UUID) async throws -> VenueEvent { try await send(.event(id)) }
    public func fetchGallery() async throws -> [GalleryAsset] { try await send(.gallery) }
    public func fetchOpeningHours() async throws -> OpeningHours { try await send(.openingHours) }
    public func fetchAvailability(_ query: AvailabilityQueryDTO) async throws -> [AvailabilitySlot] {
        try await send(.availability(query))
    }
    public func createReservation(_ request: ReservationRequestDTO) async throws -> Reservation {
        try await send(.createReservation(request))
    }
    public func updateReservation(id: UUID, update: ReservationUpdateDTO) async throws -> Reservation {
        try await send(.updateReservation(id, update))
    }
    public func cancelReservation(id: UUID) async throws -> Reservation {
        try await send(.cancelReservation(id))
    }
    public func fetchMembership() async throws -> Membership { try await send(.membership) }
    public func fetchMembershipTiers() async throws -> [MembershipTierInfo] {
        let response: MembershipTiersResponse = try await send(.membershipTiers)
        return response.tiers
    }
    public func fetchProfile() async throws -> UserProfile { try await send(.profile) }
    public func updateProfile(_ update: ProfileUpdateDTO) async throws -> UserProfile {
        try await send(.updateProfile(update))
    }
    public func sendConciergeMessage(_ request: ConciergeChatRequestDTO) async throws -> ConciergeResponse {
        try await send(.conciergeChat(request))
    }
    public func createConciergeRequest(_ request: ConciergeRequestDTO) async throws -> ConciergeRequest {
        try await send(.createConciergeRequest(request))
    }
    public func fetchConciergeRequests() async throws -> [ConciergeRequest] {
        try await send(.conciergeRequests)
    }
    public func fetchExclusiveEvents() async throws -> [VenueEvent] { try await send(.exclusiveEvents) }
    public func rsvpEvent(_ request: EventRSVPRequestDTO) async throws -> EventRSVP {
        try await send(.rsvpEvent(request))
    }
    public func confirmPayment(_ request: PaymentConfirmDTO) async throws -> PaymentReceipt {
        try await send(.confirmPayment(request))
    }
    public func registerPushToken(_ request: PushTokenDTO) async throws -> PushRegistrationResponse {
        try await send(.registerPushToken(request))
    }

    private func send<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        if configuration.useMockResponses {
            return try await mockResponder.respond(to: endpoint, as: T.self)
        }
        return try await performNetworkRequest(endpoint)
    }

    private func performNetworkRequest<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = URL(string: endpoint.path, relativeTo: configuration.baseURL)?.absoluteURL else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.timeoutInterval = configuration.requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = authTokenProvider() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = endpoint.body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
            guard (200..<300).contains(http.statusCode) else {
                if http.statusCode == 401 { throw APIError.unauthorized }
                throw APIError.httpStatus(http.statusCode)
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decoding(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.transport(error)
        }
    }
}
