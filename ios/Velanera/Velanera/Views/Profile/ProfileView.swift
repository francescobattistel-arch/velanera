import SwiftUI
import AuthenticationServices
import SwiftData

/// Guest identity, reservations, favourites, and settings entry.
struct ProfileView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PersistedReservation.date, order: .reverse) private var persistedReservations: [PersistedReservation]
    @Query(sort: \FavouriteDish.savedAt, order: .reverse) private var favourites: [FavouriteDish]
    @State private var selectedTab: AppTab = .profile
    @State private var viewModel: ProfileViewModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.xl) {
                header
                quickLinks
                authSection
                reservationsSection
                favouritesSection
                settingsEntry
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Profile")
        .velaneraRouter(selectedTab: $selectedTab)
        .task {
            if viewModel == nil {
                viewModel = ProfileViewModel(
                    apiClient: environment.apiClient,
                    authService: environment.authService,
                    notifications: environment.notificationService,
                    analytics: environment.analyticsService
                )
            }
            await viewModel?.load()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel?.profile?.displayName ?? "Guest")
                .font(VelaneraTypography.title(32))
                .foregroundStyle(VelaneraColors.ivory)
            Text(viewModel?.profile?.email ?? "Sign in to sync reservations")
                .font(VelaneraTypography.caption())
                .foregroundStyle(VelaneraColors.secondaryText)
            if let phone = viewModel?.profile?.phone, !phone.isEmpty {
                Text(phone)
                    .font(VelaneraTypography.caption())
                    .foregroundStyle(VelaneraColors.tertiaryText)
            }
        }
    }

    private var quickLinks: some View {
        HStack(spacing: 8) {
            NavigationLink(value: AppDestination.editProfile) { chip("Edit profile") }
            NavigationLink(value: AppDestination.settings) { chip("Settings") }
            NavigationLink(value: AppDestination.eventsList) { chip("Events") }
        }
    }

    private var authSection: some View {
        VStack(alignment: .leading, spacing: VelaneraSpacing.md) {
            SectionHeader(title: "Sign In", subtitle: "Secure access across devices")

            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                Task { await viewModel?.handleAppleSignIn(result, modelContext: modelContext) }
            }
            .signInWithAppleButtonStyle(.white)
            .frame(height: 48)
            .clipShape(RoundedRectangle(cornerRadius: VelaneraSpacing.radiusSm, style: .continuous))

            LuxuryButton(title: "Continue with Google", style: .secondary, systemImage: "g.circle") {
                Task { await viewModel?.signInWithGooglePlaceholder(modelContext: modelContext) }
            }

            if let provider = viewModel?.profile?.authProvider, provider != .none {
                Button("Sign Out") { viewModel?.signOut() }
                    .font(VelaneraTypography.label(12))
                    .foregroundStyle(VelaneraColors.secondaryText)
            }

            if let error = viewModel?.errorMessage {
                Text(error)
                    .font(VelaneraTypography.caption())
                    .foregroundStyle(VelaneraColors.danger)
            }
        }
    }

    private var reservationsSection: some View {
        VStack(alignment: .leading, spacing: VelaneraSpacing.md) {
            SectionHeader(title: "Reservations", subtitle: "Stored on this device")
            if persistedReservations.isEmpty {
                Text("No reservations yet.")
                    .foregroundStyle(VelaneraColors.secondaryText)
            } else {
                ForEach(persistedReservations, id: \.id) { item in
                    NavigationLink(value: AppDestination.reservationDetail(item.id)) {
                        ReservationCard(reservation: item.asReservation)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var favouritesSection: some View {
        VStack(alignment: .leading, spacing: VelaneraSpacing.md) {
            SectionHeader(title: "Favourite Dishes", subtitle: "Saved from the menu")
            if favourites.isEmpty {
                Text("Heart a dish in Restaurant to save it here.")
                    .foregroundStyle(VelaneraColors.secondaryText)
            } else {
                ForEach(favourites, id: \.dishID) { favourite in
                    NavigationLink(value: AppDestination.menuItem(favourite.dishID)) {
                        GlassCard {
                            Label(favourite.name, systemImage: "heart.fill")
                                .foregroundStyle(VelaneraColors.champagne)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var settingsEntry: some View {
        VStack(alignment: .leading, spacing: VelaneraSpacing.md) {
            SectionHeader(title: "Preferences", subtitle: "Notifications & more")
            NavigationLink(value: AppDestination.settings) {
                GlassCard {
                    Label("Open Settings", systemImage: "gearshape")
                        .foregroundStyle(VelaneraColors.ivory)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .buttonStyle(.plain)

            GlassCard {
                Toggle(
                    "Reservation notifications",
                    isOn: Binding(
                        get: { viewModel?.notificationsEnabled ?? true },
                        set: { newValue in
                            Task { await viewModel?.updateNotifications(newValue) }
                        }
                    )
                )
                .tint(VelaneraColors.gold)
                .foregroundStyle(VelaneraColors.ivory)
            }
        }
    }

    private func chip(_ title: String) -> some View {
        Text(title)
            .font(VelaneraTypography.label(11))
            .foregroundStyle(VelaneraColors.champagne)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(VelaneraColors.elevated)
            .clipShape(Capsule())
    }
}
