import SwiftUI

/// Applies a frosted glass treatment suited to dark luxury surfaces.
struct GlassBackground: ViewModifier {
    var cornerRadius: CGFloat = VelaneraSpacing.radiusMd
    var opacity: Double = 0.08

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.white.opacity(opacity))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(VelaneraColors.glassStroke, lineWidth: 1)
                    }
            }
    }
}

extension View {
    /// Wraps content in Velanera glass material.
    func glassBackground(cornerRadius: CGFloat = VelaneraSpacing.radiusMd, opacity: Double = 0.08) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius, opacity: opacity))
    }
}
