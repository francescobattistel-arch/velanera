import Foundation
import Observation

/// Settings surface backed by `SettingsStore` and notification permissions.
@Observable
@MainActor
final class SettingsViewModel {
    private let settingsStore: SettingsStore
    private let notifications: NotificationServiceProtocol
    private let apiClient: APIClientProtocol
    private let analytics: AnalyticsServiceProtocol

    var settings: AppSettings
    var appVersion: String
    var buildNumber: String

    init(
        settingsStore: SettingsStore,
        notifications: NotificationServiceProtocol,
        apiClient: APIClientProtocol,
        analytics: AnalyticsServiceProtocol
    ) {
        self.settingsStore = settingsStore
        self.notifications = notifications
        self.apiClient = apiClient
        self.analytics = analytics
        self.settings = settingsStore.settings
        let info = Bundle.main.infoDictionary
        self.appVersion = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        self.buildNumber = info?["CFBundleVersion"] as? String ?? "1"
    }

    func onAppear() {
        analytics.track(event: .screenView("settings"))
        settings = settingsStore.settings
    }

    func setNotifications(_ enabled: Bool) async {
        settingsStore.update { $0.notificationsEnabled = enabled }
        settings = settingsStore.settings
        if enabled {
            _ = await notifications.requestAuthorization()
            _ = try? await apiClient.registerPushToken(
                PushTokenDTO(token: "mock-device-token", platform: "ios")
            )
        }
    }

    func setMarketing(_ enabled: Bool) {
        settingsStore.update { $0.marketingEmailsEnabled = enabled }
        settings = settingsStore.settings
    }

    func setConciergeVoice(_ enabled: Bool) {
        settingsStore.update { $0.conciergeVoiceEnabled = enabled }
        settings = settingsStore.settings
    }

    func setReduceMotion(_ enabled: Bool) {
        settingsStore.update { $0.reduceMotion = enabled }
        settings = settingsStore.settings
    }

    func toggleDietary(_ allergen: Allergen) {
        settingsStore.update { current in
            if current.dietaryExclusions.contains(allergen) {
                current.dietaryExclusions.removeAll { $0 == allergen }
            } else {
                current.dietaryExclusions.append(allergen)
            }
        }
        settings = settingsStore.settings
    }

    func reset() {
        settingsStore.reset()
        settings = settingsStore.settings
    }
}
