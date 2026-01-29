//
//  NotificationManager.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }

    func scheduleReminder(for activity: Activity) {
        guard activity.reminderEnabled,
              let reminderType = activity.reminderType else {
            return
        }

        // Cancel any existing reminder first
        cancelReminder(for: activity)

        let content = UNMutableNotificationContent()
        content.title = gentleTitle(for: activity)
        content.body = gentleBody(for: activity)
        content.sound = .default

        var triggerDate: Date?

        switch reminderType {
        case .oneTime:
            triggerDate = activity.reminderDate
        case .recurring:
            if let intervalDays = activity.reminderIntervalDays {
                // Use lastCompletedDate if available, otherwise fall back to createdDate
                // This allows newly imported activities to have working reminders
                let baseDate = activity.lastCompletedDate ?? activity.createdDate
                triggerDate = Calendar.current.date(byAdding: .day, value: intervalDays, to: baseDate)
            }
        }

        guard let date = triggerDate, date > Date() else {
            return
        }

        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let notificationID = UUID().uuidString
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }

        // Store the notification ID so we can cancel it later
        activity.reminderNotificationID = notificationID
    }

    func cancelReminder(for activity: Activity) {
        guard let notificationID = activity.reminderNotificationID else {
            return
        }

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
        activity.reminderNotificationID = nil
    }

    func rescheduleRecurringReminder(for activity: Activity) {
        guard activity.reminderEnabled,
              activity.reminderType == .recurring else {
            return
        }

        // Cancel old notification and schedule new one based on updated lastCompletedDate
        scheduleReminder(for: activity)
    }

    // MARK: - Gentle Reminder Copy

    private func gentleTitle(for activity: Activity) -> String {
        SoftLanguage.Reminders.gentleTitles.randomElement() ?? "Reminder"
    }

    private func gentleBody(for activity: Activity) -> String {
        SoftLanguage.Reminders.bodyMessage(
            for: activity.name,
            daysSince: activity.daysSinceLastCompleted
        )
    }
}
