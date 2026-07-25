import SwiftUI

/// Event detail with RSVP.
struct EventDetailView: View {
    @Environment(AppEnvironment.self) private var environment
    let eventID: UUID

    @State private var event: VenueEvent?
    @State private var guestName = ""
    @State private var guestCount = 2
    @State private var rsvp: EventRSVP?
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                if let event {
                    EventCard(event: event)
                    Text(event.detail)
                        .font(VelaneraTypography.body(16))
                        .foregroundStyle(VelaneraColors.secondaryText)

                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label(event.venueLabel, systemImage: "mappin")
                            Label(event.dressCode, systemImage: "sparkles")
                            Label("\(event.remainingSpaces) of \(event.capacity) spaces", systemImage: "person.3")
                            if event.isMembersOnly {
                                Label("Members only", systemImage: "crown")
                                    .foregroundStyle(VelaneraColors.gold)
                            }
                        }
                        .font(VelaneraTypography.caption())
                        .foregroundStyle(VelaneraColors.secondaryText)
                    }

                    if let rsvp {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("RSVP \(rsvp.status.rawValue.capitalized)")
                                    .font(VelaneraTypography.headline(18))
                                    .foregroundStyle(VelaneraColors.champagne)
                                Text("\(rsvp.guestName) · \(rsvp.guestCount) guests")
                                    .font(VelaneraTypography.caption())
                                    .foregroundStyle(VelaneraColors.secondaryText)
                            }
                        }
                        .luxuryAppear()
                    } else if event.rsvpRequired {
                        SectionHeader(title: "RSVP", subtitle: "We’ll confirm availability with care")
                        TextField("Your name", text: $guestName)
                            .padding()
                            .glassBackground(cornerRadius: VelaneraSpacing.radiusSm)
                            .foregroundStyle(VelaneraColors.ivory)
                        Stepper("Guests: \(guestCount)", value: $guestCount, in: 1...12)
                            .foregroundStyle(VelaneraColors.ivory)
                        if let errorMessage {
                            Text(errorMessage).foregroundStyle(VelaneraColors.danger)
                        }
                        LuxuryButton(title: "Request RSVP", isLoading: isSubmitting, systemImage: "checkmark") {
                            Task { await submit(event) }
                        }
                        .disabled(guestName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                } else {
                    LoadingSkeleton(height: 260)
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Event")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            event = try? await environment.apiClient.fetchEvent(id: eventID)
        }
    }

    private func submit(_ event: VenueEvent) async {
        isSubmitting = true
        errorMessage = nil
        do {
            rsvp = try await environment.apiClient.rsvpEvent(
                EventRSVPRequestDTO(eventID: event.id, guestName: guestName, guestCount: guestCount)
            )
            HapticFeedback.success()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSubmitting = false
    }
}
