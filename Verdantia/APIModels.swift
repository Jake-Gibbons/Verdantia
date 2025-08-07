import Foundation

/// Top-level response for the Perenual API.
/// The API can include other keys (pagination, etc.), but extra keys are ignored.
struct APIPlantListResponse: Codable {
    let data: [APIPlant]?
}

/// Represents a single plant returned from the API.
/// Many fields in the API can be `null`, so they are declared as optional.
/// This prevents decoding errors when the server omits a value.
struct APIPlant: Codable, Identifiable {
    let id: Int
    let common_name: String?
    let scientific_name: [String]?   // ← change to array
    let watering: String?
    let default_image: APIPlantImage?

    struct APIPlantImage: Codable {
        let original_url: String?
    }
}
