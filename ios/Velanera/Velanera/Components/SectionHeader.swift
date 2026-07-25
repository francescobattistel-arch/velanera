import SwiftUI

/// Section title with optional supporting line and trailing action.
struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: VelaneraSpacing.xxs) {
                Text(title)
                    .font(VelaneraTypography.headline(22))
                    .foregroundStyle(VelaneraColors.ivory)
                if let subtitle {
                    Text(subtitle)
                        .font(VelaneraTypography.caption())
                        .foregroundStyle(VelaneraColors.secondaryText)
                }
            }
            Spacer(minLength: VelaneraSpacing.md)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(VelaneraTypography.label(12))
                    .foregroundStyle(VelaneraColors.gold)
                    .textCase(.uppercase)
                    .tracking(1)
            }
        }
    }
}
