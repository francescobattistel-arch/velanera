import SwiftUI

/// Address, phone, and maps handoff.
struct LocationView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var hours: OpeningHours?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                Text("Find Us")
                    .font(VelaneraTypography.displayScaled)
                    .foregroundStyle(VelaneraColors.ivory)

                if let hours {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Label(hours.address, systemImage: "mappin.and.ellipse")
                            Link(destination: URL(string: "tel:\(hours.phone.filter { $0.isNumber || $0 == "+" })")!) {
                                Label(hours.phone, systemImage: "phone")
                                    .foregroundStyle(VelaneraColors.champagne)
                            }
                            Text("Valet available Friday & Saturday evenings.")
                                .font(VelaneraTypography.captionScaled)
                                .foregroundStyle(VelaneraColors.secondaryText)
                        }
                        .font(VelaneraTypography.bodyScaled)
                        .foregroundStyle(VelaneraColors.ivory)
                    }

                    Link(destination: mapURL(for: hours)) {
                        Text("Open in Maps")
                            .font(VelaneraTypography.labelScaled)
                            .tracking(1.2)
                            .textCase(.uppercase)
                            .foregroundStyle(VelaneraColors.matteBlack)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: DeviceLayout.minTouchTarget)
                            .background(
                                LinearGradient(
                                    colors: [VelaneraColors.champagne, VelaneraColors.gold],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: VelaneraSpacing.radiusSm, style: .continuous))
                    }

                    NavigationLink(value: AppDestination.openingHours) {
                        Text("View opening hours")
                            .font(VelaneraTypography.labelScaled)
                            .foregroundStyle(VelaneraColors.gold)
                            .frame(minHeight: DeviceLayout.minTouchTarget)
                    }
                } else {
                    LoadingSkeleton(height: 180)
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Location")
        .task {
            hours = try? await environment.apiClient.fetchOpeningHours()
        }
    }

    private func mapURL(for hours: OpeningHours) -> URL {
        let query = hours.mapQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Velanera"
        return URL(string: "http://maps.apple.com/?q=\(query)")!
    }
}
