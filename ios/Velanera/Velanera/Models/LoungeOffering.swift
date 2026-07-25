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
    var detail: String
    var kind: Kind
    var startingPrice: Decimal
    var capacity: Int
    var includes: [String]
    var minimumSpend: Decimal?
    var symbolName: String

    var formattedStartingPrice: String {
        "From " + startingPrice.formatted(.currency(code: "GBP"))
    }

    init(
        id: UUID = UUID(),
        name: String,
        summary: String,
        detail: String = "",
        kind: Kind,
        startingPrice: Decimal,
        capacity: Int,
        includes: [String] = [],
        minimumSpend: Decimal? = nil,
        symbolName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.detail = detail.isEmpty ? summary : detail
        self.kind = kind
        self.startingPrice = startingPrice
        self.capacity = capacity
        self.includes = includes
        self.minimumSpend = minimumSpend
        self.symbolName = symbolName ?? kind.symbolName
    }
}
