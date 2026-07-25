import SwiftUI
import SwiftData

/// Persisted voice transcript archive.
struct ConciergeArchiveView: View {
    @Query(sort: \ConciergeTranscriptEntry.createdAt, order: .reverse) private var entries: [ConciergeTranscriptEntry]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VelaneraSpacing.md) {
                Text("Transcript Archive")
                    .font(VelaneraTypography.title(32))
                    .foregroundStyle(VelaneraColors.ivory)

                if entries.isEmpty {
                    EmptyStateView(
                        title: "No transcripts yet",
                        message: "Your voice history with the concierge will appear here.",
                        systemImage: "waveform"
                    )
                } else {
                    TranscriptHistoryView(messages: entries.map(\.asMessage).reversed())
                }
            }
            .pagePadding()
            .padding(.bottom, 100)
        }
        .background(VelaneraColors.ambientGradient.ignoresSafeArea())
        .navigationTitle("Archive")
    }
}
