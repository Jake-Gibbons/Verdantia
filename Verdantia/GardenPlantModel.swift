import Foundation
import SwiftData

@Model
class GardenPlant: Identifiable {
    @Attribute(.unique) var pid: String
    var displayName: String
    var imageUrl: String?
    var remindersEnabled: Bool = true

    var wateringFrequencyDays: Int = 3
    var lastWatered: Date?

    var weedCheckFrequencyDays: Int = 14
    var lastWeedCheck: Date?

    var pestCheckFrequencyDays: Int = 10
    var lastPestCheck: Date?

    init(pid: String, displayName: String, imageUrl: String? = nil) {
        self.pid = pid
        self.displayName = displayName
        self.imageUrl = imageUrl
    }
}
