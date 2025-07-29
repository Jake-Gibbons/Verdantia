import Foundation

class PlantAPIService {
    private let apiKey = "sk-iJQs6887e13964f7c11602"
    private let baseURL = "https://perenual.com/api/species-list"

    func fetchPlants(page: Int = 1, completion: @escaping (Result<[APIPlant], Error>) -> Void) {
        guard var urlComponents = URLComponents(string: baseURL) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "page", value: "\(page)")
        ]

        guard let url = urlComponents.url else {
            completion(.failure(URLError(.badURL)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(URLError(.badServerResponse))) }
                return
            }

            do {
                let result = try JSONDecoder().decode(APIPlantListResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(result.data))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
