import SwiftUI

/// DJ night detail with RSVP path into Events.
struct DJDetailView: View {
    @Environment(AppEnvironment.self) private var environment
    let eventID: UUID
    @State private var event: VenueEvent?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                if let event {
                    Image(systemName: event.symbolName)
                        .font(.system(size: 48, weight: .ultraLight))
                        .foregroundStyle(VelaneraColors.gold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, VelaneraSpacing.xl)
                        .background(VelaneraColors.elevated)
                        .clipShape(RoundedRectangle(cornerRadius: VelaneraSpacing.radiusLg, style: .continuous))

                    Text(event.title)
                        .font(VelaneraTypography.title(32))
                        .foregroundStyle(VelaneraColors.ivory)
                    Text(event.detail)
                        .font(VelaneraTypography.body(16))
                        .foregroundStyle(VelaneraColors.secondaryText)

                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label(event.date.bookingDateLabel, systemImage: "calendar")
                            Label(event.date.bookingTimeLabel, systemImage: "clock")
                            Label(event.venueLabel, systemImage: "mappin")
                            Label(event.dressCode, systemImage: "sparkles")
                            Text("\(event.remainingSpaces) spaces remaining")
                                .foregroundStyle(VelaneraColors.gold)
                        }
                        .font(VelaneraTypography.caption())
                        .foregroundStyle(VelaneraColors.secondaryText)
                    }

                    NavigationLink(value: AppDestination.eventDetail(event.id)) {
                        Text("View Event & RSVP")
                            .font(VelaneraTypography.label(14))
                            .tracking(1.2)
                            .textCase(.uppercase)
                            .foregroundStyle(VelaneraColors.matteBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, VelaneraSpacing.md)
                            .background(
                                LinearGradient(
                                    colors: [VelaneraColors.champagne, VelaneraColors.gold],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: VelaneraSpacing.radiusSm, style: .continuous))
                    }
                    .buttonStyle(.plain)
                } else {
                    LoadingSkeleton(height: 240)
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("DJ Night")
        .task {
            event = try? await environment.apiClient.fetchEvent(id: eventID)
        }
    }
}
