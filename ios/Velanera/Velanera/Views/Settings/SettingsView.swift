import SwiftUI

/// Full settings surface — notifications, voice, dietary, privacy, about.
struct SettingsView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var viewModel: SettingsViewModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.xl) {
                Text("Settings")
                    .font(VelaneraTypography.title(34))
                    .foregroundStyle(VelaneraColors.ivory)

                if let viewModel {
                    section("Notifications") {
                        toggle("Reservation alerts", isOn: viewModel.settings.notificationsEnabled) {
                            Task { await viewModel.setNotifications($0) }
                        }
                        toggle("Marketing emails", isOn: viewModel.settings.marketingEmailsEnabled) {
                            viewModel.setMarketing($0)
                        }
                    }

                    section("Concierge") {
                        toggle("Speak replies aloud", isOn: viewModel.settings.conciergeVoiceEnabled) {
                            viewModel.setConciergeVoice($0)
                        }
                        NavigationLink(value: AppDestination.staffRequests) {
                            settingsRow("Staff requests", systemImage: "tray.full")
                        }
                        NavigationLink(value: AppDestination.conciergeArchive) {
                            settingsRow("Transcript archive", systemImage: "waveform")
                        }
                    }

                    section("Accessibility") {
                        toggle("Reduce motion", isOn: viewModel.settings.reduceMotion) {
                            viewModel.setReduceMotion($0)
                        }
                    }

                    section("Dietary exclusions") {
                        ForEach(Allergen.allCases) { allergen in
                            Button {
                                viewModel.toggleDietary(allergen)
                            } label: {
                                HStack {
                                    Text(allergen.displayName)
                                        .foregroundStyle(VelaneraColors.ivory)
                                    Spacer()
                                    Image(systemName: viewModel.settings.dietaryExclusions.contains(allergen) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(VelaneraColors.gold)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    section("Privacy & legal") {
                        NavigationLink(value: AppDestination.privacy) {
                            settingsRow("Privacy policy", systemImage: "hand.raised")
                        }
                        NavigationLink(value: AppDestination.terms) {
                            settingsRow("Terms of use", systemImage: "doc.text")
                        }
                    }

                    section("About") {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Velanera")
                                    .font(VelaneraTypography.headline(18))
                                    .foregroundStyle(VelaneraColors.ivory)
                                Text("Version \(viewModel.appVersion) (\(viewModel.buildNumber))")
                                    .font(VelaneraTypography.caption())
                                    .foregroundStyle(VelaneraColors.secondaryText)
                                Text("Restaurant & Lounge")
                                    .font(VelaneraTypography.caption())
                                    .foregroundStyle(VelaneraColors.tertiaryText)
                            }
                        }
                        LuxuryButton(title: "Reset Preferences", style: .ghost) {
                            viewModel.reset()
                        }
                    }
                } else {
                    LoadingSkeletonList(count: 2)
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil {
                viewModel = SettingsViewModel(
                    settingsStore: environment.settingsStore,
                    notifications: environment.notificationService,
                    apiClient: environment.apiClient,
                    analytics: environment.analyticsService
                )
            }
            viewModel?.onAppear()
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: VelaneraSpacing.md) {
            SectionHeader(title: title)
            content()
        }
    }

    private func toggle(_ title: String, isOn: Bool, set: @escaping (Bool) -> Void) -> some View {
        GlassCard {
            Toggle(title, isOn: Binding(get: { isOn }, set: set))
                .tint(VelaneraColors.gold)
                .foregroundStyle(VelaneraColors.ivory)
        }
    }

    private func settingsRow(_ title: String, systemImage: String) -> some View {
        GlassCard {
            Label(title, systemImage: systemImage)
                .font(VelaneraTypography.body(15))
                .foregroundStyle(VelaneraColors.ivory)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
