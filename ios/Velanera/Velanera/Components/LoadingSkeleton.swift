import SwiftUI

/// Premium shimmer placeholder for loading states.
struct LoadingSkeleton: View {
    var height: CGFloat = 88
    var cornerRadius: CGFloat = VelaneraSpacing.radiusMd

    @State private var phase: CGFloat = -1

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(VelaneraColors.elevated)
            .frame(height: height)
            .overlay {
                LinearGradient(
                    colors: [
                        .clear,
                        VelaneraColors.gold.opacity(0.08),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase * 220)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1.2
                }
            }
            .accessibilityLabel("Loading")
    }
}

/// Stack of skeleton rows for list placeholders.
struct LoadingSkeletonList: View {
    var count: Int = 3

    var body: some View {
        VStack(spacing: VelaneraSpacing.md) {
            ForEach(0..<count, id: \.self) { index in
                LoadingSkeleton()
                    .opacity(1 - Double(index) * 0.12)
            }
        }
    }
}
