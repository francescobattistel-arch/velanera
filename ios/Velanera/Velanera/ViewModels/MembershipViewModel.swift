import Foundation
import Observation

/// Membership card, loyalty, tiers, and checkout.
@Observable
@MainActor
final class MembershipViewModel {
    private let apiClient: APIClientProtocol
    private let analytics: AnalyticsServiceProtocol
    private let payments: PaymentServiceProtocol

    var membership: Membership?
    var exclusiveEvents: [VenueEvent] = []
    var tiers: [MembershipTierInfo] = []
    var checkoutSession: PaymentCheckoutSession?
    var receipt: PaymentReceipt?
    var isLoading = false
    var isConfirmingPayment = false
    var errorMessage: String?

    init(
        apiClient: APIClientProtocol,
        analytics: AnalyticsServiceProtocol,
        payments: PaymentServiceProtocol
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
            async let tierList = apiClient.fetchMembershipTiers()
            membership = try await member
            exclusiveEvents = try await events
            tiers = try await tierList
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func prepareUpgrade(to tier: MembershipTier) async {
        do {
            checkoutSession = try await payments.prepareMembershipCheckout(tier: tier)
            receipt = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func confirmCheckout() async {
        guard let checkoutSession else { return }
        isConfirmingPayment = true
        do {
            receipt = try await apiClient.confirmPayment(
                PaymentConfirmDTO(sessionID: checkoutSession.id, tier: checkoutSession.tier)
            )
            if var membership {
                membership.tier = checkoutSession.tier
                self.membership = membership
            }
            HapticFeedback.success()
        } catch {
            errorMessage = error.localizedDescription
            HapticFeedback.warning()
        }
        isConfirmingPayment = false
    }
}
