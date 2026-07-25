import SwiftUI

/// Membership upgrade / checkout confirmation surface.
struct MembershipUpgradeView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var viewModel: MembershipViewModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                Text("Upgrade")
                    .font(VelaneraTypography.title(32))
                    .foregroundStyle(VelaneraColors.ivory)
                Text("Choose a tier. Payment is mocked until StoreKit is connected.")
                    .font(VelaneraTypography.body(15))
                    .foregroundStyle(VelaneraColors.secondaryText)

                ForEach(viewModel?.tiers ?? []) { tier in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(tier.tier.displayName)
                                    .font(VelaneraTypography.headline(20))
                                    .foregroundStyle(VelaneraColors.ivory)
                                Spacer()
                                Text(tier.annualFee.formatted(.currency(code: "GBP")) + " / yr")
                                    .font(VelaneraTypography.caption())
                                    .foregroundStyle(VelaneraColors.gold)
                            }
                            Text(tier.tagline)
                                .font(VelaneraTypography.caption())
                                .foregroundStyle(VelaneraColors.secondaryText)
                            LuxuryButton(title: "Select \(tier.tier.displayName)", style: .secondary) {
                                Task { await viewModel?.prepareUpgrade(to: tier.tier) }
                            }
                        }
                    }
                }

                if let session = viewModel?.checkoutSession {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Checkout ready")
                                .font(VelaneraTypography.headline(18))
                                .foregroundStyle(VelaneraColors.champagne)
                            Text("\(session.tier.displayName) · \(session.amount.formatted(.currency(code: session.currencyCode)))")
                                .font(VelaneraTypography.caption())
                                .foregroundStyle(VelaneraColors.secondaryText)
                            LuxuryButton(
                                title: "Confirm Payment",
                                isLoading: viewModel?.isConfirmingPayment == true,
                                systemImage: "creditcard"
                            ) {
                                Task { await viewModel?.confirmCheckout() }
                            }
                        }
                    }
                    .goldShimmer()
                }

                if let receipt = viewModel?.receipt {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Payment confirmed")
                                .font(VelaneraTypography.headline(18))
                                .foregroundStyle(VelaneraColors.success)
                            Text("Receipt \(receipt.id.prefix(8).uppercased()) · \(receipt.tier.displayName)")
                                .font(VelaneraTypography.caption())
                                .foregroundStyle(VelaneraColors.secondaryText)
                        }
                    }
                    .luxuryAppear()
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Upgrade")
        .task {
            if viewModel == nil {
                viewModel = MembershipViewModel(
                    apiClient: environment.apiClient,
                    analytics: environment.analyticsService,
                    payments: environment.paymentService
                )
            }
            await viewModel?.load()
        }
    }
}
