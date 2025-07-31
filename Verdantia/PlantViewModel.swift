import Foundation
import Combine

/// ViewModel responsible for fetching plants and exposing them to the UI.
final class PlantViewModel: ObservableObject {
    @Published private(set) var plants: [APIPlant] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    private var currentPage = 1

    /// Loads plants asynchronously and updates published properties on the main actor.
    @MainActor
    func loadPlants() async {
        isLoading = true
        error = nil
        do {
            let fetched = try await PlantAPIService.shared.fetchPlants(page: currentPage)
            plants = fetched
        } catch let decodingError as DecodingError {
            print("Decoding error: \(decodingError)")
            self.error = decodingError
        } catch {
            // Rename the caught error to avoid shadowing the property.
            let genericError = error
            self.error = genericError
        }
        isLoading = false
    }

    func convertToSavedPlant(from apiPlant: APIPlant) -> SavedPlant {
        SavedPlant(
            id: apiPlant.id,
            commonName: apiPlant.common_name ?? "Unknown",
            scientificName: apiPlant.scientific_name ?? "",
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
