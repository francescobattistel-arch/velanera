import Foundation

/// Public event, DJ night, or exclusive membership gathering.
struct VenueEvent: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var title: String
    var subtitle: String
    var date: Date
    var isMembersOnly: Bool
    var symbolName: String

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        date: Date,
        isMembersOnly: Bool = false,
        symbolName: String = "music.note"
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.date = date
        self.isMembersOnly = isMembersOnly
        self.symbolName = symbolName
    }
}
