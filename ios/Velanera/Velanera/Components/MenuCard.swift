import SwiftUI

/// Compact presentation of a menu item or chef recommendation.
struct MenuCard: View {
    let item: MenuItem
    var showsAllergens: Bool = true
    var onFavourite: (() -> Void)? = nil

    var body: some View {
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
                        Spacer()
                        Text(item.formattedPrice)
                            .font(VelaneraTypography.caption())
                            .foregroundStyle(VelaneraColors.gold)
                    }

                    Text(item.description)
                        .font(VelaneraTypography.caption())
                        .foregroundStyle(VelaneraColors.secondaryText)
                        .lineLimit(2)

                    if showsAllergens, !item.allergens.isEmpty {
                        Text(item.allergens.map(\.rawValue).joined(separator: " · "))
                            .font(VelaneraTypography.label(10))
                            .foregroundStyle(VelaneraColors.tertiaryText)
                            .textCase(.uppercase)
                            .padding(.top, 2)
                    }
                }

                if let onFavourite {
                    Button(action: onFavourite) {
                        Image(systemName: "heart")
                            .foregroundStyle(VelaneraColors.gold)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
