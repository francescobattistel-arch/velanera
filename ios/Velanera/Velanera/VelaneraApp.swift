import SwiftUI
import SwiftData

/// Application entry point for the Velanera guest experience.
@main
struct VelaneraApp: App {
    @State private var appEnvironment = AppEnvironment.live

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PersistedReservation.self,
            FavouriteDish.self,
            ConciergeTranscriptEntry.self,
            PersistedUserProfile.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(appEnvironment)
                .preferredColorScheme(.dark)
                .tint(VelaneraColors.gold)
        }
        .modelContainer(sharedModelContainer)
    }
}
