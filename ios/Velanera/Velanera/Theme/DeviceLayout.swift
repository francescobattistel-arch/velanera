import SwiftUI
import UIKit

/// Layout tokens optimised for iPhone 17 (portrait) as the reference device.
///
/// Reference: iPhone 17 · iOS 26.5.2 · portrait · Dark Mode.
/// iPad and landscape are intentionally unsupported until the phone experience is complete.
enum DeviceLayout {
    /// Minimum comfortable touch target (HIG).
    static let minTouchTarget: CGFloat = 48

    /// Primary voice control diameter on iPhone 17.
    static let conciergeHostSize: CGFloat = 196

    /// Outer pulse ring for recording state.
    static let conciergePulseSize: CGFloat = 236

    /// Bottom clearance above home indicator for floating controls.
    static let floatingBottomClearance: CGFloat = 28

    /// Edge-to-edge content horizontal inset that still respects readability.
    static let contentInset: CGFloat = 20

    /// Comfortable vertical rhythm between major blocks.
    static let sectionGap: CGFloat = 28

    static var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}

/// Prefers ProMotion-smooth animation curves when reduce-motion is off.
enum ProMotion {
    static func smooth(duration: Double = 0.42) -> Animation {
        .smooth(duration: duration)
    }

    static func spring() -> Animation {
        .spring(response: 0.38, dampingFraction: 0.84, blendDuration: 0.15)
    }

    static func recordingPulse() -> Animation {
        .easeInOut(duration: 0.9).repeatForever(autoreverses: true)
    }
}
