import Foundation

/// Routes endpoint calls to rich mock payloads with realistic latency.
struct MockAPIResponder: Sendable {
    var artificialDelayNanoseconds: UInt64 = 280_000_000

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
        case .lounge:
            return try encoder.encode(MockBackend.lounge)
        case .events:
            return try encoder.encode(MockBackend.events)
        case .openingHours:
            return try encoder.encode(MockBackend.hours)
        case .membership:
            return try encoder.encode(MockBackend.membership)
        case .profile:
            return try encoder.encode(MockBackend.profile)
        case .exclusiveEvents:
            return try encoder.encode(MockBackend.events.filter(\.isMembersOnly))
        case .createReservation(let request):
            let reservation = Reservation(
                venue: request.venue,
                date: request.date,
                guestCount: request.guestCount,
                specialRequests: request.specialRequests,
                status: request.venue == .privateEvent ? .staffReview : .confirmed,
                contactName: request.contactName,
                contactEmail: request.contactEmail
            )
            return try encoder.encode(reservation)
        case .conciergeChat(let request):
            let response = MockConciergeAI.respond(to: request.transcript, history: request.history)
            return try encoder.encode(response)
        case .createConciergeRequest(let request):
            let created = ConciergeRequest(summary: request.summary, details: request.details)
            return try encoder.encode(created)
        }
    }
}
