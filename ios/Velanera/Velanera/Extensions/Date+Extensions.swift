import Foundation

extension Date {
    /// Short calendar date suitable for booking cards.
    var bookingDateLabel: String {
        DateFormatters.bookingDate.string(from: self)
    }

    /// Time label for reservations.
    var bookingTimeLabel: String {
        DateFormatters.bookingTime.string(from: self)
    }
}
