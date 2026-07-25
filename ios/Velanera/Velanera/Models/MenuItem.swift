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

        var symbolName: String {
            switch self {
            case .starters: "leaf"
            case .mains: "fork.knife"
            case .desserts: "birthday.cake"
            case .wine: "wineglass"
            case .cocktails: "wineglass.fill"
            case .chefSpecials: "star"
            }
        }
    }

    let id: UUID
    var name: String
    var description: String
    var longDescription: String
    var price: Decimal
    var category: Category
    var allergens: [Allergen]
    var isChefRecommendation: Bool
    var symbolName: String
    var pairingNote: String?
    var wineRegion: String?
    var wineVintage: String?
    var wineGrape: String?
    var abv: String?
    var dietaryTags: [String]

    var formattedPrice: String {
        price.formatted(.currency(code: "GBP"))
    }

    var isWine: Bool { category == .wine }
    var isCocktail: Bool { category == .cocktails }

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        longDescription: String? = nil,
        price: Decimal,
        category: Category,
        allergens: [Allergen] = [],
        isChefRecommendation: Bool = false,
        symbolName: String = "fork.knife",
        pairingNote: String? = nil,
        wineRegion: String? = nil,
        wineVintage: String? = nil,
        wineGrape: String? = nil,
        abv: String? = nil,
        dietaryTags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.longDescription = longDescription ?? description
        self.price = price
        self.category = category
        self.allergens = allergens
        self.isChefRecommendation = isChefRecommendation
        self.symbolName = symbolName
        self.pairingNote = pairingNote
        self.wineRegion = wineRegion
        self.wineVintage = wineVintage
        self.wineGrape = wineGrape
        self.abv = abv
        self.dietaryTags = dietaryTags
    }
}
