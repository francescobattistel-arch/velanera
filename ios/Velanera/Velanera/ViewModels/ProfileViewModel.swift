import Foundation
import Observation
import AuthenticationServices
import SwiftData

/// Profile, authentication, favourites, and settings.
@Observable
@MainActor
final class ProfileViewModel {
    private let apiClient: APIClientProtocol
    private let authService: AuthServiceProtocol
    private let notifications: NotificationServiceProtocol
    private let analytics: AnalyticsServiceProtocol

    var profile: UserProfile?
    var isLoading = false
    var errorMessage: String?
    var notificationsEnabled = true

    init(
        apiClient: APIClientProtocol,
        authService: AuthServiceProtocol,
        notifications: NotificationServiceProtocol,
        analytics: AnalyticsServiceProtocol
    ) {
        self.apiClient = apiClient
        self.authService = authService
        self.notifications = notifications
        self.analytics = analytics
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        analytics.track(event: .screenView("profile"))
        if let current = authService.currentUser {
            profile = current
        } else {
            do {
                profile = try await apiClient.fetchProfile()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        notificationsEnabled = profile?.notificationsEnabled ?? true
        isLoading = false
    }

    func handleAppleSignIn(_ result: Result<ASAuthorization, Error>, modelContext: ModelContext) async {
        do {
            let authorization = try result.get()
            let user = try await authService.signInWithApple(authorization: authorization)
            profile = user
            modelContext.insert(PersistedUserProfile(from: user))
            analytics.track(event: .signIn(.apple))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signInWithGooglePlaceholder(modelContext: ModelContext) async {
        do {
            let user = try await authService.signInWithGooglePlaceholder()
            profile = user
            modelContext.insert(PersistedUserProfile(from: user))
            analytics.track(event: .signIn(.google))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        authService.signOut()
        profile = UserProfile(displayName: "Guest", email: "guest@velanera.co")
    }

    func updateNotifications(_ enabled: Bool) async {
        notificationsEnabled = enabled
        if enabled {
            _ = await notifications.requestAuthorization()
        }
        profile?.notificationsEnabled = enabled
    }
}
