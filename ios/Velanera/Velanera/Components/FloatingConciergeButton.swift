import SwiftUI

/// Floating action that opens the AI Concierge voice experience.
struct FloatingConciergeButton: View {
    let action: () -> Void
    @State private var glow = false

    var body: some View {
        Button(action: {
            HapticFeedback.medium()
            action()
        }) {
            HStack(spacing: VelaneraSpacing.xs) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                Text("Concierge")
                    .font(VelaneraTypography.label(12))
                    .tracking(1.2)
                    .textCase(.uppercase)
            }
            .foregroundStyle(VelaneraColors.matteBlack)
            .padding(.horizontal, VelaneraSpacing.lg)
            .padding(.vertical, VelaneraSpacing.sm + 2)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [VelaneraColors.champagne, VelaneraColors.gold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: VelaneraColors.gold.opacity(glow ? 0.45 : 0.2), radius: glow ? 18 : 10, y: 4)
            )
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                glow = true
            }
        }
        .accessibilityLabel("Open AI Concierge")
    }
}
