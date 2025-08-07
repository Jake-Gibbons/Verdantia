import SwiftUI
import SwiftData

@main
struct VerdantiaApp: App {
    init() {
        preloadPlantsIfNeeded()
    }
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack { PlantListView() }
                    .tabItem { Label("Encyclopedia", systemImage: "leaf") }
                NavigationStack { MyGardenView() }
                    .tabItem { Label("My Garden", systemImage: "heart.fill") }
                NavigationStack { WateringScheduleView() }
                    .tabItem { Label("Calendar", systemImage: "calendar") }
            }
        }
        .modelContainer(for: SavedPlant.self)
    }

    /// Fetch all plant data in the background on first launch and cache it for future runs.
    private func preloadPlantsIfNeeded() {
        let cache = PlantCache.shared
        guard !cache.hasCache else { return }

        Task.detached {
            var page = 1
            var all: [APIPlant] = []

            do {
                while true {
                    let fetched = try await PlantAPIService.shared.fetchPlants(page: page)
                    guard !fetched.isEmpty else { break }
                    all += fetched
                    page += 1
                }
                cache.save(all)
            } catch {
                print("Failed to preload plants: \(error)")
            }
        }
    }
}

#Preview {
    PlantListView()
}

#Preview{
    MyGardenView()
}

#Preview{
    WateringScheduleView()
}
