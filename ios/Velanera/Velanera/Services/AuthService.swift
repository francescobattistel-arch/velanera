import Foundation
import AuthenticationServices

protocol AuthServiceProtocol: AnyObject, Sendable {
    @MainActor var currentUser: UserProfile? { get }
    @MainActor func signInWithApple(authorization: ASAuthorization) async throws -> UserProfile
    @MainActor func signInWithGooglePlaceholder() async throws -> UserProfile
    @MainActor func signOut()
}

/// Authentication façade. Apple Sign In is wired; Google is an intentional placeholder.
@MainActor
public final class AuthService: AuthServiceProtocol {
    private(set) public var currentUser: UserProfile?

    public init() {}

    public func signInWithApple(authorization: ASAuthorization) async throws -> UserProfile {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw APIError.unauthorized
        }

        let nameComponents = credential.fullName
        let composedName = [nameComponents?.givenName, nameComponents?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")

        let profile = UserProfile(
            id: UUID(uuidString: credential.user) ?? UUID(),
            displayName: composedName.isEmpty ? "Velanera Member" : composedName,
            email: credential.email ?? "member@velanera.co",
            authProvider: .apple,
            notificationsEnabled: true
        )
        currentUser = profile
        return profile
    }

    /// Placeholder for future Google Sign-In SDK integration.
    public func signInWithGooglePlaceholder() async throws -> UserProfile {
        let profile = UserProfile(
            displayName: "Google Guest",
            email: "google.guest@velanera.co",
            authProvider: .google
        )
        currentUser = profile
        return profile
    }

    public func signOut() {
        currentUser = nil
    }
}
