import SwiftUI

/// Venue-wide events list with kind filters.
struct EventsView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var viewModel: EventsViewModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
                Text("Events")
                    .font(VelaneraTypography.title(34))
                    .foregroundStyle(VelaneraColors.ivory)
                Text("Dining, music, tastings, and members' evenings.")
                    .font(VelaneraTypography.body(15))
                    .foregroundStyle(VelaneraColors.secondaryText)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterChip(title: "All", selected: viewModel?.selectedKind == nil) {
                            viewModel?.selectedKind = nil
                        }
                        ForEach(VenueEvent.Kind.allCases, id: \.self) { kind in
                            filterChip(title: kind.displayName, selected: viewModel?.selectedKind == kind) {
                                viewModel?.selectedKind = kind
                            }
                        }
                    }
                }

                if viewModel?.isLoading == true {
                    LoadingSkeletonList()
                } else {
                    ForEach(viewModel?.filteredEvents ?? []) { event in
                        NavigationLink(value: AppDestination.eventDetail(event.id)) {
                            EventCard(event: event)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Events")
        .task {
            if viewModel == nil {
                viewModel = EventsViewModel(
                    apiClient: environment.apiClient,
                    analytics: environment.analyticsService
                )
            }
            await viewModel?.load()
        }
    }

    private func filterChip(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(VelaneraTypography.label(11))
                .foregroundStyle(selected ? VelaneraColors.matteBlack : VelaneraColors.champagne)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Capsule().fill(selected ? VelaneraColors.gold : VelaneraColors.elevated))
        }
        .buttonStyle(.plain)
    }
}
