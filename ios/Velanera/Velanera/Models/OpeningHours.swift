import Foundation

/// Weekly opening hours for restaurant and lounge.
struct OpeningHours: Codable, Hashable, Sendable {
    struct DayHours: Identifiable, Codable, Hashable, Sendable {
        var id: String { day }
        var day: String
        var restaurant: String
        var lounge: String
    }

    var days: [DayHours]
    var address: String
    var phone: String
    var mapQuery: String
}
