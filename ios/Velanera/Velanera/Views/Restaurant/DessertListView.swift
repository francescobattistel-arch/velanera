import SwiftUI

/// Dessert collection.
struct DessertListView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var desserts: [MenuItem] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                Text("Desserts")
                    .font(VelaneraTypography.title(32))
                    .foregroundStyle(VelaneraColors.ivory)

                ForEach(desserts) { dessert in
                    NavigationLink(value: AppDestination.menuItem(dessert.id)) {
                        MenuCard(item: dessert)
                    }
                    .buttonStyle(.plain)
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Desserts")
        .task {
            desserts = (try? await environment.apiClient.fetchMenu())?.filter { $0.category == .desserts } ?? []
        }
    }
}
