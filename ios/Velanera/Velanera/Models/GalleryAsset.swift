import Foundation

/// Curated gallery image placeholder for Home and Lounge.
struct GalleryAsset: Identifiable, Codable, Hashable, Sendable {
    enum Collection: String, Codable, CaseIterable, Sendable {
        case restaurant
        case lounge
        case events
        case membership

        var displayName: String {
            switch self {
            case .restaurant: "Restaurant"
            case .lounge: "Lounge"
            case .events: "Events"
            case .membership: "Members"
            }
        }
    }

    let id: UUID
    var title: String
    var caption: String
    var symbolName: String
    var collection: Collection

    init(
        id: UUID = UUID(),
        title: String,
        caption: String,
        symbolName: String,
        collection: Collection
    ) {
        self.id = id
        self.title = title
        self.caption = caption
        self.symbolName = symbolName
        self.collection = collection
    }
}
