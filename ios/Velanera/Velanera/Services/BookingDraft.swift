import Foundation
import Observation

/// Cross-tab booking intent (e.g. Lounge offering → Book tab).
@Observable
@MainActor
final class BookingDraft {
    var venue: VenueType = .restaurant
    var offeringID: UUID?
    var occasion: String = ""
    var guestCount: Int?
    var note: String = ""
    var isPending = false

    func prefill(
        venue: VenueType,
        offeringID: UUID? = nil,
        occasion: String = "",
        guestCount: Int? = nil,
        note: String = ""
    ) {
        self.venue = venue
        self.offeringID = offeringID
        self.occasion = occasion
        self.guestCount = guestCount
        self.note = note
        self.isPending = true
    }

    func consume() -> (
        venue: VenueType,
        offeringID: UUID?,
        occasion: String,
        guestCount: Int?,
        note: String
    )? {
        guard isPending else { return nil }
        isPending = false
        defer {
            offeringID = nil
            occasion = ""
            guestCount = nil
            note = ""
        }
        return (venue, offeringID, occasion, guestCount, note)
    }
}
