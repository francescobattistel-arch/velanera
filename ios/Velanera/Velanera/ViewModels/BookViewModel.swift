import Foundation
import Observation
import SwiftData

/// Booking flow for restaurant, lounge, and private events.
@Observable
@MainActor
final class BookViewModel {
    private let apiClient: APIClientProtocol
    private let notifications: NotificationServiceProtocol
    private let analytics: AnalyticsServiceProtocol

    var venue: VenueType = .restaurant
    var date: Date = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
    var guestCount: Int = 2
    var specialRequests: String = ""
    var contactName: String = ""
    var contactEmail: String = ""
    var isSubmitting = false
    var confirmation: Reservation?
    var errorMessage: String?

    init(
        apiClient: APIClientProtocol,
        notifications: NotificationServiceProtocol,
        analytics: AnalyticsServiceProtocol
    ) {
        self.apiClient = apiClient
        self.notifications = notifications
        self.analytics = analytics
    }

    var canSubmit: Bool {
        !contactName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && contactEmail.contains("@")
            && guestCount > 0
            && !isSubmitting
    }

    func submit(modelContext: ModelContext) async {
        guard canSubmit else { return }
        isSubmitting = true
        errorMessage = nil
        analytics.track(event: .bookingStarted(venue))

        let request = ReservationRequestDTO(
            venue: venue,
            date: date,
            guestCount: guestCount,
            specialRequests: specialRequests,
            contactName: contactName,
            contactEmail: contactEmail
        )

        do {
            let reservation = try await apiClient.createReservation(request)
            confirmation = reservation
            modelContext.insert(PersistedReservation(from: reservation))
            await notifications.scheduleReservationReminder(for: reservation)
            analytics.track(event: .bookingConfirmed(venue))
            HapticFeedback.success()
        } catch {
            errorMessage = error.localizedDescription
            HapticFeedback.warning()
        }
        isSubmitting = false
    }

    func resetForm() {
        confirmation = nil
        specialRequests = ""
        guestCount = 2
    }
}
