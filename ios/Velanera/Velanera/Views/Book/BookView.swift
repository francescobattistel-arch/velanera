import SwiftUI

/// Unified booking for restaurant, lounge, and private events.
struct BookView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: BookViewModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                Text("Reserve")
                    .font(VelaneraTypography.title(34))
                    .foregroundStyle(VelaneraColors.ivory)

                Text("Restaurant, lounge, or a private evening — we will confirm with care.")
                    .font(VelaneraTypography.body(15))
                    .foregroundStyle(VelaneraColors.secondaryText)

                if viewModel == nil {
                    LoadingSkeleton(height: 320)
                } else if viewModel?.confirmation != nil {
                    confirmationView
                } else {
                    bookingForm
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Book")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil {
                viewModel = BookViewModel(
                    apiClient: environment.apiClient,
                    notifications: environment.notificationService,
                    analytics: environment.analyticsService
                )
            }
        }
    }

    private var bookingForm: some View {
        VStack(alignment: .leading, spacing: VelaneraSpacing.md) {
            Text("Experience")
                .font(VelaneraTypography.label(12))
                .foregroundStyle(VelaneraColors.gold)
                .tracking(1)

            Picker(
                "Venue",
                selection: Binding(
                    get: { viewModel?.venue ?? .restaurant },
                    set: { viewModel?.venue = $0 }
                )
            ) {
                ForEach(VenueType.allCases, id: \.self) { venue in
                    Text(venue.displayName).tag(venue)
                }
            }
            .pickerStyle(.segmented)

            GlassCard {
                VStack(spacing: VelaneraSpacing.md) {
                    DatePicker(
                        "Date & time",
                        selection: Binding(
                            get: { viewModel?.date ?? .now },
                            set: { viewModel?.date = $0 }
                        ),
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .colorScheme(.dark)
                    .tint(VelaneraColors.gold)

                    Stepper(
                        "Guests: \(viewModel?.guestCount ?? 2)",
                        value: Binding(
                            get: { viewModel?.guestCount ?? 2 },
                            set: { viewModel?.guestCount = $0 }
                        ),
                        in: 1...40
                    )
                    .foregroundStyle(VelaneraColors.ivory)

                    TextField(
                        "Full name",
                        text: Binding(
                            get: { viewModel?.contactName ?? "" },
                            set: { viewModel?.contactName = $0 }
                        )
                    )
                    .textContentType(.name)
                    .padding()
                    .glassBackground(cornerRadius: VelaneraSpacing.radiusSm)

                    TextField(
                        "Email",
                        text: Binding(
                            get: { viewModel?.contactEmail ?? "" },
                            set: { viewModel?.contactEmail = $0 }
                        )
                    )
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .glassBackground(cornerRadius: VelaneraSpacing.radiusSm)

                    TextField(
                        "Special requests",
                        text: Binding(
                            get: { viewModel?.specialRequests ?? "" },
                            set: { viewModel?.specialRequests = $0 }
                        ),
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                    .padding()
                    .glassBackground(cornerRadius: VelaneraSpacing.radiusSm)
                }
                .foregroundStyle(VelaneraColors.ivory)
            }

            if let error = viewModel?.errorMessage {
                Text(error)
                    .font(VelaneraTypography.caption())
                    .foregroundStyle(VelaneraColors.danger)
            }

            LuxuryButton(
                title: viewModel?.venue == .privateEvent ? "Submit Request" : "Confirm Reservation",
                isLoading: viewModel?.isSubmitting == true,
                systemImage: "checkmark"
            ) {
                Task { await viewModel?.submit(modelContext: modelContext) }
            }
            .disabled(viewModel?.canSubmit != true)
            .opacity(viewModel?.canSubmit == true ? 1 : 0.5)
        }
    }

    @ViewBuilder
    private var confirmationView: some View {
        if let reservation = viewModel?.confirmation {
            VStack(spacing: VelaneraSpacing.lg) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 48, weight: .ultraLight))
                    .foregroundStyle(VelaneraColors.gold)
                    .symbolEffect(.bounce, value: reservation.id)

                Text(reservation.status == .staffReview ? "Request Received" : "Reservation Confirmed")
                    .font(VelaneraTypography.title(28))
                    .foregroundStyle(VelaneraColors.ivory)

                ReservationCard(reservation: reservation)

                Text("A confirmation will be sent to \(reservation.contactEmail). Future backend delivery will automate this.")
                    .font(VelaneraTypography.caption())
                    .foregroundStyle(VelaneraColors.secondaryText)
                    .multilineTextAlignment(.center)

                LuxuryButton(title: "Book Another", style: .secondary) {
                    viewModel?.resetForm()
                }
            }
            .frame(maxWidth: .infinity)
            .luxuryAppear()
        }
    }
}
