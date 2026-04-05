//
//  NotificationService.swift
//  Safham
//

import UserNotifications
import SwiftData

class NotificationService {
    static let shared = NotificationService()

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func scheduleDailyReminder(hour: Int, minute: Int, dueCount: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["safham.daily"])

        let content = UNMutableNotificationContent()
        content.title = "سأفهم — Safham"
        let minutes = max(5, dueCount * 2)
        content.body = "\(dueCount) words due today. ~\(minutes) minutes."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "safham.daily", content: content, trigger: trigger)

        center.add(request)
    }

    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["safham.daily"])
    }

    /// Update the streak / badge count on the app icon.
    func updateBadge(count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(count) { _ in }
    }
}
