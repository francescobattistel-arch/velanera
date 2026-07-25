import SwiftUI

extension View {
    /// Soft luxury fade-and-rise entrance.
    func luxuryAppear(delay: Double = 0) -> some View {
        modifier(LuxuryAppearModifier(delay: delay))
    }

    /// Standard horizontal page padding.
    func pagePadding() -> some View {
        padding(.horizontal, VelaneraSpacing.lg)
    }
}

private struct LuxuryAppearModifier: ViewModifier {
    let delay: Double
    @State private var visible = false

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : 12)
            .onAppear {
                withAnimation(VelaneraTheme.animationSmooth.delay(delay)) {
                    visible = true
                }
            }
    }
}
