import SwiftUI

/// Allergen legend and filtering guidance.
struct AllergenGuideView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var selected: Set<Allergen> = []
    @State private var matching: [MenuItem] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                Text("Allergen Guide")
                    .font(VelaneraTypography.title(32))
                    .foregroundStyle(VelaneraColors.ivory)
                Text("Select allergens to exclude. We’ll show dishes that avoid them.")
                    .font(VelaneraTypography.body(15))
                    .foregroundStyle(VelaneraColors.secondaryText)

                ForEach(Allergen.allCases) { allergen in
                    Button {
                        if selected.contains(allergen) {
                            selected.remove(allergen)
                        } else {
                            selected.insert(allergen)
                        }
                        Task { await refresh() }
                    } label: {
                        GlassCard {
                            HStack(spacing: VelaneraSpacing.md) {
                                Image(systemName: allergen.symbolName)
                                    .foregroundStyle(VelaneraColors.gold)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(allergen.displayName)
                                        .font(VelaneraTypography.headline(16))
                                        .foregroundStyle(VelaneraColors.ivory)
                                    Text(allergen.guidance)
                                        .font(VelaneraTypography.caption())
                                        .foregroundStyle(VelaneraColors.secondaryText)
                                }
                                Spacer()
                                Image(systemName: selected.contains(allergen) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(VelaneraColors.gold)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }

                if !selected.isEmpty {
                    SectionHeader(title: "Suitable dishes", subtitle: "Excluding selected allergens")
                    ForEach(matching) { item in
                        NavigationLink(value: AppDestination.menuItem(item.id)) {
                            MenuCard(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Allergens")
    }

    private func refresh() async {
        let menu = (try? await environment.apiClient.fetchMenu()) ?? []
        matching = menu.filter { selected.isDisjoint(with: Set($0.allergens)) }
    }
}
