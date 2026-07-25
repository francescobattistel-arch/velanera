import SwiftUI

/// Home composition: hero, featured dishes, events, hours, and location.
struct HomeView: View {
    @Environment(AppEnvironment.self) private var environment
    @Binding var selectedTab: AppTab
    @State private var viewModel: HomeViewModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.xl) {
                HeroMediaView(
                    primaryActionTitle: "Reserve Restaurant"
                ) {
                    selectedTab = .book
                }

                if viewModel == nil {
                    LoadingSkeletonList()
                        .pagePadding()
                } else {
                    feedContent
                }
            }
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("VELANERA")
                    .font(VelaneraTypography.label(13))
                    .tracking(4)
                    .foregroundStyle(VelaneraColors.gold)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = HomeViewModel(
                    apiClient: environment.apiClient,
                    analytics: environment.analyticsService
                )
            }
            await viewModel?.load()
        }
        .refreshable {
            await viewModel?.load()
        }
    }

    @ViewBuilder
    private var feedContent: some View {
        if viewModel?.isLoading == true && viewModel?.featuredDishes.isEmpty == true {
            LoadingSkeletonList()
                .pagePadding()
        } else if let error = viewModel?.errorMessage, viewModel?.featuredDishes.isEmpty == true {
            Text(error)
                .foregroundStyle(VelaneraColors.danger)
                .pagePadding()
        } else {
            section(title: "Featured Dishes", subtitle: "Signatures from the kitchen") {
                ForEach(viewModel?.featuredDishes ?? []) { item in
                    MenuCard(item: item)
                }
            }

            section(title: "Chef Specials", subtitle: "Seasonal compositions") {
                ForEach(viewModel?.chefSpecials ?? []) { item in
                    MenuCard(item: item)
                }
            }

            section(title: "Events", subtitle: "Evenings worth dressing for") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: VelaneraSpacing.md) {
                        ForEach(viewModel?.events ?? []) { event in
                            EventCard(event: event)
                                .frame(width: 260)
                        }
                    }
                }
            }

            VStack(spacing: VelaneraSpacing.sm) {
                LuxuryButton(title: "Reserve Restaurant", systemImage: "fork.knife") {
                    selectedTab = .book
                }
                LuxuryButton(title: "Reserve Lounge", style: .secondary, systemImage: "moon.stars") {
                    selectedTab = .lounge
                }
            }
            .pagePadding()
            .luxuryAppear(delay: 0.15)

            section(title: "Gallery", subtitle: "Moments from the house") {
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 10
                ) {
                    ForEach(viewModel?.gallerySymbols ?? [], id: \.self) { symbol in
                        RoundedRectangle(cornerRadius: VelaneraSpacing.radiusSm, style: .continuous)
                            .fill(VelaneraColors.elevated)
                            .frame(height: 96)
                            .overlay {
                                Image(systemName: symbol)
                                    .foregroundStyle(VelaneraColors.softGold.opacity(0.8))
                            }
                    }
                }
            }

            if let hours = viewModel?.hours {
                section(title: "Opening Hours", subtitle: hours.address) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(hours.days) { day in
                                HStack {
                                    Text(day.day)
                                        .foregroundStyle(VelaneraColors.ivory)
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("R \(day.restaurant)")
                                        Text("L \(day.lounge)")
                                    }
                                    .font(VelaneraTypography.caption())
                                    .foregroundStyle(VelaneraColors.secondaryText)
                                }
                                .font(VelaneraTypography.caption())
                            }
                            Divider().overlay(VelaneraColors.glassStroke)
                            Link(destination: mapURL(for: hours)) {
                                Label("Open in Maps", systemImage: "map")
                                    .font(VelaneraTypography.label(12))
                                    .foregroundStyle(VelaneraColors.gold)
                            }
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
        .luxuryAppear()
    }

    private func mapURL(for hours: OpeningHours) -> URL {
        let query = hours.mapQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Velanera"
        return URL(string: "http://maps.apple.com/?q=\(query)")!
    }
}
