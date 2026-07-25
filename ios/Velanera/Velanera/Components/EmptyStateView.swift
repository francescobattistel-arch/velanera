import SwiftUI

/// Reusable empty-state block for lists and archives.
struct EmptyStateView: View {
    let title: String
    var message: String = ""
    var systemImage: String = "sparkles"
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: VelaneraSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 36, weight: .ultraLight))
                .foregroundStyle(VelaneraColors.gold)
                .frame(width: DeviceLayout.minTouchTarget, height: DeviceLayout.minTouchTarget)

            Text(title)
                .font(VelaneraTypography.headlineScaled)
                .foregroundStyle(VelaneraColors.ivory)
                .multilineTextAlignment(.center)

            if !message.isEmpty {
                Text(message)
                    .font(VelaneraTypography.bodyScaled)
                    .foregroundStyle(VelaneraColors.secondaryText)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                LuxuryButton(title: actionTitle, style: .secondary, action: action)
                    .frame(maxWidth: 260)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, VelaneraSpacing.xl)
        .accessibilityElement(children: .combine)
    }
}
