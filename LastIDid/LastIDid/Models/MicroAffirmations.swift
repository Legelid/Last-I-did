//
//  MicroAffirmations.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import Foundation

/// Collection of micro-affirmations for celebrating completions
struct MicroAffirmations {

    // MARK: - General Completion Affirmations

    static let general: [String] = [
        "Nice work!",
        "Well done!",
        "You did it!",
        "Progress made!",
        "One step forward!",
        "Way to go!",
        "Checked off!",
        "Mission accomplished!",
        "Another one done!",
        "Keep it up!",
        "You're on it!",
        "Great job!",
        "That's the way!",
        "Solid effort!",
        "Moving forward!"
    ]

    // MARK: - Plan6 Life Care Messages

    static let lifeCare: [String] = [
        "That's one more thing taken care of.",
        "You showed up for this one.",
        "You're taking care of things.",
        "Another small win.",
        "You did the thing.",
        "You gave this attention.",
        "You followed through.",
        "Good on you for doing this.",
        "You're keeping up."
    ]

    /// Combined pool of general and life care messages
    static var allGeneral: [String] {
        general + lifeCare
    }

    // MARK: - First Time Completion

    static let firstTime: [String] = [
        "First time! Exciting!",
        "A new beginning!",
        "Off to a great start!",
        "First step taken!",
        "And so it begins!",
        "Journey started!"
    ]

    // MARK: - Streak Related

    static let streakContinued: [String] = [
        "Streak continues!",
        "On a roll!",
        "Consistency wins!",
        "Building momentum!",
        "Keeping it going!"
    ]

    static let streakMilestone: [String] = [
        "Impressive streak!",
        "Dedication showing!",
        "True commitment!",
        "Remarkable consistency!"
    ]

    // MARK: - Catching Up

    static let catchingUp: [String] = [
        "Back on track!",
        "Welcome back!",
        "Good to see you!",
        "Picking up where you left off!",
        "No time like the present!"
    ]

    // MARK: - Time-of-Day Specific

    static let morning: [String] = [
        "Great way to start the day!",
        "Morning momentum!",
        "Productive morning!"
    ]

    static let evening: [String] = [
        "Ending the day strong!",
        "Evening accomplishment!",
        "Before bed win!"
    ]

    static let weekend: [String] = [
        "Weekend warrior!",
        "Making the most of your weekend!",
        "Saturday/Sunday success!"
    ]

    // MARK: - Smart Selection

    /// Get a contextually appropriate affirmation
    static func select(
        isFirstTime: Bool = false,
        streakCount: Int = 0,
        daysSinceLastCompletion: Int = 0
    ) -> String {
        // First time completion
        if isFirstTime {
            return firstTime.randomElement() ?? general.randomElement()!
        }

        // Streak milestone (every 5)
        if streakCount > 0 && streakCount % 5 == 0 {
            return streakMilestone.randomElement() ?? general.randomElement()!
        }

        // Active streak
        if streakCount >= 2 {
            return streakContinued.randomElement() ?? general.randomElement()!
        }

        // Catching up after a while
        if daysSinceLastCompletion > 14 {
            return catchingUp.randomElement() ?? general.randomElement()!
        }

        // Time of day specific
        let hour = Calendar.current.component(.hour, from: Date())
        let isWeekend = Calendar.current.isDateInWeekend(Date())

        if isWeekend && Bool.random() {
            return weekend.randomElement() ?? general.randomElement()!
        }

        if hour < 10 && Bool.random() {
            return morning.randomElement() ?? general.randomElement()!
        }

        if hour >= 20 && Bool.random() {
            return evening.randomElement() ?? general.randomElement()!
        }

        // Default: general affirmation (including life care messages)
        return allGeneral.randomElement()!
    }

    /// Get a random general affirmation (including life care messages)
    static func random() -> String {
        allGeneral.randomElement()!
    }
}
