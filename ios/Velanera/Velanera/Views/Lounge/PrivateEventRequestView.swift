import SwiftUI

/// Private event briefing before handing into the booking engine.
struct PrivateEventRequestView: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                Text("Private Events")
                    .font(VelaneraTypography.title(34))
                    .foregroundStyle(VelaneraColors.ivory)
                Text("Bespoke evenings for twelve to sixty guests — dinners, celebrations, and discreet gatherings.")
                    .font(VelaneraTypography.body(16))
                    .foregroundStyle(VelaneraColors.secondaryText)

                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("The Library — up to 12", systemImage: "door.left.hand.open")
                        Label("Founders' Chamber — up to 20", systemImage: "crown")
                        Label("Full venue buyout on request", systemImage: "building.columns")
                    }
                    .font(VelaneraTypography.body(14))
                    .foregroundStyle(VelaneraColors.ivory)
                    .tint(VelaneraColors.gold)
                }

                Text("Unusual or highly bespoke requests are reviewed by our concierge team before confirmation.")
                    .font(VelaneraTypography.caption())
                    .foregroundStyle(VelaneraColors.secondaryText)

                LuxuryButton(title: "Start Private Request", systemImage: "calendar") {
                    selectedTab = .book
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Private Events")
    }
}
