import Foundation

/// A single dish, wine, cocktail, or dessert on the digital menu.
struct MenuItem: Identifiable, Codable, Hashable, Sendable {
    enum Category: String, Codable, CaseIterable, Sendable {
        case starters
        case mains
        case desserts
        case wine
        case cocktails
        case chefSpecials

        var displayName: String {
            switch self {
            case .starters: "Starters"
            case .mains: "Mains"
            case .desserts: "Desserts"
            case .wine: "Wine"
            case .cocktails: "Cocktails"
            case .chefSpecials: "Chef Specials"
            }
        }
    }

    let id: UUID
    var name: String
    var description: String
    var price: Decimal
    var category: Category
    var allergens: [Allergen]
    var isChefRecommendation: Bool
    var symbolName: String

    var formattedPrice: String {
        price.formatted(.currency(code: "GBP"))
    }

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        price: Decimal,
        category: Category,
        allergens: [Allergen] = [],
        isChefRecommendation: Bool = false,
        symbolName: String = "fork.knife"
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.category = category
        self.allergens = allergens
        self.isChefRecommendation = isChefRecommendation
        self.symbolName = symbolName
    }
}
