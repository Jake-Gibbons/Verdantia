import Foundation
import UserNotifications

// MARK: - NotificationManager
class NotificationManager {
    static let shared = NotificationManager()
    private init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func scheduleReminder(for plant: SavedPlant) {
        guard let date = plant.lastWatered else { return }
        let triggerDate = Calendar.current.date(byAdding: .day, value: plant.wateringIntervalDays, to: date) ?? Date()
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: triggerDate)

        let content = UNMutableNotificationContent()
        content.title = "Water \(plant.commonName)"
        content.body = "Reminder to water your \(plant.commonName)."

        let request = UNNotificationRequest(
            identifier: "\(plant.id)",
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }
}

