import Foundation
import Observation

/// Shared application dependencies injected into the SwiftUI environment.
@Observable
@MainActor
final class AppEnvironment {
    let apiClient: APIClientProtocol
    let authService: AuthServiceProtocol
    let speechRecognizer: SpeechRecognizerProtocol
    let voicePlayback: VoicePlaybackServiceProtocol
    let conversationEngine: ConversationEngineProtocol
    let notificationService: NotificationServiceProtocol
    let analyticsService: AnalyticsServiceProtocol
    let permissionService: PermissionServiceProtocol

    init(
        apiClient: APIClientProtocol,
        authService: AuthServiceProtocol,
        speechRecognizer: SpeechRecognizerProtocol,
        voicePlayback: VoicePlaybackServiceProtocol,
        conversationEngine: ConversationEngineProtocol,
        notificationService: NotificationServiceProtocol,
        analyticsService: AnalyticsServiceProtocol,
        permissionService: PermissionServiceProtocol
    ) {
        self.apiClient = apiClient
        self.authService = authService
        self.speechRecognizer = speechRecognizer
        self.voicePlayback = voicePlayback
        self.conversationEngine = conversationEngine
        self.notificationService = notificationService
        self.analyticsService = analyticsService
        self.permissionService = permissionService
    }

    /// Production composition root with mock networking until a backend ships.
    static var live: AppEnvironment {
        let configuration = APIConfiguration.load()
        let apiClient = APIClient(configuration: configuration)
        let conversationEngine = ConversationEngine(apiClient: apiClient)
        return AppEnvironment(
            apiClient: apiClient,
            authService: AuthService(),
            speechRecognizer: SpeechRecognizer(),
            voicePlayback: VoicePlaybackService(),
            conversationEngine: conversationEngine,
            notificationService: NotificationService(),
            analyticsService: AnalyticsService(),
            permissionService: PermissionService()
        )
    }
}
