import Foundation
import Observation
import AuthenticationServices
import SwiftData

/// Profile, authentication, favourites, and account editing.
@Observable
@MainActor
final class ProfileViewModel {
    private let apiClient: APIClientProtocol
    private let authService: AuthServiceProtocol
    private let notifications: NotificationServiceProtocol
    private let analytics: AnalyticsServiceProtocol

    var profile: UserProfile?
    var isLoading = false
    var isSaving = false
    var errorMessage: String?
    var notificationsEnabled = true
    var editName = ""
    var editEmail = ""
    var editPhone = ""

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
        editName = profile?.displayName ?? ""
        editEmail = profile?.email ?? ""
        editPhone = profile?.phone ?? ""
        isLoading = false
    }

    func handleAppleSignIn(_ result: Result<ASAuthorization, Error>, modelContext: ModelContext) async {
        do {
            let authorization = try result.get()
            let user = try await authService.signInWithApple(authorization: authorization)
            profile = user
            modelContext.insert(PersistedUserProfile(from: user))
            analytics.track(event: .signIn(.apple))
            await load()
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
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveProfile() async {
        isSaving = true
        errorMessage = nil
        do {
            let updated = try await apiClient.updateProfile(
                ProfileUpdateDTO(
                    displayName: editName,
                    email: editEmail,
                    phone: editPhone,
                    notificationsEnabled: notificationsEnabled
                )
            )
            profile = updated
            HapticFeedback.success()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }

    func signOut() {
        authService.signOut()
        profile = UserProfile(displayName: "Guest", email: "guest@velanera.co")
        editName = profile?.displayName ?? ""
        editEmail = profile?.email ?? ""
        editPhone = ""
    }

    func updateNotifications(_ enabled: Bool) async {
        notificationsEnabled = enabled
        if enabled {
            _ = await notifications.requestAuthorization()
            _ = try? await apiClient.registerPushToken(
                PushTokenDTO(token: "mock-device-token", platform: "ios")
            )
        }
        profile?.notificationsEnabled = enabled
    }
}
