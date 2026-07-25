import SwiftUI

/// Animated audio waveform tuned for ProMotion displays.
struct WaveformView: View {
    var levels: [CGFloat]
    var isActive: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 1.0 / 30.0 : 1.0 / 120.0, paused: !isActive)) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate
            HStack(alignment: .center, spacing: 3) {
                ForEach(Array(levels.enumerated()), id: \.offset) { index, level in
                    let wobble = isActive && !reduceMotion
                        ? (sin(phase * 10 + Double(index) * 0.45) + 1) * 0.08
                        : 0
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [VelaneraColors.champagne, VelaneraColors.gold],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: 3, height: barHeight(for: level + CGFloat(wobble)))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
        }
        .accessibilityLabel("Voice waveform")
        .accessibilityHidden(!isActive)
    }

    private func barHeight(for level: CGFloat) -> CGFloat {
        let clamped = max(0.08, min(level, 1))
        return isActive ? 10 + clamped * 42 : 8
    }
}
