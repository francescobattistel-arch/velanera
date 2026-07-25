import SwiftUI

/// Signature cocktail list.
struct CocktailListView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var cocktails: [MenuItem] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                Text("Cocktails")
                    .font(VelaneraTypography.title(32))
                    .foregroundStyle(VelaneraColors.ivory)
                Text("House signatures for the dining room and after dark.")
                    .font(VelaneraTypography.body(15))
                    .foregroundStyle(VelaneraColors.secondaryText)

                ForEach(cocktails) { drink in
                    NavigationLink(value: AppDestination.menuItem(drink.id)) {
                        MenuCard(item: drink)
                    }
                    .buttonStyle(.plain)
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Cocktails")
        .task {
            cocktails = (try? await environment.apiClient.fetchMenu())?.filter(\.isCocktail) ?? []
        }
    }
}
