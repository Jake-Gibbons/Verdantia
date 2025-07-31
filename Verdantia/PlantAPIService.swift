import Foundation

// MARK: - API Service

final class PlantAPIService {
    static let shared = PlantAPIService()

    func fetchPlants(page: Int = 1, query: String = "") async throws -> [APIPlant] {
        var urlString = "https://perenual.com/api/species-list?page=\(page)&key=YOUR_API_KEY"
        if !query.isEmpty {
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            urlString += "&q=\(encodedQuery)"
        }

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        #if DEBUG
        if let jsonString = String(data: data, encoding: .utf8) {
            print("🔎 Raw API Response:\n\(jsonString)")
        }
        #endif

        let decoded = try JSONDecoder().decode(APIPlantListResponse.self, from: data)
        return decoded.data ?? []
    }
}
