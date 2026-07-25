import SwiftUI

/// Primary and secondary luxury call-to-action button.
struct LuxuryButton: View {
    enum Style {
        case primary
        case secondary
        case ghost
    }

    let title: String
    var style: Style = .primary
    var isLoading: Bool = false
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticFeedback.light()
            action()
        }) {
            HStack(spacing: VelaneraSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(foreground)
                } else {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    Text(title)
                        .font(VelaneraTypography.label(14))
                        .tracking(1.2)
                        .textCase(.uppercase)
                }
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, VelaneraSpacing.md)
            .padding(.horizontal, VelaneraSpacing.lg)
            .background(background)
            .overlay {
                RoundedRectangle(cornerRadius: VelaneraSpacing.radiusSm, style: .continuous)
                    .strokeBorder(border, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: VelaneraSpacing.radiusSm, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1)
    }

    private var foreground: Color {
        switch style {
        case .primary: VelaneraColors.matteBlack
        case .secondary, .ghost: VelaneraColors.champagne
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .primary:
            LinearGradient(
                colors: [VelaneraColors.champagne, VelaneraColors.gold],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            VelaneraColors.elevated
        case .ghost:
            Color.clear
        }
    }

    private var border: Color {
        switch style {
        case .primary: Color.clear
        case .secondary: VelaneraColors.goldStroke
        case .ghost: VelaneraColors.glassStroke
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        LuxuryButton(title: "Reserve", systemImage: "calendar") {}
        LuxuryButton(title: "Explore", style: .secondary) {}
        LuxuryButton(title: "Learn More", style: .ghost) {}
    }
    .padding()
    .background(VelaneraColors.matteBlack)
}
