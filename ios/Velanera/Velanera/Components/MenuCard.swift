import SwiftUI

/// Compact presentation of a menu item or chef recommendation.
struct MenuCard: View {
    let item: MenuItem
    var isFavourite: Bool = false
    var showsAllergens: Bool = true
    var onFavourite: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            GlassCard {
                HStack(alignment: .top, spacing: VelaneraSpacing.md) {
                    RoundedRectangle(cornerRadius: VelaneraSpacing.radiusSm, style: .continuous)
                        .fill(VelaneraColors.charcoal)
                        .frame(width: 72, height: 72)
                        .overlay {
                            Image(systemName: item.symbolName)
                                .foregroundStyle(VelaneraColors.softGold)
                        }

                    VStack(alignment: .leading, spacing: VelaneraSpacing.xxs) {
                        HStack {
                            Text(item.name)
                                .font(VelaneraTypography.headline(17))
                                .foregroundStyle(VelaneraColors.ivory)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 8)
                            Text(item.formattedPrice)
                                .font(VelaneraTypography.caption())
                                .foregroundStyle(VelaneraColors.gold)
                        }

                        Text(item.description)
                            .font(VelaneraTypography.caption())
                            .foregroundStyle(VelaneraColors.secondaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        if showsAllergens, !item.allergens.isEmpty {
                            Text(item.allergens.map(\.displayName).joined(separator: " · "))
                                .font(VelaneraTypography.label(10))
                                .foregroundStyle(VelaneraColors.tertiaryText)
                                .textCase(.uppercase)
                                .padding(.top, 2)
                        }
                    }

                    if let onFavourite {
                        Button {
                            onFavourite()
                        } label: {
                            Image(systemName: isFavourite ? "heart.fill" : "heart")
                                .foregroundStyle(VelaneraColors.gold)
                                .symbolEffect(.bounce, value: isFavourite)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}
