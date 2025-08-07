import Foundation
import SwiftData

@Model
final class CachedOPBPlant {
    var pid: String
    var alias: String
    var display_pid: String
    var imageUrl: String?
    var minTemp: Int?
    var maxTemp: Int?
    var minHumidity: Int?
    var maxHumidity: Int?
    var isFavourite: Bool

    init(pid: String, alias: String, display_pid: String, imageUrl: String?, minTemp: Int?, maxTemp: Int?, minHumidity: Int?, maxHumidity: Int?, isFavourite: Bool = false) {
        self.pid = pid
        self.alias = alias
        self.display_pid = display_pid
        self.imageUrl = imageUrl
        self.minTemp = minTemp
        self.maxTemp = maxTemp
        self.minHumidity = minHumidity
        self.maxHumidity = maxHumidity
        self.isFavourite = isFavourite
    }
}