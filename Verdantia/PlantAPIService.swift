import Foundation

// MARK: - API Service

final class PlantAPIService {
    static let shared = PlantAPIService()
    private let session: URLSession
    private let apiKey = "YOUR_API_KEY"

    private init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPlants(page: Int = 1, query: String = "") async throws -> [APIPlant] {
        var components = URLComponents(string: "https://perenual.com/api/species-list")!
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "key", value: apiKey)
        ]

        if !query.isEmpty {
            components.queryItems?.append(URLQueryItem(name: "q", value: query))
        }

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        #if DEBUG
        if let jsonString = String(data: data, encoding: .utf8) {
            print("🔎 Raw API Response:\n\(jsonString)")
        }
        #endif

        let decoded = try JSONDecoder().decode(APIPlantListResponse.self, from: data)
        return decoded.data ?? []
    }
}
