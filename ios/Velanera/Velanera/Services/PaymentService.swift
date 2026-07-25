import Foundation

/// Future StoreKit / payment-provider integration for deposits and membership billing.
public protocol PaymentServiceProtocol: Sendable {
    func prepareMembershipCheckout(tier: MembershipTier) async throws -> PaymentCheckoutSession
}

public struct PaymentCheckoutSession: Sendable {
    public let id: String
    public let tier: MembershipTier
    public let amount: Decimal
    public let currencyCode: String
}

/// Scaffolded payment service — no charges are processed in this release.
public final class PaymentService: PaymentServiceProtocol, @unchecked Sendable {
    public init() {}

    public func prepareMembershipCheckout(tier: MembershipTier) async throws -> PaymentCheckoutSession {
        let amount: Decimal = switch tier {
        case .guest: 0
        case .house: 250
        case .black: 750
        case .founder: 2000
        }
        return PaymentCheckoutSession(
            id: UUID().uuidString,
            tier: tier,
            amount: amount,
            currencyCode: "GBP"
        )
    }
}
