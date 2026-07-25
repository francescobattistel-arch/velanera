import Foundation

/// Common allergen markers for menu items.
enum Allergen: String, Codable, CaseIterable, Sendable, Identifiable {
    case gluten
    case dairy
    case nuts
    case shellfish
    case eggs
    case soy
    case sesame
    case fish

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gluten: "Gluten"
        case .dairy: "Dairy"
        case .nuts: "Nuts"
        case .shellfish: "Shellfish"
        case .eggs: "Eggs"
        case .soy: "Soy"
        case .sesame: "Sesame"
        case .fish: "Fish"
        }
    }

    var symbolName: String {
        switch self {
        case .gluten: "leaf"
        case .dairy: "drop"
        case .nuts: "leaf.circle"
        case .shellfish: "fish"
        case .eggs: "circle"
        case .soy: "circle.hexagongrid"
        case .sesame: "circle.grid.cross"
        case .fish: "fish.fill"
        }
    }

    var guidance: String {
        switch self {
        case .gluten: "Contains wheat, barley, or rye."
        case .dairy: "Contains milk or milk derivatives."
        case .nuts: "Contains tree nuts or traces thereof."
        case .shellfish: "Contains crustaceans or molluscs."
        case .eggs: "Contains egg."
        case .soy: "Contains soy."
        case .sesame: "Contains sesame."
        case .fish: "Contains fish."
        }
    }
}
