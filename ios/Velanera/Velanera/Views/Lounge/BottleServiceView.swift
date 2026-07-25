import SwiftUI

/// Bottle and spirits service menu.
struct BottleServiceView: View {
    @Environment(AppEnvironment.self) private var environment
    @Binding var selectedTab: AppTab
    @State private var bottles: [LoungeOffering] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                Text("Bottle Service")
                    .font(VelaneraTypography.title(32))
                    .foregroundStyle(VelaneraColors.ivory)
                Text("Champagne rituals and rare spirits, presented tableside.")
                    .font(VelaneraTypography.body(15))
                    .foregroundStyle(VelaneraColors.secondaryText)

                ForEach(bottles) { bottle in
                    NavigationLink(value: AppDestination.loungeOffering(bottle.id)) {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(bottle.name)
                                    .font(VelaneraTypography.headline(18))
                                    .foregroundStyle(VelaneraColors.ivory)
                                Text(bottle.summary)
                                    .font(VelaneraTypography.caption())
                                    .foregroundStyle(VelaneraColors.secondaryText)
                                Text(bottle.formattedStartingPrice)
                                    .font(VelaneraTypography.label(12))
                                    .foregroundStyle(VelaneraColors.gold)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }

                LuxuryButton(title: "Book Lounge", style: .secondary) {
                    selectedTab = .book
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Bottles")
        .task {
            let all = (try? await environment.apiClient.fetchLoungeOfferings()) ?? []
            bottles = all.filter { $0.kind == .bottleService }
        }
    }
}
