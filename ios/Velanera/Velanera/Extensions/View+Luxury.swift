import SwiftUI

extension View {
    /// Soft luxury fade-and-rise entrance.
    func luxuryAppear(delay: Double = 0) -> some View {
        modifier(LuxuryAppearModifier(delay: delay))
    }

    /// Standard horizontal page padding for iPhone 17 portrait.
    func pagePadding() -> some View {
        padding(.horizontal, DeviceLayout.contentInset)
    }

    /// Ensures controls meet the minimum touch target.
    func largeTouchTarget(minHeight: CGFloat = DeviceLayout.minTouchTarget) -> some View {
        frame(minHeight: minHeight)
            .contentShape(Rectangle())
    }

    /// Parallax-style depth on scroll offset.
    func luxuryParallax(offset: CGFloat, intensity: CGFloat = 0.25) -> some View {
        offset(y: offset * intensity)
            .scaleEffect(1 + min(max(-offset, 0), 80) / 1200)
    }

    /// Shared hero transition chrome.
    func luxuryHeroChrome() -> some View {
        modifier(LuxuryHeroChromeModifier())
    }

    /// Gentle shimmer border for premium CTAs.
    func goldShimmer(isActive: Bool = true) -> some View {
        modifier(GoldShimmerModifier(isActive: isActive))
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

private struct LuxuryHeroChromeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [VelaneraColors.matteBlack.opacity(0.35), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)
                .allowsHitTesting(false)
            }
    }
}

private struct GoldShimmerModifier: ViewModifier {
    var isActive: Bool
    @State private var phase: CGFloat = -0.6

    func body(content: Content) -> some View {
        content
            .overlay {
                if isActive {
                    LinearGradient(
                        colors: [
                            .clear,
                            VelaneraColors.champagne.opacity(0.35),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .rotationEffect(.degrees(20))
                    .offset(x: phase * 220)
                    .allowsHitTesting(false)
                    .onAppear {
                        withAnimation(.linear(duration: 2.8).repeatForever(autoreverses: false)) {
                            phase = 0.8
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: VelaneraSpacing.radiusSm, style: .continuous))
    }
}

/// Namespace IDs for matched geometry across feature detail transitions.
enum VelaneraMotionID {
    static func menu(_ id: UUID) -> String { "menu-\(id.uuidString)" }
    static func event(_ id: UUID) -> String { "event-\(id.uuidString)" }
    static func offering(_ id: UUID) -> String { "offering-\(id.uuidString)" }
    static func gallery(_ id: UUID) -> String { "gallery-\(id.uuidString)" }
}
