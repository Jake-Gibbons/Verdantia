import SwiftUI
import SwiftData

@main
struct VerdantiaApp: App {
    var body: some Scene {
        WindowGroup {
            OpenPlantbookSearchView()
        }
        .modelContainer(for: [CachedOPBPlant.self, GardenPlant.self])
    }
}
