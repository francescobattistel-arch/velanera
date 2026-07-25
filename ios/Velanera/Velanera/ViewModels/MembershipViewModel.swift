import Foundation
import Observation

/// Membership card, loyalty, and exclusive events.
@Observable
@MainActor
final class MembershipViewModel {
    private let apiClient: APIClientProtocol
    private let analytics: AnalyticsServiceProtocol
    private let payments: PaymentServiceProtocol

    var membership: Membership?
    var exclusiveEvents: [VenueEvent] = []
    var checkoutSession: PaymentCheckoutSession?
    var isLoading = false
    var errorMessage: String?

    init(
        apiClient: APIClientProtocol,
        analytics: AnalyticsServiceProtocol,
        payments: PaymentServiceProtocol = PaymentService()
    ) {
        self.apiClient = apiClient
        self.analytics = analytics
        self.payments = payments
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        analytics.track(event: .membershipViewed)
        do {
            async let member = apiClient.fetchMembership()
            async let events = apiClient.fetchExclusiveEvents()
            membership = try await member
            exclusiveEvents = try await events
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func prepareUpgrade(to tier: MembershipTier) async {
        do {
            checkoutSession = try await payments.prepareMembershipCheckout(tier: tier)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
