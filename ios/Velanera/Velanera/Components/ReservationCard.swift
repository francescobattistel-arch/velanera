import SwiftUI

/// Summary card for an upcoming or past reservation.
struct ReservationCard: View {
    let reservation: Reservation
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            GlassCard {
                VStack(alignment: .leading, spacing: VelaneraSpacing.sm) {
                    HStack {
                        Text(reservation.venue.displayName.uppercased())
                            .font(VelaneraTypography.label(11))
                            .foregroundStyle(VelaneraColors.gold)
                            .tracking(1.4)
                        Spacer()
                        StatusPill(status: reservation.status)
                    }

                    Text(reservation.displayTitle)
                        .font(VelaneraTypography.headline(18))
                        .foregroundStyle(VelaneraColors.ivory)

                    HStack(spacing: VelaneraSpacing.lg) {
                        Label(reservation.date.bookingDateLabel, systemImage: "calendar")
                        Label(reservation.date.bookingTimeLabel, systemImage: "clock")
                        Label("\(reservation.guestCount)", systemImage: "person.2")
                    }
                    .font(VelaneraTypography.caption())
                    .foregroundStyle(VelaneraColors.secondaryText)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct StatusPill: View {
    let status: ReservationStatus

    var body: some View {
        Text(status.displayName)
            .font(VelaneraTypography.label(10))
            .foregroundStyle(status.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color.opacity(0.15))
            .clipShape(Capsule())
    }
}
