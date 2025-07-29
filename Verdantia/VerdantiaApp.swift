import SwiftUI
import SwiftData

@main
struct VerdantiaApp: App {
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
}
