import CoreGraphics

/// Spacing and corner radius tokens tuned for iPhone 17 portrait.
enum VelaneraSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 28
    static let xxl: CGFloat = 44
    static let hero: CGFloat = 56

    static let radiusSm: CGFloat = 12
    static let radiusMd: CGFloat = 18
    static let radiusLg: CGFloat = 28
    static let radiusPill: CGFloat = 999

    /// Preferred minimum control height.
    static let controlHeight: CGFloat = DeviceLayout.minTouchTarget
}
