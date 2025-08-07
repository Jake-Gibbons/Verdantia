import Foundation
import UserNotifications

/// A singleton responsible for requesting notification permissions and
/// scheduling local reminders. Interacts with `UNUserNotificationCenter` to
/// deliver alerts when it's time to water a plant.
final class NotificationManager {
static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()

    private init() {
        // Request authorization on initialisation. Errors are ignored here but
        // could be surfaced to the UI if more granular control is required.
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    /// Schedules a reminder for the next watering date of the given plant. If
    /// the plant has never been watered (i.e. `lastWatered` is `nil`), the
    /// method returns without scheduling a notification.
    func scheduleReminder(for plant: SavedPlant) {
        guard let date = plant.lastWatered else { return }
        guard let triggerDate = Calendar.current.date(byAdding: .day,
                                                      value: plant.wateringIntervalDays,
                                                      to: date) else { return }
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: triggerDate)

        // Clear the minute and second components to schedule the notification on the hour.
        components.minute = 0
        components.second = 0

        let content = UNMutableNotificationContent()
        content.title = "Water \(plant.commonName)"
        content.body = "Reminder to water your \(plant.commonName)."

        let request = UNNotificationRequest(
            identifier: "water_\(plant.id)",
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        )
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
}
