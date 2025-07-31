import Foundation

/// A service responsible for communicating with the Perenual plant API.
///
/// The API key is loaded lazily from the application's `Info.plist` via the
/// `PerenualAPIKey` key. Storing secrets in your source code is insecure; by
/// moving the key into your app's bundle you can configure it per‑target and
/// avoid accidentally committing it to version control.  Add your API key to
/// the project's `Info.plist` (or via an XCConfig) under the `PerenualAPIKey`
/// entry before building for release.
@MainActor
final class PlantAPIService {

    /// Shared singleton instance used by view models. Because this class
    /// maintains no state, a single shared instance is sufficient for the
    /// lifetime of the application.
    static let shared = PlantAPIService()

    /// The base URL for the Perenual API.
    private let baseURL = URL(string: "https://perenual.com/api/species-list")!

    /// Lazily retrieved API key. If this value is missing or empty the
    /// application will assert at runtime. Do not commit your API key into
    /// source control; instead add it to your Info.plist under
    /// `PerenualAPIKey`.
    private var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "PerenualAPIKey") as? String,
              !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fatalError("Missing `PerenualAPIKey` in Info.plist. Add your API key before running.")
        }
        return key
    }

    /// Fetches a page of plants from the Perenual API.
    ///
    /// - Parameter page: The page number to request. Perenual paginates results.
    /// - Returns: An array of ``APIPlant`` models on success.
    /// - Throws: A ``URLError`` or decoding error if the request fails.
    func fetchPlants(page: Int = 1) async throws -> [APIPlant] {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "page", value: String(page))
        ]
        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        // Basic response validation: ensure a 200 OK is returned.
        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(APIPlantListResponse.self, from: data)
        return decoded.data
    }
}