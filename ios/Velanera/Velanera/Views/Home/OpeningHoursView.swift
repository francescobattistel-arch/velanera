import SwiftUI

/// Full opening-hours reference for restaurant and lounge.
struct OpeningHoursView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var hours: OpeningHours?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                Text("Opening Hours")
                    .font(VelaneraTypography.displayScaled)
                    .foregroundStyle(VelaneraColors.ivory)

                if let hours {
                    Text(hours.address)
                        .font(VelaneraTypography.bodyScaled)
                        .foregroundStyle(VelaneraColors.secondaryText)

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(hours.days) { day in
                                HStack(alignment: .top) {
                                    Text(day.day)
                                        .font(VelaneraTypography.headlineScaled)
                                        .foregroundStyle(VelaneraColors.ivory)
                                        .frame(width: 110, alignment: .leading)
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Restaurant · \(day.restaurant)")
                                        Text("Lounge · \(day.lounge)")
                                    }
                                    .font(VelaneraTypography.captionScaled)
                                    .foregroundStyle(VelaneraColors.secondaryText)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                            }
                        }
                    }

                    NavigationLink(value: AppDestination.location) {
                        Label("Directions & contact", systemImage: "map")
                            .font(VelaneraTypography.labelScaled)
                            .foregroundStyle(VelaneraColors.gold)
                            .frame(minHeight: DeviceLayout.minTouchTarget)
                    }
                } else {
                    LoadingSkeletonList(count: 2)
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Hours")
        .task {
            hours = try? await environment.apiClient.fetchOpeningHours()
        }
    }
}
