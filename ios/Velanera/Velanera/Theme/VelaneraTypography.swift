import SwiftUI

/// Expressive typography scale for a luxury hospitality surface.
enum VelaneraTypography {
    static func display(_ size: CGFloat = 44) -> Font {
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
}
