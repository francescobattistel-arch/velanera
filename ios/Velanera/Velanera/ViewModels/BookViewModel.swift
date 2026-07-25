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
    var contactPhone: String = ""
    var occasion: String = ""
    var offeringID: UUID?
    var slots: [AvailabilitySlot] = []
    var selectedSlot: AvailabilitySlot?
    var isLoadingSlots = false
    var isSubmitting = false
    var confirmation: Reservation?
    var errorMessage: String?

    init(
        apiClient: APIClientProtocol,
        notifications: NotificationServiceProtocol,
        analytics: AnalyticsServiceProtocol,
        prefillVenue: VenueType? = nil,
        prefillOfferingID: UUID? = nil
    ) {
        self.apiClient = apiClient
        self.notifications = notifications
        self.analytics = analytics
        if let prefillVenue { venue = prefillVenue }
        offeringID = prefillOfferingID
    }

    var canSubmit: Bool {
        !contactName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && contactEmail.contains("@")
            && guestCount > 0
            && selectedSlot != nil
            && !isSubmitting
    }

    func loadAvailability() async {
        isLoadingSlots = true
        errorMessage = nil
        do {
            let query = AvailabilityQueryDTO(venue: venue, date: date, guestCount: guestCount)
            slots = try await apiClient.fetchAvailability(query)
            if let selectedSlot, slots.contains(selectedSlot) == false {
                self.selectedSlot = slots.first(where: \.isAvailable)
            } else if selectedSlot == nil {
                selectedSlot = slots.first(where: \.isAvailable)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingSlots = false
    }

    func submit(modelContext: ModelContext) async {
        guard canSubmit, let slot = selectedSlot else { return }
        isSubmitting = true
        errorMessage = nil
        analytics.track(event: .bookingStarted(venue))

        let request = ReservationRequestDTO(
            venue: venue,
            date: slot.date,
            guestCount: guestCount,
            specialRequests: specialRequests,
            contactName: contactName,
            contactEmail: contactEmail,
            contactPhone: contactPhone,
            offeringID: offeringID,
            occasion: occasion
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
        occasion = ""
        guestCount = 2
        selectedSlot = nil
    }
}
