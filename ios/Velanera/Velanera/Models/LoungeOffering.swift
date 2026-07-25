import Foundation

/// Lounge product: VIP table, private area, or bottle service.
struct LoungeOffering: Identifiable, Codable, Hashable, Sendable {
    enum Kind: String, Codable, CaseIterable, Sendable {
        case vipTable
        case privateArea
        case bottleService

        var displayName: String {
            switch self {
            case .vipTable: "VIP Tables"
            case .privateArea: "Private Areas"
            case .bottleService: "Bottle Service"
            }
        }

        var symbolName: String {
            switch self {
            case .vipTable: "sofa.fill"
            case .privateArea: "door.left.hand.open"
            case .bottleService: "wineglass.fill"
            }
        }
    }

    let id: UUID
    var name: String
    var summary: String
    var kind: Kind
    var startingPrice: Decimal
    var capacity: Int

    var formattedStartingPrice: String {
        "From " + startingPrice.formatted(.currency(code: "GBP"))
    }

    init(
        id: UUID = UUID(),
        name: String,
        summary: String,
        kind: Kind,
        startingPrice: Decimal,
        capacity: Int
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.kind = kind
        self.startingPrice = startingPrice
        self.capacity = capacity
    }
}
