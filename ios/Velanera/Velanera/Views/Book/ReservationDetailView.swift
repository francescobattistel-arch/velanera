import SwiftUI
import SwiftData

/// Reservation management — view, modify guests/notes, cancel.
struct ReservationDetailView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.modelContext) private var modelContext
    let reservationID: UUID

    @State private var reservation: Reservation?
    @State private var guestCount = 2
    @State private var specialRequests = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                if let reservation {
                    ReservationCard(reservation: reservation)

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Confirmation \(reservation.confirmationCode)")
                                .font(VelaneraTypography.headline(16))
                                .foregroundStyle(VelaneraColors.champagne)
                            if !reservation.occasion.isEmpty {
                                Text("Occasion · \(reservation.occasion)")
                                    .font(VelaneraTypography.caption())
                                    .foregroundStyle(VelaneraColors.secondaryText)
                            }
                            Text(reservation.contactEmail)
                                .font(VelaneraTypography.caption())
                                .foregroundStyle(VelaneraColors.secondaryText)
                            if !reservation.contactPhone.isEmpty {
                                Text(reservation.contactPhone)
                                    .font(VelaneraTypography.caption())
                                    .foregroundStyle(VelaneraColors.secondaryText)
                            }
                        }
                    }

                    if reservation.status != .cancelled {
                        SectionHeader(title: "Manage", subtitle: "Update details or cancel")
                        Stepper("Guests: \(guestCount)", value: $guestCount, in: 1...40)
                            .foregroundStyle(VelaneraColors.ivory)
                        TextField("Special requests", text: $specialRequests, axis: .vertical)
                            .lineLimit(3...5)
                            .padding()
                            .glassBackground(cornerRadius: VelaneraSpacing.radiusSm)
                            .foregroundStyle(VelaneraColors.ivory)

                        if let errorMessage {
                            Text(errorMessage).foregroundStyle(VelaneraColors.danger)
                        }

                        LuxuryButton(title: "Save Changes", isLoading: isSaving, systemImage: "checkmark") {
                            Task { await save() }
                        }
                        LuxuryButton(title: "Cancel Reservation", style: .ghost, systemImage: "xmark") {
                            Task { await cancel() }
                        }
                    }
                } else {
                    LoadingSkeleton(height: 200)
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Reservation")
        .task { loadLocal() }
    }

    private func loadLocal() {
        let descriptor = FetchDescriptor<PersistedReservation>(
            predicate: #Predicate { $0.id == reservationID }
        )
        if let local = try? modelContext.fetch(descriptor).first {
            reservation = local.asReservation
            guestCount = local.guestCount
            specialRequests = local.specialRequests
        }
    }

    private func save() async {
        isSaving = true
        errorMessage = nil
        do {
            let updated = try await environment.apiClient.updateReservation(
                id: reservationID,
                update: ReservationUpdateDTO(guestCount: guestCount, specialRequests: specialRequests)
            )
            reservation = updated
            syncLocal(updated)
            HapticFeedback.success()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }

    private func cancel() async {
        isSaving = true
        do {
            let updated = try await environment.apiClient.cancelReservation(id: reservationID)
            reservation = updated
            syncLocal(updated)
            HapticFeedback.warning()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }

    private func syncLocal(_ reservation: Reservation) {
        let descriptor = FetchDescriptor<PersistedReservation>(
            predicate: #Predicate { $0.id == reservationID }
        )
        if let local = try? modelContext.fetch(descriptor).first {
            local.apply(reservation)
        }
    }
}
