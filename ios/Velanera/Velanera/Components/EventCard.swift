import SwiftUI

/// Card presenting a hospitality event or DJ night.
struct EventCard: View {
    let event: VenueEvent
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: VelaneraSpacing.sm) {
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: VelaneraSpacing.radiusMd, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [VelaneraColors.charcoal, VelaneraColors.nearBlack],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 160)
                        .overlay {
                            Image(systemName: event.symbolName)
                                .font(.system(size: 40, weight: .ultraLight))
                                .foregroundStyle(VelaneraColors.gold.opacity(0.7))
                        }

                    LinearGradient(
                        colors: [.clear, VelaneraColors.matteBlack.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: VelaneraSpacing.radiusMd, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(event.date.bookingDateLabel.uppercased())
                                .font(VelaneraTypography.label(11))
                                .foregroundStyle(VelaneraColors.gold)
                                .tracking(1.4)
                            if event.isMembersOnly {
                                Text("MEMBERS")
                                    .font(VelaneraTypography.label(9))
                                    .foregroundStyle(VelaneraColors.matteBlack)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(VelaneraColors.champagne)
                                    .clipShape(Capsule())
                            }
                        }
                        Text(event.title)
                            .font(VelaneraTypography.headline(20))
                            .foregroundStyle(VelaneraColors.ivory)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(VelaneraSpacing.md)
                }

                Text(event.subtitle)
                    .font(VelaneraTypography.caption())
                    .foregroundStyle(VelaneraColors.secondaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .buttonStyle(.plain)
    }
}
