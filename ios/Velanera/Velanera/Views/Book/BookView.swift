import SwiftUI

/// Unified booking engine with availability slots and confirmation.
struct BookView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: AppTab = .book
    @State private var viewModel: BookViewModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                Text("Reserve")
                    .font(VelaneraTypography.title(34))
                    .foregroundStyle(VelaneraColors.ivory)
                Text("Restaurant, lounge, or a private evening — availability first, then confirmation.")
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
        .velaneraRouter(selectedTab: $selectedTab)
        .onAppear {
            if viewModel == nil {
                viewModel = BookViewModel(
                    apiClient: environment.apiClient,
                    notifications: environment.notificationService,
                    analytics: environment.analyticsService
                )
            }
            if let draft = environment.bookingDraft.consume() {
                viewModel?.venue = draft.venue
                viewModel?.offeringID = draft.offeringID
                viewModel?.occasion = draft.occasion
                if let guests = draft.guestCount {
                    viewModel?.guestCount = guests
                }
                if !draft.note.isEmpty {
                    viewModel?.specialRequests = draft.note
                }
            }
        }
        .task(id: "\(viewModel?.venue.rawValue ?? "")-\(viewModel?.date.timeIntervalSince1970 ?? 0)-\(viewModel?.guestCount ?? 0)") {
            await viewModel?.loadAvailability()
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
                    set: { viewModel?.venue = $0; viewModel?.selectedSlot = nil }
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
                        "Date",
                        selection: Binding(
                            get: { viewModel?.date ?? .now },
                            set: { viewModel?.date = $0 }
                        ),
                        in: Date()...,
                        displayedComponents: [.date]
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

                    field("Full name", text: Binding(
                        get: { viewModel?.contactName ?? "" },
                        set: { viewModel?.contactName = $0 }
                    ))
                    field("Email", text: Binding(
                        get: { viewModel?.contactEmail ?? "" },
                        set: { viewModel?.contactEmail = $0 }
                    ))
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    field("Phone", text: Binding(
                        get: { viewModel?.contactPhone ?? "" },
                        set: { viewModel?.contactPhone = $0 }
                    ))
                    .keyboardType(.phonePad)
                    field("Occasion", text: Binding(
                        get: { viewModel?.occasion ?? "" },
                        set: { viewModel?.occasion = $0 }
                    ))

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

            SectionHeader(title: "Availability", subtitle: "Select a time")
            if viewModel?.isLoadingSlots == true {
                LoadingSkeleton(height: 72)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: 8)], spacing: 8) {
                    ForEach(viewModel?.slots ?? []) { slot in
                        Button {
                            viewModel?.selectedSlot = slot
                            HapticFeedback.light()
                        } label: {
                            VStack(spacing: 4) {
                                Text(slot.label)
                                    .font(VelaneraTypography.label(12))
                                Text(slot.isAvailable ? "Open" : "Full")
                                    .font(VelaneraTypography.label(9))
                                    .foregroundStyle(slot.isAvailable ? VelaneraColors.success : VelaneraColors.danger)
                            }
                            .foregroundStyle(
                                viewModel?.selectedSlot?.id == slot.id
                                ? VelaneraColors.matteBlack
                                : VelaneraColors.champagne
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(
                                        viewModel?.selectedSlot?.id == slot.id
                                        ? VelaneraColors.gold
                                        : VelaneraColors.elevated
                                    )
                            )
                            .opacity(slot.isAvailable ? 1 : 0.4)
                        }
                        .buttonStyle(.plain)
                        .disabled(!slot.isAvailable)
                    }
                }
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
            .goldShimmer(isActive: viewModel?.canSubmit == true)
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

                NavigationLink(value: AppDestination.reservationDetail(reservation.id)) {
                    ReservationCard(reservation: reservation)
                }
                .buttonStyle(.plain)

                Text("Confirmation \(reservation.confirmationCode) · \(reservation.contactEmail)")
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

    private func field(_ title: String, text: Binding<String>) -> some View {
        TextField(title, text: text)
            .padding()
            .glassBackground(cornerRadius: VelaneraSpacing.radiusSm)
    }
}
