import SwiftUI

/// Edit display name, email, and phone.
struct EditProfileView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var viewModel: ProfileViewModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                Text("Edit Profile")
                    .font(VelaneraTypography.title(32))
                    .foregroundStyle(VelaneraColors.ivory)

                if let viewModel {
                    field("Name", text: Binding(
                        get: { viewModel.editName },
                        set: { viewModel.editName = $0 }
                    ))
                    field("Email", text: Binding(
                        get: { viewModel.editEmail },
                        set: { viewModel.editEmail = $0 }
                    ))
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    field("Phone", text: Binding(
                        get: { viewModel.editPhone },
                        set: { viewModel.editPhone = $0 }
                    ))
                    .keyboardType(.phonePad)

                    if let error = viewModel.errorMessage {
                        Text(error).foregroundStyle(VelaneraColors.danger)
                    }

                    LuxuryButton(title: "Save", isLoading: viewModel.isSaving, systemImage: "checkmark") {
                        Task { await viewModel.saveProfile() }
                    }
                } else {
                    LoadingSkeleton(height: 200)
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Edit Profile")
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

    private func field(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(VelaneraTypography.label(11))
                .foregroundStyle(VelaneraColors.gold)
                .tracking(1)
            TextField(title, text: text)
                .padding()
                .glassBackground(cornerRadius: VelaneraSpacing.radiusSm)
                .foregroundStyle(VelaneraColors.ivory)
        }
    }
}
