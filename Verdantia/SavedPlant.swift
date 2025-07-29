import Foundation
import SwiftData

// MARK: - SwiftData Model
@Model
class SavedPlant {
    @Attribute(.unique) var id: Int
    var commonName: String
    var scientificName: String
    var imageUrl: String
    var wateringIntervalDays: Int
    var lastWatered: Date?
    var notes: String = ""

    init(id: Int, commonName: String, scientificName: String, imageUrl: String, wateringIntervalDays: Int) {
        self.id = id
        self.commonName = commonName
        self.scientificName = scientificName
        self.imageUrl = imageUrl
        self.wateringIntervalDays = wateringIntervalDays
    }
}

