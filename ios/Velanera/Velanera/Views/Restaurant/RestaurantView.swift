import SwiftUI
import SwiftData

/// Digital menu with wine, cocktails, desserts, chef, and allergen tools.
struct RestaurantView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: AppTab = .restaurant
    @State private var viewModel: RestaurantViewModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                header
                quickLinks
                searchField
                categoryPicker

                if viewModel?.isLoading == true && viewModel?.items.isEmpty == true {
                    LoadingSkeletonList()
                } else {
                    if !(viewModel?.chefRecommendations.isEmpty ?? true),
                       viewModel?.selectedCategory != .chefSpecials {
                        SectionHeader(title: "Chef Recommendations", subtitle: "Guided selections")
                        ForEach(Array((viewModel?.chefRecommendations ?? []).prefix(2))) { item in
                            menuLink(item)
                        }
                    }

                    SectionHeader(
                        title: viewModel?.selectedCategory.displayName ?? "Menu",
                        subtitle: "Allergen information shown per dish"
                    )
                    ForEach(viewModel?.filteredItems ?? []) { item in
                        menuLink(item)
                    }
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Restaurant")
        .navigationBarTitleDisplayMode(.large)
        .velaneraRouter(selectedTab: $selectedTab)
        .task {
            if viewModel == nil {
                viewModel = RestaurantViewModel(apiClient: environment.apiClient)
            }
            await viewModel?.load(modelContext: modelContext)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: VelaneraSpacing.xs) {
            Text("The Menu")
                .font(VelaneraTypography.title(32))
                .foregroundStyle(VelaneraColors.ivory)
            Text("Mediterranean compositions, precise wine, and evening cocktails.")
                .font(VelaneraTypography.body(15))
                .foregroundStyle(VelaneraColors.secondaryText)
        }
        .luxuryAppear()
    }

    private var quickLinks: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                navChip("Wine", destination: .wineList)
                navChip("Cocktails", destination: .cocktails)
                navChip("Desserts", destination: .desserts)
                navChip("Chef", destination: .chef)
                navChip("Allergens", destination: .allergenGuide)
            }
        }
    }

    private var searchField: some View {
        TextField(
            "Search the menu",
            text: Binding(
                get: { viewModel?.searchText ?? "" },
                set: { viewModel?.searchText = $0 }
            )
        )
        .padding()
        .glassBackground(cornerRadius: VelaneraSpacing.radiusSm)
        .foregroundStyle(VelaneraColors.ivory)
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: VelaneraSpacing.xs) {
                ForEach(MenuItem.Category.allCases, id: \.self) { category in
                    Button {
                        withAnimation(VelaneraTheme.animationSmooth) {
                            viewModel?.selectedCategory = category
                        }
                    } label: {
                        Text(category.displayName)
                            .font(VelaneraTypography.label(11))
                            .tracking(0.8)
                            .foregroundStyle(
                                viewModel?.selectedCategory == category
                                ? VelaneraColors.matteBlack : VelaneraColors.champagne
                            )
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(
                                    viewModel?.selectedCategory == category
                                    ? VelaneraColors.gold : VelaneraColors.elevated
                                )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func menuLink(_ item: MenuItem) -> some View {
        NavigationLink(value: AppDestination.menuItem(item.id)) {
            MenuCard(
                item: item,
                isFavourite: viewModel?.isFavourite(item) == true,
                onFavourite: {
                    viewModel?.toggleFavourite(item, modelContext: modelContext)
                }
            )
        }
        .buttonStyle(.plain)
    }

    private func navChip(_ title: String, destination: AppDestination) -> some View {
        NavigationLink(value: destination) {
            Text(title)
                .font(VelaneraTypography.label(11))
                .foregroundStyle(VelaneraColors.champagne)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(VelaneraColors.elevated)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
