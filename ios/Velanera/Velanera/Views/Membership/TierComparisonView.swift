import SwiftUI

/// Side-by-side membership tier comparison.
struct TierComparisonView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var tiers: [MembershipTierInfo] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                Text("Compare Tiers")
                    .font(VelaneraTypography.title(32))
                    .foregroundStyle(VelaneraColors.ivory)

                ForEach(tiers) { tier in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(tier.tier.displayName)
                                .font(VelaneraTypography.headline(20))
                                .foregroundStyle(VelaneraColors.ivory)
                            Text(tier.annualFee.formatted(.currency(code: "GBP")) + " annually")
                                .font(VelaneraTypography.label(12))
                                .foregroundStyle(VelaneraColors.gold)
                            ForEach(tier.benefits, id: \.self) { benefit in
                                Label(benefit, systemImage: "checkmark")
                                    .font(VelaneraTypography.caption())
                                    .foregroundStyle(VelaneraColors.secondaryText)
                                    .tint(VelaneraColors.gold)
                            }
                        }
                    }
                }

                NavigationLink(value: AppDestination.membershipUpgrade) {
                    Text("Continue to Upgrade")
                        .font(VelaneraTypography.label(14))
                        .tracking(1.2)
                        .textCase(.uppercase)
                        .foregroundStyle(VelaneraColors.matteBlack)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, VelaneraSpacing.md)
                        .background(
                            LinearGradient(
                                colors: [VelaneraColors.champagne, VelaneraColors.gold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: VelaneraSpacing.radiusSm, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Tiers")
        .task {
            tiers = (try? await environment.apiClient.fetchMembershipTiers()) ?? []
        }
    }
}
