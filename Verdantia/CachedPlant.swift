import Foundation
import SwiftData

/// A persistent model representing a plant downloaded from the API.
@Model
class CachedPlant {
    var id: Int
    var commonName: String
    var scientificName: String
    var imageUrl: String
    var watering: String?

    init(id: Int, commonName: String, scientificName: String, imageUrl: String, watering: String?) {
        self.id = id
        self.commonName = commonName
        self.scientificName = scientificName
        self.imageUrl = imageUrl
        self.watering = watering
    }
}
