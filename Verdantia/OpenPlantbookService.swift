import Foundation

enum OpenPlantbookError: LocalizedError {
    case missingCredentials
    case tokenFetchFailed
    case invalidResponse(code: Int)
    case noData
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "Open Plantbook client credentials are missing."
        case .tokenFetchFailed:
            return "Failed to fetch access token."
        case let .invalidResponse(code):
            return "Unexpected response from server (HTTP \(code))."
        case .noData:
            return "No data returned from server."
        case let .decodingError(err):
            return "Failed to decode response: \(err.localizedDescription)"
        }
    }
}


struct OPBPlantDetail: Decodable {
    let pid: String
    let display_pid: String
    let alias: String
    let max_light_lux: Int?
    let min_light_lux: Int?
    let max_temp: Int?
    let min_temp: Int?
    let max_env_humid: Int?
    let min_env_humid: Int?
    let max_soil_moist: Int?
    let min_soil_moist: Int?
    let max_soil_ec: Int?
    let min_soil_ec: Int?
    let image_url: String?
}

@MainActor
final class OpenPlantbookService {
    static let shared = OpenPlantbookService()
    private init() {}

    private var accessToken: String?
    private var tokenExpiry: Date?

    private func getCredentials() -> (clientId: String, clientSecret: String)? {
        guard let id = Bundle.main.object(forInfoDictionaryKey: "OPBClientID") as? String,
              let secret = Bundle.main.object(forInfoDictionaryKey: "OPBClientSecret") as? String,
              !id.isEmpty, !secret.isEmpty else {
            return nil
        }
        return (id, secret)
    }

    private func fetchToken() async throws {
        guard let creds = getCredentials() else {
            throw OpenPlantbookError.missingCredentials
        }
        let url = URL(string: "https://open.plantbook.io/api/v1/token/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "grant_type=client_credentials&client_id=\(creds.clientId)&client_secret=\(creds.clientSecret)"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw OpenPlantbookError.tokenFetchFailed
        }
        guard (200...299).contains(http.statusCode) else {
            throw OpenPlantbookError.invalidResponse(code: http.statusCode)
        }
        struct TokenResponse: Decodable {
            let access_token: String
            let expires_in: Int
        }
        let token = try JSONDecoder().decode(TokenResponse.self, from: data)
        accessToken = token.access_token
        tokenExpiry = Date().addingTimeInterval(TimeInterval(token.expires_in))
    }

    private func ensureToken() async throws {
        if accessToken == nil || (tokenExpiry != nil && Date() >= tokenExpiry!) {
            try await fetchToken()
        }
    }

    /// Searches for plants by alias (common name).
    func searchPlants(alias: String) async throws -> [PlantSummary] {
        try await ensureToken()
        guard let token = accessToken else { throw OpenPlantbookError.tokenFetchFailed }
        var comp = URLComponents(string: "https://open.plantbook.io/api/v1/plant/search")!
        comp.queryItems = [URLQueryItem(name: "alias", value: alias)]
        let request = NSMutableURLRequest(url: comp.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request as URLRequest)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw OpenPlantbookError.invalidResponse(code: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        struct SearchResponse: Decodable {
            let count: Int
            let results: [PlantSummary]
        }
        let resp = try JSONDecoder().decode(SearchResponse.self, from: data)
        return resp.results
    }

    /// Fetches detailed thresholds for a particular plant by pid.
    func fetchPlantDetail(pid: String) async throws -> PlantDetail {
        try await ensureToken()
        guard let token = accessToken else { throw OpenPlantbookError.tokenFetchFailed }
        let url = URL(string: "https://open.plantbook.io/api/v1/plant/detail/\(pid)/")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw OpenPlantbookError.invalidResponse(code: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        return try JSONDecoder().decode(PlantDetail.self, from: data)
    }
}
