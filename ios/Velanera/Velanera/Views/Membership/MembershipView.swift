import SwiftUI

/// Digital membership wallet, loyalty, benefits, and exclusive events.
struct MembershipView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var viewModel: MembershipViewModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.xl) {
                Text("Membership")
                    .font(VelaneraTypography.title(34))
                    .foregroundStyle(VelaneraColors.ivory)

                Text("A quieter key to Velanera — priority, loyalty, and evenings reserved for members.")
                    .font(VelaneraTypography.body(15))
                    .foregroundStyle(VelaneraColors.secondaryText)

                if viewModel?.isLoading == true && viewModel?.membership == nil {
                    LoadingSkeleton(height: 200)
                } else if let membership = viewModel?.membership {
                    MembershipCard(membership: membership)
                        .luxuryAppear()

                    section(title: "VIP Status", subtitle: membership.tier.displayName) {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(membership.loyaltyPoints.formatted()) loyalty points")
                                    .font(VelaneraTypography.headline(18))
                                    .foregroundStyle(VelaneraColors.champagne)
                                Text("Present your QR at arrival for recognition.")
                                    .font(VelaneraTypography.caption())
                                    .foregroundStyle(VelaneraColors.secondaryText)
                            }
                        }
                    }

                    section(title: "Benefits", subtitle: "Included with \(membership.tier.displayName)") {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(membership.tier.benefits, id: \.self) { benefit in
                                    Label(benefit, systemImage: "checkmark")
                                        .font(VelaneraTypography.body(14))
                                        .foregroundStyle(VelaneraColors.ivory)
                                        .symbolRenderingMode(.hierarchical)
                                        .tint(VelaneraColors.gold)
                                }
                            }
                        }
                    }

                    section(title: "Exclusive Events", subtitle: "Members first") {
                        if viewModel?.exclusiveEvents.isEmpty == true {
                            Text("No exclusive evenings scheduled.")
                                .foregroundStyle(VelaneraColors.secondaryText)
                        } else {
                            ForEach(viewModel?.exclusiveEvents ?? []) { event in
                                EventCard(event: event)
                            }
                        }
                    }

                    if let session = viewModel?.checkoutSession {
                        GlassCard {
                            Text("Checkout ready: \(session.tier.displayName) · \(session.amount.formatted(.currency(code: session.currencyCode)))")
                                .font(VelaneraTypography.caption())
                                .foregroundStyle(VelaneraColors.gold)
                        }
                    }

                    LuxuryButton(title: "Explore Black Tier", style: .secondary, systemImage: "crown") {
                        Task { await viewModel?.prepareUpgrade(to: .black) }
                    }
                } else if let error = viewModel?.errorMessage {
                    Text(error).foregroundStyle(VelaneraColors.danger)
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Membership")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                viewModel = MembershipViewModel(
                    apiClient: environment.apiClient,
                    analytics: environment.analyticsService
                )
            }
            await viewModel?.load()
        }
    }

    private func section<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: VelaneraSpacing.md) {
            SectionHeader(title: title, subtitle: subtitle)
            content()
        }
    }
}
