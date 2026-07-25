import SwiftUI

/// Velanera colour tokens — matte black canvas with restrained gold accents.
enum VelaneraColors {
    static let matteBlack = Color(hex: 0x0A0A0A)
    static let nearBlack = Color(hex: 0x121212)
    static let elevated = Color(hex: 0x1A1A1A)
    static let charcoal = Color(hex: 0x2A2A2A)

    static let gold = Color(hex: 0xC6A75E)
    static let softGold = Color(hex: 0xD4BC82)
    static let champagne = Color(hex: 0xE8D5A3)

    static let ivory = Color(hex: 0xF5F0E8)
    static let secondaryText = Color(hex: 0xA8A29A)
    static let tertiaryText = Color(hex: 0x6B6560)

    static let success = Color(hex: 0x5C8A6B)
    static let danger = Color(hex: 0xA65D5D)

    static let glassFill = Color.white.opacity(0.06)
    static let glassStroke = Color.white.opacity(0.12)
    static let goldStroke = gold.opacity(0.45)

    static let heroGradient = LinearGradient(
        colors: [
            matteBlack.opacity(0.15),
            matteBlack.opacity(0.55),
            matteBlack.opacity(0.92)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let ambientGradient = LinearGradient(
        colors: [nearBlack, matteBlack, Color(hex: 0x101010)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
