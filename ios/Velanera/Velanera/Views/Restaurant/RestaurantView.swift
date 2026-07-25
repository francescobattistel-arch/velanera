import SwiftUI
import SwiftData

/// Digital menu with wine, cocktails, desserts, and allergen detail.
struct RestaurantView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: RestaurantViewModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                header
                categoryPicker

                if viewModel?.isLoading == true && viewModel?.items.isEmpty == true {
                    LoadingSkeletonList()
                } else {
                    if !(viewModel?.chefRecommendations.isEmpty ?? true),
                       viewModel?.selectedCategory != .chefSpecials {
                        SectionHeader(title: "Chef Recommendations", subtitle: "Guided selections")
                        ForEach(Array((viewModel?.chefRecommendations ?? []).prefix(2))) { item in
                            MenuCard(item: item) {
                                viewModel?.toggleFavourite(item, modelContext: modelContext)
                            }
                        }
                    }

                    SectionHeader(
                        title: viewModel?.selectedCategory.displayName ?? "Menu",
                        subtitle: "Allergen information shown per dish"
                    )
                    ForEach(viewModel?.filteredItems ?? []) { item in
                        MenuCard(item: item) {
                            viewModel?.toggleFavourite(item, modelContext: modelContext)
                        }
                    }
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Restaurant")
        .navigationBarTitleDisplayMode(.large)
        .task {
            if viewModel == nil {
                viewModel = RestaurantViewModel(apiClient: environment.apiClient)
            }
            await viewModel?.load()
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
                                ? VelaneraColors.matteBlack
                                : VelaneraColors.champagne
                            )
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(
                                    viewModel?.selectedCategory == category
                                    ? VelaneraColors.gold
                                    : VelaneraColors.elevated
                                )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
