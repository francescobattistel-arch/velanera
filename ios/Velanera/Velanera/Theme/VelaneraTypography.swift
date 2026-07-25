import SwiftUI

/// Dynamic Type–aware typography for the iPhone 17 reference experience.
enum VelaneraTypography {
    static func display(_ size: CGFloat = 40) -> Font {
        .system(size: size, weight: .light, design: .serif)
    }

    static func title(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }

    static func headline(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .medium, design: .serif)
    }

    static func body(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }

    static func caption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }

    static func label(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }

    static func brand(_ size: CGFloat = 36) -> Font {
        .system(size: size, weight: .ultraLight, design: .serif)
    }

    /// Scaled fonts that respect Dynamic Type.
    static var displayScaled: Font { .system(.largeTitle, design: .serif).weight(.light) }
    static var titleScaled: Font { .system(.title2, design: .serif) }
    static var headlineScaled: Font { .system(.title3, design: .serif).weight(.medium) }
    static var bodyScaled: Font { .body }
    static var captionScaled: Font { .subheadline.weight(.medium) }
    static var labelScaled: Font { .caption.weight(.semibold) }
}
