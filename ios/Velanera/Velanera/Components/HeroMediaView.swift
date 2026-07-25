import SwiftUI

/// Full-bleed atmospheric hero plane for the Home experience.
struct HeroMediaView: View {
    var brand: String = "Velanera"
    var headline: String = "Restaurant & Lounge"
    var supporting: String = "An intimate Mediterranean evening, composed with quiet luxury."
    var primaryActionTitle: String = "Reserve"
    var primaryAction: () -> Void = {}

    @State private var appear = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color(hex: 0x2A2318),
                    VelaneraColors.matteBlack,
                    Color(hex: 0x0C0C0C)
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .overlay {
                GeometryReader { proxy in
                    Circle()
                        .fill(VelaneraColors.gold.opacity(0.08))
                        .frame(width: proxy.size.width * 0.7)
                        .blur(radius: 60)
                        .offset(x: proxy.size.width * 0.35, y: -40)
                }
            }
            .overlay(VelaneraColors.heroGradient)

            VStack(alignment: .leading, spacing: VelaneraSpacing.md) {
                Text(brand.uppercased())
                    .font(VelaneraTypography.brand(42))
                    .foregroundStyle(VelaneraColors.ivory)
                    .tracking(8)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 16)

                Text(headline)
                    .font(VelaneraTypography.title(28))
                    .foregroundStyle(VelaneraColors.champagne)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 12)

                Text(supporting)
                    .font(VelaneraTypography.body(15))
                    .foregroundStyle(VelaneraColors.secondaryText)
                    .frame(maxWidth: 320, alignment: .leading)
                    .opacity(appear ? 1 : 0)

                LuxuryButton(title: primaryActionTitle, systemImage: "calendar") {
                    primaryAction()
                }
                .frame(maxWidth: 220)
                .padding(.top, VelaneraSpacing.xs)
                .opacity(appear ? 1 : 0)
            }
            .pagePadding()
            .padding(.bottom, VelaneraSpacing.xxl)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 520)
        .onAppear {
            withAnimation(VelaneraTheme.animationSmooth.delay(0.1)) {
                appear = true
            }
        }
    }
}
