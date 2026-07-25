import SwiftUI

/// Central design-system entry for Velanera visual language.
enum VelaneraTheme {
    static let colors = VelaneraColors.self
    static let typography = VelaneraTypography.self
    static let spacing = VelaneraSpacing.self

    static let animationSmooth = Animation.smooth(duration: 0.45)
    static let animationSpring = Animation.spring(response: 0.45, dampingFraction: 0.82)
    static let animationGentle = Animation.easeInOut(duration: 0.55)
}
