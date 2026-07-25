import SwiftUI
import SwiftData

/// Full dish / wine / cocktail detail with allergens and favourite action.
struct MenuItemDetailView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.modelContext) private var modelContext
    let itemID: UUID

    @State private var item: MenuItem?
    @State private var isFavourite = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                if let item {
                    hero(item)
                    Text(item.longDescription)
                        .font(VelaneraTypography.body(16))
                        .foregroundStyle(VelaneraColors.secondaryText)
                        .luxuryAppear()

                    if let pairing = item.pairingNote {
                        metaRow(title: "Pairing", value: pairing)
                    }
                    if item.isWine {
                        if let region = item.wineRegion { metaRow(title: "Region", value: region) }
                        if let grape = item.wineGrape { metaRow(title: "Grape", value: grape) }
                        if let vintage = item.wineVintage { metaRow(title: "Vintage", value: vintage) }
                    }
                    if let abv = item.abv { metaRow(title: "ABV", value: abv) }

                    if !item.allergens.isEmpty {
                        SectionHeader(title: "Allergens", subtitle: "Please advise your host of any allergies")
                        FlowAllergenChips(allergens: item.allergens)
                    }

                    if !item.dietaryTags.isEmpty {
                        Text(item.dietaryTags.joined(separator: " · "))
                            .font(VelaneraTypography.label(11))
                            .foregroundStyle(VelaneraColors.gold)
                            .tracking(1)
                    }

                    LuxuryButton(
                        title: isFavourite ? "Saved to Favourites" : "Save Favourite",
                        style: isFavourite ? .secondary : .primary,
                        systemImage: isFavourite ? "heart.fill" : "heart"
                    ) {
                        toggleFavourite(item)
                    }
                } else if let errorMessage {
                    Text(errorMessage).foregroundStyle(VelaneraColors.danger)
                } else {
                    LoadingSkeleton(height: 280)
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle(item?.name ?? "Details")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func hero(_ item: MenuItem) -> some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: VelaneraSpacing.radiusLg, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x2A2318), VelaneraColors.nearBlack],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                )
                .frame(height: 240)
                .overlay {
                    Image(systemName: item.symbolName)
                        .font(.system(size: 56, weight: .ultraLight))
                        .foregroundStyle(VelaneraColors.gold.opacity(0.55))
                }
                .luxuryHeroChrome()

            VStack(alignment: .leading, spacing: 6) {
                Text(item.category.displayName.uppercased())
                    .font(VelaneraTypography.label(11))
                    .foregroundStyle(VelaneraColors.gold)
                    .tracking(2)
                Text(item.name)
                    .font(VelaneraTypography.title(28))
                    .foregroundStyle(VelaneraColors.ivory)
                Text(item.formattedPrice)
                    .font(VelaneraTypography.headline(18))
                    .foregroundStyle(VelaneraColors.champagne)
            }
            .padding(VelaneraSpacing.lg)
        }
        .luxuryAppear()
    }

    private func metaRow(title: String, value: String) -> some View {
        GlassCard {
            HStack {
                Text(title)
                    .font(VelaneraTypography.label(12))
                    .foregroundStyle(VelaneraColors.gold)
                Spacer()
                Text(value)
                    .font(VelaneraTypography.body(14))
                    .foregroundStyle(VelaneraColors.ivory)
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    private func load() async {
        do {
            item = try await environment.apiClient.fetchMenuItem(id: itemID)
            let descriptor = FetchDescriptor<FavouriteDish>(
                predicate: #Predicate { $0.dishID == itemID }
            )
            isFavourite = ((try? modelContext.fetch(descriptor))?.isEmpty == false)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func toggleFavourite(_ item: MenuItem) {
        let descriptor = FetchDescriptor<FavouriteDish>(
            predicate: #Predicate { $0.dishID == itemID }
        )
        if let existing = try? modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
            isFavourite = false
        } else {
            modelContext.insert(FavouriteDish(dishID: item.id, name: item.name))
            isFavourite = true
        }
        HapticFeedback.light()
    }
}

struct FlowAllergenChips: View {
    let allergens: [Allergen]

    var body: some View {
        FlexibleChipWrap(items: allergens) { allergen in
            Label(allergen.displayName, systemImage: allergen.symbolName)
                .font(VelaneraTypography.label(11))
                .foregroundStyle(VelaneraColors.champagne)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(VelaneraColors.elevated)
                .clipShape(Capsule())
        }
    }
}

/// Simple wrapping layout for chips without external dependencies.
struct FlexibleChipWrap<Item: Identifiable, Content: View>: View {
    let items: [Item]
    @ViewBuilder var content: (Item) -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(items.chunked(into: 3).enumerated()), id: \.offset) { _, row in
                HStack(spacing: 8) {
                    ForEach(row) { item in
                        content(item)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
