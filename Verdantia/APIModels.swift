import Foundation

struct APIPlantListResponse: Decodable {
    let data: [APIPlant]
}

struct APIPlant: Decodable, Identifiable {
    let id: Int
    let common_name: String
    let scientific_name: String
    let watering: String
    let default_image: APIPlantImage?

    struct APIPlantImage: Decodable {
        let original_url: String?
    }
}
