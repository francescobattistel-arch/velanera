import SwiftUI

/// Animated audio waveform for the voice concierge recording state.
struct WaveformView: View {
    var levels: [CGFloat]
    var isActive: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach(Array(levels.enumerated()), id: \.offset) { _, level in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [VelaneraColors.champagne, VelaneraColors.gold],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 3, height: barHeight(for: level))
            }
        }
        .frame(height: 48)
        .animation(isActive ? .easeInOut(duration: 0.12) : .default, value: levels)
        .accessibilityLabel("Voice waveform")
    }

    private func barHeight(for level: CGFloat) -> CGFloat {
        let clamped = max(0.08, min(level, 1))
        return isActive ? 8 + clamped * 40 : 8
    }
}

#Preview {
    WaveformView(levels: (0..<24).map { _ in CGFloat.random(in: 0.1...1) }, isActive: true)
        .padding()
        .background(VelaneraColors.matteBlack)
}
