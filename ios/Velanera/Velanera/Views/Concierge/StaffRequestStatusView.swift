import SwiftUI

/// Staff-review concierge requests created from voice.
struct StaffRequestStatusView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var requests: [ConciergeRequest] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                Text("Staff Requests")
                    .font(VelaneraTypography.title(32))
                    .foregroundStyle(VelaneraColors.ivory)
                Text("Bespoke asks awaiting the Velanera team.")
                    .font(VelaneraTypography.body(15))
                    .foregroundStyle(VelaneraColors.secondaryText)

                if requests.isEmpty {
                    GlassCard {
                        Text("No staff requests yet. Ask the concierge for something bespoke.")
                            .font(VelaneraTypography.caption())
                            .foregroundStyle(VelaneraColors.secondaryText)
                    }
                } else {
                    ForEach(requests) { request in
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(request.status.displayName.uppercased())
                                    .font(VelaneraTypography.label(11))
                                    .foregroundStyle(request.status.color)
                                    .tracking(1)
                                Text(request.summary)
                                    .font(VelaneraTypography.headline(17))
                                    .foregroundStyle(VelaneraColors.ivory)
                                Text(request.details)
                                    .font(VelaneraTypography.caption())
                                    .foregroundStyle(VelaneraColors.secondaryText)
                                Text(request.createdAt.bookingDateLabel)
                                    .font(VelaneraTypography.label(10))
                                    .foregroundStyle(VelaneraColors.tertiaryText)
                            }
                        }
                    }
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Requests")
        .task {
            requests = (try? await environment.apiClient.fetchConciergeRequests()) ?? []
        }
    }
}
