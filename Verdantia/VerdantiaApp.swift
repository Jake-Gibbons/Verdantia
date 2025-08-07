import SwiftUI

@main
struct VerdantiaApp: App {
    init() {
        preloadPlantsIfNeeded()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(NavigationManager.shared)
                .onReceive(NotificationCenter.default.publisher(for: .navigateToPlantDetail)) { notification in
                    if let pid = notification.object as? String {
                        NavigationManager.shared.navigateToPlant(pid: pid)
                    }
                }
        }
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
    ContentView()
}
