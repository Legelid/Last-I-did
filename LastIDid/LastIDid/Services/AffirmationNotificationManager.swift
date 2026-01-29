//
//  AffirmationNotificationManager.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/23/26.
//

import Foundation
import UserNotifications
import SwiftUI

/// Manages daily affirmation notifications with supportive messages
class AffirmationNotificationManager: ObservableObject {
    static let shared = AffirmationNotificationManager()

    private let notificationCenter = UNUserNotificationCenter.current()
    private let userDefaults = UserDefaults.standard
    private let notificationIdentifier = "dailyAffirmation"

    // MARK: - Published Properties

    @AppStorage(AppPreferenceKey.affirmationNotificationsEnabled) var isEnabled = false {
        didSet {
            if isEnabled {
                scheduleDaily()
            } else {
                cancelDaily()
            }
        }
    }

    @AppStorage(AppPreferenceKey.affirmationHour) var preferredHour: Int = 18 // 6 PM default
    @AppStorage(AppPreferenceKey.affirmationMinute) var preferredMinute: Int = 0

    private init() {}

    // MARK: - Daily Affirmation Messages

    private let dailyMessages = [
        "You're doing better than you think.",
        "Small efforts add up over time.",
        "Awareness itself is valuable.",
        "Taking care of things takes care of you.",
        "You're showing up, and that matters.",
        "Progress happens one step at a time.",
        "Being mindful is its own reward.",
        "You're handling things well.",
        "Every little bit counts.",
        "Trust your own pace."
    ]

    private let personalizedMessages = [
        "%@, you're doing better than you think.",
        "%@, small efforts add up over time.",
        "%@, awareness itself is valuable.",
        "%@, you're showing up, and that matters.",
        "%@, trust your own pace."
    ]

    // MARK: - Public API

    /// Schedule daily affirmation notification
    func scheduleDaily() {
        guard isEnabled else { return }

        // Cancel existing to avoid duplicates
        cancelDaily()

        // Check if we should send (only if app used within 7 days)
        guard shouldSendToday() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Daily Reflection"
        content.body = selectMessage()
        content.sound = .default

        // Create trigger for preferred time
        var dateComponents = DateComponents()
        dateComponents.hour = preferredHour
        dateComponents.minute = preferredMinute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling affirmation notification: \(error)")
            }
        }
    }

    /// Cancel daily affirmation notification
    func cancelDaily() {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [notificationIdentifier]
        )
    }

    /// Check if notification should be sent (only if app used within 7 days)
    func shouldSendToday() -> Bool {
        guard let lastAppOpen = userDefaults.object(forKey: AppPreferenceKey.lastAppOpen) as? Date else {
            // If never opened, don't send
            return false
        }

        let daysSinceOpen = Calendar.current.dateComponents(
            [.day],
            from: lastAppOpen,
            to: Date()
        ).day ?? Int.max

        return daysSinceOpen <= 7
    }

    /// Update preferred notification time
    func updateTime(hour: Int, minute: Int) {
        preferredHour = hour
        preferredMinute = minute

        if isEnabled {
            scheduleDaily()
        }
    }

    /// Record app open for activity tracking
    func recordAppOpen() {
        userDefaults.set(Date(), forKey: AppPreferenceKey.lastAppOpen)
    }

    // MARK: - Private Helpers

    private func selectMessage() -> String {
        // Get user name for potential personalization
        let userName = userDefaults.string(forKey: "userName")

        // 30% chance to personalize with name
        if let name = userName, !name.isEmpty, Double.random(in: 0...1) < 0.3 {
            let template = personalizedMessages.randomElement() ?? "%@, you're doing better than you think."
            return String(format: template, name)
        }

        return dailyMessages.randomElement() ?? "You're doing better than you think."
    }
}
