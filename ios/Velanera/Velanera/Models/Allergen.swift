import Foundation

/// Common allergen markers for menu items.
enum Allergen: String, Codable, CaseIterable, Sendable {
    case gluten
    case dairy
    case nuts
    case shellfish
    case eggs
    case soy
    case sesame
    case fish
}
