import Foundation
import Combine

@MainActor
class PlantViewModel: ObservableObject {
    @Published var allPlants: [APIPlant] = []

    func loadPlants() {
        self.allPlants = [
            APIPlant(
                id: 1,
                common_name: "Basil",
                scientific_name: "Ocimum basilicum",
                watering: "average",
                default_image: APIPlant.APIPlantImage(original_url: "")
            ),
            APIPlant(
                id: 2,
                common_name: "Tomato",
                scientific_name: "Solanum lycopersicum",
                watering: "frequent",
                default_image: APIPlant.APIPlantImage(original_url: "")
            ),
            APIPlant(
                id: 3,
                common_name: "Lavender",
                scientific_name: "Lavandula",
                watering: "minimum",
                default_image: APIPlant.APIPlantImage(original_url: "")
            )
        ]
    }

    func convertToSavedPlant(from apiPlant: APIPlant) -> SavedPlant {
        SavedPlant(
            id: apiPlant.id,
            commonName: apiPlant.common_name,
            scientificName: apiPlant.scientific_name,
            imageUrl: apiPlant.default_image?.original_url ?? "",
            wateringIntervalDays: wateringInterval(for: apiPlant)
        )
    }

    private func wateringInterval(for plant: APIPlant) -> Int {
        switch plant.watering.lowercased() {
        case "frequent": return 2
        case "average": return 4
        case "minimum": return 7
        default: return 5
        }
    }
}
