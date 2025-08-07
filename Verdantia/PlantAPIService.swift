import Foundation

// MARK: - API Service

/// Errors that can occur while fetching plants.
enum PlantAPIServiceError: LocalizedError {
    /// The API key is missing or still set to the default placeholder.
    case missingAPIKey
    /// The server responded with an unexpected HTTP status code.
    case invalidResponse(statusCode: Int)
    /// The server is rate‑limiting requests (HTTP 429).  Optionally includes a retry‑after interval in seconds.
    case rateLimited(retryAfter: TimeInterval?)

    /// Human‑readable error descriptions for each error case.
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "The API key is missing or invalid. Please add your Perenual API key to Info.plist."
        case .invalidResponse(let statusCode):
            return "Unexpected response from the server (HTTP \(statusCode))."
        case .rateLimited(let retryAfter):
            if let retryAfter = retryAfter {
                return "You are making requests too quickly. Please wait \(Int(retryAfter)) seconds and try again."
            } else {
                return "The server is rate‑limiting requests. Please wait and try again later."
            }
        }
    }
}

final class PlantAPIService {
    static let shared = PlantAPIService()
<<<<<<< Updated upstream
    private let session: URLSession
    private let apiKey = "YOUR_API_KEY"

    private init(session: URLSession = .shared) {
        self.session = session
    }
=======
    private init() {}
>>>>>>> Stashed changes

    /// Reads the Perenual API key from the app's Info.plist.  Throws an error if the key
    /// is missing or set to the default placeholder value.
    private func getApiKey() throws -> String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "PerenualAPIKey") as? String,
              !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              key != "YOUR_API_KEY" else {
            throw PlantAPIServiceError.missingAPIKey
        }
        return key
    }

    /// Fetches a page of plants from the Perenual API.
    /// - Parameters:
    ///   - page: The page number to request.
    ///   - query: Optional search query to filter results.
    /// - Returns: An array of `APIPlant` models on success.
    func fetchPlants(page: Int = 1, query: String = "") async throws -> [APIPlant] {
<<<<<<< Updated upstream
        var components = URLComponents(string: "https://perenual.com/api/species-list")!
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "key", value: apiKey)
        ]

        if !query.isEmpty {
            components.queryItems?.append(URLQueryItem(name: "q", value: query))
=======
        // Retrieve the API key, throwing an error if it's missing
        let apiKey = try getApiKey()

        // Construct the URL safely using URLComponents
        var components = URLComponents(string: "https://perenual.com/api/species-list")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "key", value: apiKey)
        ]
        if !query.isEmpty {
            queryItems.append(URLQueryItem(name: "q", value: query))
>>>>>>> Stashed changes
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw URLError(.badURL)
        }

<<<<<<< Updated upstream
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
=======
        // Perform the network request
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))

        // Validate the HTTP status code, handling rate limits separately
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200...299:
                break // OK
            case 429:
                // Extract optional Retry‑After header (seconds)
                let retryAfterString = httpResponse.value(forHTTPHeaderField: "Retry-After")
                let retryAfter = retryAfterString.flatMap(Double.init)
                throw PlantAPIServiceError.rateLimited(retryAfter: retryAfter)
            default:
                throw PlantAPIServiceError.invalidResponse(statusCode: httpResponse.statusCode)
            }
>>>>>>> Stashed changes
        }

        #if DEBUG
        // Print the raw JSON response during development for easier debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("🔎 Raw API Response:\n\(jsonString)")
        }
        #endif

        // Decode the JSON response
        let decoded = try JSONDecoder().decode(APIPlantListResponse.self, from: data)
        return decoded.data
    }
}
