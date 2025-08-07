import Foundation

struct PlantSummary: Identifiable, Codable, Hashable {
    var id: String { pid }
    let pid: String
    let display_pid: String
    let alias: String
}