import SwiftUI

/// Floating host avatar that opens the AI Concierge — primary voice entry point.
struct FloatingConciergeButton: View {
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var glow = false

    var body: some View {
        Button {
            HapticFeedback.medium()
            action()
        } label: {
            HStack(spacing: 12) {
                Image("ConciergeHost")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .overlay {
                        Circle().strokeBorder(VelaneraColors.goldStroke, lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Concierge")
                        .font(VelaneraTypography.labelScaled)
                        .tracking(1.1)
                        .textCase(.uppercase)
                    Text("Hold to talk")
                        .font(VelaneraTypography.captionScaled)
                        .foregroundStyle(VelaneraColors.matteBlack.opacity(0.7))
                }
            }
            .foregroundStyle(VelaneraColors.matteBlack)
            .padding(.leading, 6)
            .padding(.trailing, 18)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [VelaneraColors.champagne, VelaneraColors.gold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: VelaneraColors.gold.opacity(glow ? 0.5 : 0.22),
                        radius: glow ? 20 : 12,
                        y: 4
                    )
            )
        }
        .buttonStyle(.plain)
        .frame(minHeight: DeviceLayout.minTouchTarget)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                glow = true
            }
        }
        .accessibilityLabel("Open AI Concierge")
        .accessibilityHint("Opens the voice concierge. Hold the host portrait to speak.")
    }
}
