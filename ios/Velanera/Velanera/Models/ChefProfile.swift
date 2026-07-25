import Foundation

/// Narrative content for the chef / tasting experience.
struct ChefProfile: Codable, Hashable, Sendable {
    var name: String
    var title: String
    var biography: String
    var philosophy: String
    var signatureDishIDs: [UUID]
    var tastingMenuSummary: String
    var tastingMenuPrice: Decimal

    var formattedTastingPrice: String {
        tastingMenuPrice.formatted(.currency(code: "GBP"))
    }
}
