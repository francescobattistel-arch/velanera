import Foundation

/// Bookable time window returned by the availability interface.
struct AvailabilitySlot: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var date: Date
    var venue: VenueType
    var capacityRemaining: Int
    var label: String
    var isPeak: Bool

    var isAvailable: Bool { capacityRemaining > 0 }

    init(
        id: UUID = UUID(),
        date: Date,
        venue: VenueType,
        capacityRemaining: Int,
        label: String,
        isPeak: Bool = false
    ) {
        self.id = id
        self.date = date
        self.venue = venue
        self.capacityRemaining = capacityRemaining
        self.label = label
        self.isPeak = isPeak
    }
}
