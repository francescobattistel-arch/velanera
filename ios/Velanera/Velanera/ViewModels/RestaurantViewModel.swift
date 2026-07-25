import Foundation
import Observation
import SwiftData

/// Digital menu state for the Restaurant tab.
@Observable
@MainActor
final class RestaurantViewModel {
    private let apiClient: APIClientProtocol

    var items: [MenuItem] = []
    var selectedCategory: MenuItem.Category = .mains
    var isLoading = false
    var errorMessage: String?

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    var filteredItems: [MenuItem] {
        items.filter { $0.category == selectedCategory }
    }

    var chefRecommendations: [MenuItem] {
        items.filter(\.isChefRecommendation)
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            items = try await apiClient.fetchMenu()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func toggleFavourite(_ item: MenuItem, modelContext: ModelContext) {
        let targetID = item.id
        let descriptor = FetchDescriptor<FavouriteDish>(
            predicate: #Predicate { $0.dishID == targetID }
        )
        if let existing = try? modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
        } else {
            modelContext.insert(FavouriteDish(dishID: item.id, name: item.name))
        }
    }
}
