import SwiftUI

/// Chef narrative and tasting menu.
struct ChefView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var chef: ChefProfile?
    @State private var signatures: [MenuItem] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                if let chef {
                    Text(chef.name)
                        .font(VelaneraTypography.title(34))
                        .foregroundStyle(VelaneraColors.ivory)
                    Text(chef.title.uppercased())
                        .font(VelaneraTypography.label(12))
                        .foregroundStyle(VelaneraColors.gold)
                        .tracking(2)

                    Text(chef.biography)
                        .font(VelaneraTypography.body(16))
                        .foregroundStyle(VelaneraColors.secondaryText)

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Philosophy")
                                .font(VelaneraTypography.label(12))
                                .foregroundStyle(VelaneraColors.gold)
                            Text(chef.philosophy)
                                .font(VelaneraTypography.body(15))
                                .foregroundStyle(VelaneraColors.ivory)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Tasting Menu")
                                .font(VelaneraTypography.headline(18))
                                .foregroundStyle(VelaneraColors.ivory)
                            Text(chef.tastingMenuSummary)
                                .font(VelaneraTypography.caption())
                                .foregroundStyle(VelaneraColors.secondaryText)
                            Text(chef.formattedTastingPrice)
                                .font(VelaneraTypography.label(13))
                                .foregroundStyle(VelaneraColors.gold)
                        }
                    }

                    SectionHeader(title: "Signatures", subtitle: "From the pass")
                    ForEach(signatures) { item in
                        NavigationLink(value: AppDestination.menuItem(item.id)) {
                            MenuCard(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    LoadingSkeletonList()
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("The Chef")
        .task {
            chef = try? await environment.apiClient.fetchChef()
            let menu = (try? await environment.apiClient.fetchMenu()) ?? []
            if let chef {
                signatures = menu.filter { chef.signatureDishIDs.contains($0.id) }
                if signatures.isEmpty {
                    signatures = menu.filter(\.isChefRecommendation)
                }
            }
        }
    }
}
