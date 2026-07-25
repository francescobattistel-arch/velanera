import SwiftUI

/// Frosted container for interactive or narrative content blocks.
struct GlassCard<Content: View>: View {
    var padding: CGFloat = VelaneraSpacing.md
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassBackground()
    }
}

#Preview {
    GlassCard {
        Text("Velanera")
            .font(VelaneraTypography.headline())
            .foregroundStyle(VelaneraColors.ivory)
    }
    .padding()
    .background(VelaneraColors.matteBlack)
}
