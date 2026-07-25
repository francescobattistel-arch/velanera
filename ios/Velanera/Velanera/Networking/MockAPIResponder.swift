import Foundation

/// Routes endpoint calls to rich mock payloads with realistic latency.
struct MockAPIResponder: Sendable {
    var artificialDelayNanoseconds: UInt64 = 220_000_000

    func respond<T: Decodable>(to endpoint: APIEndpoint, as type: T.Type) async throws -> T {
        try await Task.sleep(nanoseconds: artificialDelayNanoseconds)
        let data = try payload(for: endpoint)
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    private func payload(for endpoint: APIEndpoint) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        switch endpoint {
        case .homeFeed:
            return try encoder.encode(MockBackend.homeFeed())
        case .menu:
            return try encoder.encode(MockBackend.menu)
        case .menuItem(let id):
            guard let item = MockBackend.menuItem(id: id) else { throw APIError.mockUnavailable }
            return try encoder.encode(item)
        case .chef:
            return try encoder.encode(MockBackend.chef)
        case .lounge:
            return try encoder.encode(MockBackend.lounge)
        case .loungeOffering(let id):
            guard let offering = MockBackend.loungeOffering(id: id) else { throw APIError.mockUnavailable }
            return try encoder.encode(offering)
        case .events:
            return try encoder.encode(MockBackend.events)
        case .event(let id):
            guard let event = MockBackend.event(id: id) else { throw APIError.mockUnavailable }
            return try encoder.encode(event)
        case .gallery:
            return try encoder.encode(MockBackend.gallery)
        case .openingHours:
            return try encoder.encode(MockBackend.hours)
        case .availability(let query):
            return try encoder.encode(MockBackend.availability(for: query))
        case .membership:
            return try encoder.encode(MockBackend.membership)
        case .membershipTiers:
            return try encoder.encode(MembershipTiersResponse(tiers: MockBackend.membershipTiers))
        case .profile:
            return try encoder.encode(MockBackend.profile)
        case .updateProfile(let update):
            return try encoder.encode(MockBackend.updateProfile(update))
        case .exclusiveEvents:
            return try encoder.encode(MockBackend.events.filter(\.isMembersOnly))
        case .createReservation(let request):
            return try encoder.encode(MockBackend.createReservation(request))
        case .updateReservation(let id, let update):
            guard let reservation = MockBackend.updateReservation(id: id, update: update) else {
                throw APIError.mockUnavailable
            }
            return try encoder.encode(reservation)
        case .cancelReservation(let id):
            guard let reservation = MockBackend.cancelReservation(id: id) else {
                throw APIError.mockUnavailable
            }
            return try encoder.encode(reservation)
        case .conciergeChat(let request):
            let response = MockConciergeAI.respond(to: request.transcript, history: request.history)
            return try encoder.encode(response)
        case .createConciergeRequest(let request):
            let created = ConciergeRequest(summary: request.summary, details: request.details)
            return try encoder.encode(MockBackend.storeConciergeRequest(created))
        case .conciergeRequests:
            return try encoder.encode(MockBackend.allConciergeRequests())
        case .rsvpEvent(let request):
            return try encoder.encode(MockBackend.rsvp(request))
        case .confirmPayment(let request):
            return try encoder.encode(MockBackend.confirmPayment(request))
        case .registerPushToken:
            return try encoder.encode(PushRegistrationResponse(accepted: true))
        }
    }
}
