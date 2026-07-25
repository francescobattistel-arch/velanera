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

    /// Creates a client with injectable session and configuration.
    public init(
        configuration: APIConfiguration = .load(),
        session: URLSession = .shared,
        mockResponder: MockAPIResponder = MockAPIResponder()
    ) {
        self.configuration = configuration
        self.session = session
        self.mockResponder = mockResponder
    }

    public func fetchHomeFeed() async throws -> HomeFeedResponse {
        try await send(.homeFeed)
    }

    public func fetchMenu() async throws -> [MenuItem] {
        try await send(.menu)
    }

    public func fetchLoungeOfferings() async throws -> [LoungeOffering] {
        try await send(.lounge)
    }

    public func fetchEvents() async throws -> [VenueEvent] {
        try await send(.events)
    }

    public func fetchOpeningHours() async throws -> OpeningHours {
        try await send(.openingHours)
    }

    public func createReservation(_ request: ReservationRequestDTO) async throws -> Reservation {
        try await send(.createReservation(request))
    }

    public func fetchMembership() async throws -> Membership {
        try await send(.membership)
    }

    public func fetchProfile() async throws -> UserProfile {
        try await send(.profile)
    }

    public func sendConciergeMessage(_ request: ConciergeChatRequestDTO) async throws -> ConciergeResponse {
        try await send(.conciergeChat(request))
    }

    public func createConciergeRequest(_ request: ConciergeRequestDTO) async throws -> ConciergeRequest {
        try await send(.createConciergeRequest(request))
    }

    public func fetchExclusiveEvents() async throws -> [VenueEvent] {
        try await send(.exclusiveEvents)
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
        if let body = endpoint.body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
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
