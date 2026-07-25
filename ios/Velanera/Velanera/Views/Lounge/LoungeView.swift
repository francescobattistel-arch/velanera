import SwiftUI

/// VIP tables, private areas, bottle service, DJs, and gallery.
struct LoungeView: View {
    @Environment(AppEnvironment.self) private var environment
    @Binding var selectedTab: AppTab
    @State private var viewModel: LoungeViewModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.xl) {
                hero

                if viewModel?.isLoading == true && viewModel?.offerings.isEmpty == true {
                    LoadingSkeletonList()
                        .pagePadding()
                } else {
                    ForEach(LoungeOffering.Kind.allCases, id: \.self) { kind in
                        offeringSection(kind: kind, items: viewModel?.offerings(for: kind) ?? [])
                    }

                    section(title: "Upcoming DJs", subtitle: "Late energy, curated") {
                        ForEach(viewModel?.upcomingDJs ?? []) { event in
                            EventCard(event: event)
                        }
                    }

                    section(title: "Private Events", subtitle: "Host with discretion") {
                        GlassCard {
                            VStack(alignment: .leading, spacing: VelaneraSpacing.md) {
                                Text("Bespoke evenings for twelve to sixty guests.")
                                    .font(VelaneraTypography.body(15))
                                    .foregroundStyle(VelaneraColors.secondaryText)
                                LuxuryButton(title: "Request Private Event", systemImage: "envelope") {
                                    selectedTab = .book
                                }
                            }
                        }
                    }

                    section(title: "Gallery", subtitle: "After dark") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(["sparkles", "music.note", "wineglass.fill", "sofa.fill"], id: \.self) { symbol in
                                RoundedRectangle(cornerRadius: VelaneraSpacing.radiusMd, style: .continuous)
                                    .fill(VelaneraColors.elevated)
                                    .frame(height: 140)
                                    .overlay {
                                        Image(systemName: symbol)
                                            .font(.title)
                                            .foregroundStyle(VelaneraColors.gold.opacity(0.7))
                                    }
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Lounge")
        .task {
            if viewModel == nil {
                viewModel = LoungeViewModel(apiClient: environment.apiClient)
            }
            await viewModel?.load()
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color(hex: 0x241C14), VelaneraColors.matteBlack],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 280)
            .overlay {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 64, weight: .ultraLight))
                    .foregroundStyle(VelaneraColors.gold.opacity(0.35))
                    .offset(x: 80, y: -30)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("After Dark")
                    .font(VelaneraTypography.title(34))
                    .foregroundStyle(VelaneraColors.ivory)
                Text("VIP tables, private rooms, and bottle service.")
                    .font(VelaneraTypography.body(15))
                    .foregroundStyle(VelaneraColors.secondaryText)
            }
            .pagePadding()
            .padding(.bottom, VelaneraSpacing.lg)
        }
    }

    private func offeringSection(kind: LoungeOffering.Kind, items: [LoungeOffering]) -> some View {
        section(title: kind.displayName, subtitle: "From the lounge book") {
            ForEach(items) { offering in
                GlassCard {
                    HStack(alignment: .top, spacing: VelaneraSpacing.md) {
                        Image(systemName: kind.symbolName)
                            .foregroundStyle(VelaneraColors.gold)
                            .frame(width: 36, height: 36)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(offering.name)
                                .font(VelaneraTypography.headline(17))
                                .foregroundStyle(VelaneraColors.ivory)
                            Text(offering.summary)
                                .font(VelaneraTypography.caption())
                                .foregroundStyle(VelaneraColors.secondaryText)
                            HStack {
                                Text(offering.formattedStartingPrice)
                                    .foregroundStyle(VelaneraColors.gold)
                                Spacer()
                                Text("Up to \(offering.capacity)")
                                    .foregroundStyle(VelaneraColors.tertiaryText)
                            }
                            .font(VelaneraTypography.label(11))
                        }
                    }
                }
            }
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
        .pagePadding()
    }
}
