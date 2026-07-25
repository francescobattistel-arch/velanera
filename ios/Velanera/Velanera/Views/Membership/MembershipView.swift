import SwiftUI

/// Digital membership wallet, loyalty, benefits, and exclusive events.
struct MembershipView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var selectedTab: AppTab = .membership
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

                HStack(spacing: 8) {
                    NavigationLink(value: AppDestination.tierComparison) {
                        chip("Compare tiers")
                    }
                    NavigationLink(value: AppDestination.membershipUpgrade) {
                        chip("Upgrade")
                    }
                }

                if viewModel?.isLoading == true && viewModel?.membership == nil {
                    LoadingSkeleton(height: 200)
                } else if let membership = viewModel?.membership {
                    MembershipCard(membership: membership)
                        .luxuryAppear()
                        .goldShimmer(isActive: membership.tier == .black || membership.tier == .founder)

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
                                NavigationLink(value: AppDestination.eventDetail(event.id)) {
                                    EventCard(event: event)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    NavigationLink(value: AppDestination.membershipUpgrade) {
                        Text("Explore Black Tier")
                            .font(VelaneraTypography.label(14))
                            .tracking(1.2)
                            .textCase(.uppercase)
                            .foregroundStyle(VelaneraColors.champagne)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, VelaneraSpacing.md)
                            .background(VelaneraColors.elevated)
                            .overlay {
                                RoundedRectangle(cornerRadius: VelaneraSpacing.radiusSm, style: .continuous)
                                    .strokeBorder(VelaneraColors.goldStroke, lineWidth: 1)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: VelaneraSpacing.radiusSm, style: .continuous))
                    }
                    .buttonStyle(.plain)
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
        .velaneraRouter(selectedTab: $selectedTab)
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

    private func chip(_ title: String) -> some View {
        Text(title)
            .font(VelaneraTypography.label(11))
            .foregroundStyle(VelaneraColors.champagne)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(VelaneraColors.elevated)
            .clipShape(Capsule())
    }
}
