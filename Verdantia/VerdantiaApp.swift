import SwiftUI

@main
struct VerdantiaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

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
}

#Preview {
    ContentView()
}
