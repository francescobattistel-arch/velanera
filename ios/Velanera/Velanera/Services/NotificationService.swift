import Foundation
import UserNotifications

protocol NotificationServiceProtocol: Sendable {
    func requestAuthorization() async -> Bool
    func scheduleReservationReminder(for reservation: Reservation) async
}

/// Local notification scaffolding; remote push arrives with backend tokens in Phase 4+.
public final class NotificationService: NotificationServiceProtocol, @unchecked Sendable {
    public init() {}

    public func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    public func scheduleReservationReminder(for reservation: Reservation) async {
        let content = UNMutableNotificationContent()
        content.title = "Velanera"
        content.body = "Your \(reservation.venue.displayName.lowercased()) reservation is coming up."
        content.sound = .default

        let triggerDate = reservation.date.addingTimeInterval(-3600)
        guard triggerDate > .now else { return }

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: reservation.id.uuidString,
            content: content,
            trigger: trigger
        )
        try? await UNUserNotificationCenter.current().add(request)
    }
}
