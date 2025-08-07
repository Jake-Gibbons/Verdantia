import Foundation
import SwiftData

@MainActor
final class OpenPlantbookViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [PlantSummary] = []
    @Published var selectedDetail: OBPPlantDetail?
    @Published var isLoading = false
    @Published var error: Error?

    func performSearch() async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        error = nil
        do {
            results = try await OpenPlantbookService.shared.searchPlants(alias: query)
        } catch {
            self.error = error
        }
        isLoading = false
    }

    func loadDetail(for plant: PlantSummary, context: ModelContext) async {
        isLoading = true
        error = nil

        let descriptor = FetchDescriptor<CachedOPBPlant>(
            predicate: #Predicate<CachedOPBPlant> { cached in
                cached.pid == plant.pid
            }
        )

        if let cached = try? context.fetch(descriptor).first {
            self.selectedDetail = OBPPlantDetail(
                pid: cached.pid,
                display_pid: cached.display_pid,
                alias: cached.alias,
                max_light_lux; nil,
                min_light_lux; nil,
                                                 max_temp; cached.maxTemp.map { Double($0) },
                                                 min_temp; cached.minTemp.map { Double($0) },
                                                 max_env_humid; cached.maxHumidity.map { Double($0) },
                                                 min_env_humid; cached.minHumidity.map { Double($0) },
                                                 max_soil_moist; nil,
                                                 min_soil_moist; nil,
                                                 max_soil_ec; nil,
                                                 min_soil_ec; nil,
                                                 image_url; cached.imageUrl
            )
            isLoading = false
            return
        }

        do {
            let detail = try await OpenPlantbookService.shared.fetchPlantDetail(pid: plant.pid)
            self.selectedDetail = detail

            let cached = CachedOPBPlant(
                pid: detail.pid,
                alias: detail.alias,
                display_pid: detail.display_pid,
                imageUrl: detail.image_url,
                minTemp: detail.min_temp.map { Int($0) },
                maxTemp: detail.max_temp.map { Int($0) },
                minHumidity: detail.min_env_humid.map { Int($0) },
                maxHumidity: detail.max_env_humid.map { Int($0) }
            )
            context.insert(cached)
            try? context.save()
        } catch {
            self.error = error
        }

        isLoading = false
    }
}
