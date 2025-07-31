import Foundation
import Combine

/// ViewModel responsible for managing the list of plants returned from the
/// Perenual API and converting API models into local saved plants. This
/// implementation uses Swift concurrency to asynchronously load data and
/// exposes published properties to notify SwiftUI views of changes.
@MainActor
final class PlantViewModel: ObservableObject {

    /// All fetched plants for the encyclopedia. Observers receive updates when
    /// this array changes.
    @Published private(set) var plants: [APIPlant] = []

    /// Tracks whether a fetch is currently in progress. Use this to present
    /// a loading indicator in the UI.
    @Published private(set) var isLoading: Bool = false

    /// Holds the last error encountered during a fetch. When set to a non‑nil
    /// value, the UI should display an error message to the user. Resets to
    /// `nil` on a successful fetch.
    @Published private(set) var error: Error? = nil

    /// The current page of results that has been loaded. Starts at 1. When
    /// additional pages are needed (e.g. implementing infinite scroll) this
    /// value can be incremented.
    private var currentPage: Int = 1

    /// Fetches plants from the API and updates published properties. Existing
    /// plants will be replaced; to append new results you could change the
    /// assignment to an append inside this method.
    func loadPlants() async {
        isLoading = true
        error = nil
        do {
            let fetched = try await PlantAPIService.shared.fetchPlants(page: currentPage)
            self.plants = fetched
        } catch {
            // Capture the error for the UI to consume.
            self.error = error
        }
        isLoading = false
    }

    /// Converts an ``APIPlant`` returned from the API into a ``SavedPlant``
    /// instance for persistence. This method centralises the logic for mapping
    /// remote fields to local storage fields.
    func convertToSavedPlant(from apiPlant: APIPlant) -> SavedPlant {
        SavedPlant(
            id: apiPlant.id,
            commonName: apiPlant.common_name,
            scientificName: apiPlant.scientific_name,
            imageUrl: apiPlant.default_image?.original_url ?? "",
            wateringIntervalDays: wateringInterval(for: apiPlant)
        )
    }

    /// Computes a watering interval based on the API's watering string. If the
    /// API returns an unexpected value a sensible default is returned.
    private func wateringInterval(for plant: APIPlant) -> Int {
        switch plant.watering.lowercased() {
        case "frequent":
            return 2
        case "average":
            return 4
        case "minimum":
            return 7
        default:
            return 5
        }
    }
}