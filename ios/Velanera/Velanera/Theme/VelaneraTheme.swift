import SwiftUI

/// Central design-system entry for Velanera visual language.
enum VelaneraTheme {
    static let colors = VelaneraColors.self
    static let typography = VelaneraTypography.self
    static let spacing = VelaneraSpacing.self
    static let device = DeviceLayout.self

    static let animationSmooth = ProMotion.smooth()
    static let animationSpring = ProMotion.spring()
    static let animationGentle = Animation.easeInOut(duration: 0.5)

    /// Reference device metadata for documentation and diagnostics.
    static let referenceDeviceName = "iPhone 17"
    static let referenceOSVersion = "26.5.2"
}
