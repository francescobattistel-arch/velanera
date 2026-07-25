import SwiftUI

/// Dedicated wine list with region, vintage, and pairing.
struct WineListView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var wines: [MenuItem] = []
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                Text("Wine List")
                    .font(VelaneraTypography.title(32))
                    .foregroundStyle(VelaneraColors.ivory)
                Text("A precise cellar — Burgundy, Piedmont, Champagne, and Loire.")
                    .font(VelaneraTypography.body(15))
                    .foregroundStyle(VelaneraColors.secondaryText)

                if isLoading {
                    LoadingSkeletonList()
                } else {
                    ForEach(wines) { wine in
                        NavigationLink(value: AppDestination.menuItem(wine.id)) {
                            GlassCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(wine.name)
                                            .font(VelaneraTypography.headline(18))
                                            .foregroundStyle(VelaneraColors.ivory)
                                        Spacer()
                                        Text(wine.formattedPrice)
                                            .foregroundStyle(VelaneraColors.gold)
                                    }
                                    if let region = wine.wineRegion, let vintage = wine.wineVintage {
                                        Text("\(region) · \(vintage)")
                                            .font(VelaneraTypography.caption())
                                            .foregroundStyle(VelaneraColors.secondaryText)
                                    }
                                    if let pairing = wine.pairingNote {
                                        Text(pairing)
                                            .font(VelaneraTypography.caption())
                                            .foregroundStyle(VelaneraColors.champagne)
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Wine")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            wines = (try? await environment.apiClient.fetchMenu())?.filter(\.isWine) ?? []
            isLoading = false
        }
    }
}
