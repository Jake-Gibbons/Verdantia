import Foundation

/// Handles persistence of the plant encyclopedia data.
final class PlantCache {
    static let shared = PlantCache()

    private let fileURL: URL
    private init() {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = directory.appendingPathComponent("plants.json")
    }

    /// Whether a cached file already exists on disk.
    var hasCache: Bool {
        FileManager.default.fileExists(atPath: fileURL.path)
    }

    /// Load the cached list of plants, if available.
    func load() -> [APIPlant]? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode([APIPlant].self, from: data)
    }

    /// Save plants to disk on a background thread.
    func save(_ plants: [APIPlant]) {
        DispatchQueue.global(qos: .background).async {
            guard let data = try? JSONEncoder().encode(plants) else { return }
            try? data.write(to: self.fileURL)
        }
    }
}
