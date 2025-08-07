import Foundation

class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    @Published var targetPlantPID: String?

    func navigateToPlant(pid: String) {
        targetPlantPID = pid
    }
}
