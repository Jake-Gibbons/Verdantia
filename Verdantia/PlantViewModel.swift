import Foundation
import Combine
import SwiftData

@MainActor
final class PlantViewModel: ObservableObject {
    /// All plants returned by the API once the download has completed.
    @Published private(set) var plants: [APIPlant] = []
    /// Indicates whether the view model is currently downloading all pages.
    @Published private(set) var isDownloadingAll = false
    /// Holds an error if the download fails.
    @Published private(set) var error: Error?
    /// A value from 0 to 1 indicating approximate download progress.
    @Published private(set) var downloadProgress: Double = 0.0

<<<<<<< Updated upstream
    private var currentPage = 1
    private var canLoadMore = true
    private var isFetching = false
    private var currentSearchQuery = ""

    func loadNextPageIfNeeded(currentItem: APIPlant?, query: String = "") async {
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

    func loadNextPage(query: String = "") async {
        guard !isFetching && canLoadMore else { return }
        isFetching = true
        isLoading = true
=======
    /// Downloads the entire catalogue of plants.  This method fetches all pages
    /// sequentially until no more results are returned.  Each time a page is
    /// fetched, `downloadProgress` is updated.  When finished, the progress is set to 1.
    func loadAllPlants(query: String = "") async {
        // Avoid starting another download if one is already in progress.
        guard !isDownloadingAll else { return }
        isDownloadingAll = true
>>>>>>> Stashed changes
        error = nil
        downloadProgress = 0.0
        var page = 1
        var pagesFetched = 0
        plants = []

        // Continue fetching pages until the API returns an empty set.
        do {
            var hasMore = true
            while hasMore {
                let fetched = try await PlantAPIService.shared.fetchPlants(page: page, query: query)
                if fetched.isEmpty {
                    hasMore = false
                } else {
                    plants += fetched
                    pagesFetched += 1
                    // Each page contributes a smaller amount to progress (assume ~100 pages max).
                    downloadProgress = min(1.0, Double(pagesFetched) * 0.01)
                    page += 1
                }
            }
        } catch {
            // Capture any error that occurs so the view can display it
            self.error = error
        }
        // Ensure progress reaches 100% when complete
        downloadProgress = 1.0
        isDownloadingAll = false
    }

    /// Persists the downloaded plants into the on‑device database.
    /// Any previously cached plants are removed to avoid duplication.
    func persistDownloadedPlants(using context: ModelContext) async {
        // Remove existing cached plants
        let fetchDescriptor = FetchDescriptor<CachedPlant>()
        if let existing = try? context.fetch(fetchDescriptor) {
            for plant in existing {
                context.delete(plant)
            }
        }
        // Convert each APIPlant to a CachedPlant and insert it into the context
        for apiPlant in plants {
            let cached = CachedPlant(
                id: apiPlant.id,
                commonName: apiPlant.common_name ?? "Unknown",
                scientificName: apiPlant.scientific_name?.joined(separator: ", ") ?? "",
                imageUrl: apiPlant.default_image?.original_url ?? "",
                watering: apiPlant.watering
            )
            context.insert(cached)
        }
        try? context.save() // Persist changes to disk
    }

    /// Converts an `APIPlant` into a `SavedPlant` entity for favourites.
    func convertToSavedPlant(from apiPlant: APIPlant) -> SavedPlant {
        SavedPlant(
            id: apiPlant.id,
            commonName: apiPlant.common_name ?? "Unknown",
            scientificName: apiPlant.scientific_name?.joined(separator: ", ") ?? "",
            imageUrl: apiPlant.default_image?.original_url ?? "",
            wateringIntervalDays: wateringInterval(for: apiPlant)
        )
    }

    /// Returns a default watering interval (in days) for display.
    private func wateringInterval(for plant: APIPlant) -> Int {
        switch plant.watering?.lowercased() {
        case "frequent": return 2
        case "average": return 4
        case "minimum": return 7
        default: return 5
        }
    }
}
