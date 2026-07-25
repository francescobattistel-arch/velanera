import Foundation
import Observation
import SwiftData

/// Digital menu state for the Restaurant tab.
@Observable
@MainActor
final class RestaurantViewModel {
    private let apiClient: APIClientProtocol

    var items: [MenuItem] = []
    var chef: ChefProfile?
    var selectedCategory: MenuItem.Category = .mains
    var searchText: String = ""
    var allergenFilter: Set<Allergen> = []
    var favouriteIDs: Set<UUID> = []
    var isLoading = false
    var errorMessage: String?

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    var filteredItems: [MenuItem] {
        items
            .filter { $0.category == selectedCategory }
            .filter { item in
                guard !searchText.isEmpty else { return true }
                let query = searchText.lowercased()
                return item.name.lowercased().contains(query)
                    || item.description.lowercased().contains(query)
            }
            .filter { item in
                guard !allergenFilter.isEmpty else { return true }
                return allergenFilter.isDisjoint(with: Set(item.allergens))
            }
    }

    var chefRecommendations: [MenuItem] {
        items.filter(\.isChefRecommendation)
    }

    var wines: [MenuItem] { items.filter(\.isWine) }
    var cocktails: [MenuItem] { items.filter(\.isCocktail) }
    var desserts: [MenuItem] { items.filter { $0.category == .desserts } }

    func load(modelContext: ModelContext? = nil) async {
        isLoading = true
        errorMessage = nil
        do {
            async let menu = apiClient.fetchMenu()
            async let chefProfile = apiClient.fetchChef()
            items = try await menu
            chef = try await chefProfile
            if let modelContext {
                refreshFavourites(modelContext: modelContext)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func refreshFavourites(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<FavouriteDish>()
        let saved = (try? modelContext.fetch(descriptor)) ?? []
        favouriteIDs = Set(saved.map(\.dishID))
    }

    func isFavourite(_ item: MenuItem) -> Bool {
        favouriteIDs.contains(item.id)
    }

    func toggleFavourite(_ item: MenuItem, modelContext: ModelContext) {
        let targetID = item.id
        let descriptor = FetchDescriptor<FavouriteDish>(
            predicate: #Predicate { $0.dishID == targetID }
        )
        if let existing = try? modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
            favouriteIDs.remove(item.id)
        } else {
            modelContext.insert(FavouriteDish(dishID: item.id, name: item.name))
            favouriteIDs.insert(item.id)
        }
        HapticFeedback.light()
    }
}
