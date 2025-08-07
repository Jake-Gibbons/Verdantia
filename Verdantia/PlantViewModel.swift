import Foundation
import Combine

@MainActor
final class PlantViewModel: ObservableObject {
    @Published private(set) var plants: [APIPlant] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    private let cache = PlantCache.shared
    private var allCachedPlants: [APIPlant]?

    private var currentPage = 1
    private var canLoadMore = true
    private var isFetching = false
    private var currentSearchQuery = ""

    init() {
        if let cached = cache.load() {
            allCachedPlants = cached
            plants = cached
            canLoadMore = false
        }
    }

    func loadNextPageIfNeeded(currentItem: APIPlant?, query: String = "") async {
        guard allCachedPlants == nil else { return }
        guard let currentItem = currentItem else {
            await loadNextPage(query: query)
            return
        }

        let thresholdIndex = max(plants.count - 5, 0)
        if let index = plants.firstIndex(where: { $0.id == currentItem.id }),
           index >= thresholdIndex {
            await loadNextPage(query: query)
        }
    }

    /// Search locally when cache is available, otherwise fall back to remote loading.
    func search(query: String = "") async {
        if let cached = allCachedPlants {
            isLoading = false
            currentSearchQuery = query
            if query.isEmpty {
                plants = cached
            } else {
                let lower = query.lowercased()
                plants = cached.filter {
                    ($0.common_name?.lowercased().contains(lower) ?? false) ||
                    ($0.scientific_name?.joined(separator: " ").lowercased().contains(lower) ?? false)
                }
            }
        } else {

            await loadNextPage(query: query)
        }
    }

    func loadNextPage(query: String = "") async {
        guard !isFetching && canLoadMore else { return }
        isFetching = true
        isLoading = true
        error = nil

        // Reset pagination if the query changed
        if query != currentSearchQuery {
            currentSearchQuery = query
            currentPage = 1
            plants = []
            canLoadMore = true
        }

        do {
            let fetched = try await PlantAPIService.shared.fetchPlants(page: currentPage, query: query)
            if fetched.isEmpty {
                canLoadMore = false
            } else {
                plants += fetched
                currentPage += 1
            }
        } catch {
            self.error = error
        }

        isFetching = false
        isLoading = false
    }

    func convertToSavedPlant(from apiPlant: APIPlant) -> SavedPlant {
        SavedPlant(
            id: apiPlant.id,
            commonName: apiPlant.common_name ?? "Unknown",
            scientificName: apiPlant.scientific_name?.joined(separator: ", ") ?? "",
            imageUrl: apiPlant.default_image?.original_url ?? "",
            wateringIntervalDays: wateringInterval(for: apiPlant)
        )
    }

    private func wateringInterval(for plant: APIPlant) -> Int {
        switch plant.watering?.lowercased() {
        case "frequent": return 2
        case "average": return 4
        case "minimum": return 7
        default: return 5
        }
    }
}
