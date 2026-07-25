import SwiftUI

/// Detail for VIP table, private area, or bottle offering.
struct LoungeOfferingDetailView: View {
    @Environment(AppEnvironment.self) private var environment
    @Binding var selectedTab: AppTab
    let offeringID: UUID

    @State private var offering: LoungeOffering?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                if let offering {
                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: VelaneraSpacing.radiusLg, style: .continuous)
                            .fill(LinearGradient(
                                colors: [Color(hex: 0x241C14), VelaneraColors.matteBlack],
                                startPoint: .top, endPoint: .bottom
                            ))
                            .frame(height: 220)
                            .overlay {
                                Image(systemName: offering.symbolName)
                                    .font(.system(size: 48, weight: .ultraLight))
                                    .foregroundStyle(VelaneraColors.gold.opacity(0.5))
                            }

                        VStack(alignment: .leading, spacing: 6) {
                            Text(offering.kind.displayName.uppercased())
                                .font(VelaneraTypography.label(11))
                                .foregroundStyle(VelaneraColors.gold)
                                .tracking(2)
                            Text(offering.name)
                                .font(VelaneraTypography.title(28))
                                .foregroundStyle(VelaneraColors.ivory)
                        }
                        .padding(VelaneraSpacing.lg)
                    }

                    Text(offering.detail)
                        .font(VelaneraTypography.body(16))
                        .foregroundStyle(VelaneraColors.secondaryText)

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(offering.formattedStartingPrice)
                                .font(VelaneraTypography.headline(18))
                                .foregroundStyle(VelaneraColors.champagne)
                            Text("Capacity · \(offering.capacity) guests")
                                .font(VelaneraTypography.caption())
                                .foregroundStyle(VelaneraColors.secondaryText)
                            if let minimum = offering.minimumSpend {
                                Text("Minimum spend · \(minimum.formatted(.currency(code: "GBP")))")
                                    .font(VelaneraTypography.caption())
                                    .foregroundStyle(VelaneraColors.tertiaryText)
                            }
                        }
                    }

                    if !offering.includes.isEmpty {
                        SectionHeader(title: "Includes", subtitle: "What to expect")
                        ForEach(offering.includes, id: \.self) { line in
                            Label(line, systemImage: "checkmark")
                                .font(VelaneraTypography.body(14))
                                .foregroundStyle(VelaneraColors.ivory)
                                .tint(VelaneraColors.gold)
                        }
                    }

                    LuxuryButton(title: "Reserve This Experience", systemImage: "calendar") {
                        selectedTab = .book
                    }
                } else {
                    LoadingSkeleton(height: 280)
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Lounge")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            offering = try? await environment.apiClient.fetchLoungeOffering(id: offeringID)
        }
    }
}
