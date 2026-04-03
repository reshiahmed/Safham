import Foundation
import UserNotifications

@MainActor
final class ReminderService {
    private let center: UNUserNotificationCenter
    private let identifier = "daily-review-reminder"

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func syncReminder(settings: AppSettings, dueCount: Int, estimatedMinutes: Int) async {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        guard settings.reminder.enabled else {
            return
        }

        let granted = await requestAuthorization()
        guard granted else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Safham"
        content.body = "\(dueCount) words due today. ~\(estimatedMinutes) minutes."
        content.sound = .default

        var components = DateComponents()
        components.hour = settings.reminder.hour
        components.minute = settings.reminder.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        await addNotification(request)
    }

    private func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }

    private func addNotification(_ request: UNNotificationRequest) async {
        await withCheckedContinuation { continuation in
            center.add(request) { _ in
                continuation.resume(returning: ())
            }
        }
    }
}
