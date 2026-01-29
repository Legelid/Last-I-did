//
//  CheckInGenerator.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/23/26.
//

import Foundation

/// Data structure for Life Care Check-In content
struct CheckInData {
    let mainMessage: String
    let recentActivityInsight: String
    let patternInsight: String
    let encouragement: String?
    let generatedDate: Date
}

/// Generates compassionate, supportive check-in messages based on activity data
class CheckInGenerator {

    // MARK: - Engagement Levels

    enum EngagementLevel {
        case high       // 70%+ completion rate recently
        case moderate   // 40-70% completion rate
        case low        // 10-40% completion rate
        case quiet      // <10% or no recent activity
    }

    // MARK: - Message Pools

    private static let highEngagementMessages = [
        "You've been taking good care of things lately.",
        "You're staying on top of things.",
        "You've been showing up consistently.",
        "Things are flowing well for you.",
        "You've built a nice rhythm."
    ]

    private static let moderateEngagementMessages = [
        "You're keeping up with the important things.",
        "You're doing what matters.",
        "You're making progress at your own pace.",
        "You're staying aware of what needs attention.",
        "You're handling things well."
    ]

    private static let lowEngagementMessages = [
        "Life gets busy - you're doing what you can.",
        "Even small steps count.",
        "You're still showing up, and that matters.",
        "Every little bit helps.",
        "You're doing your best with what you have."
    ]

    private static let quietMessages = [
        "Taking a break is part of self-care too.",
        "Rest when you need to.",
        "It's okay to step back sometimes.",
        "Quiet periods have their own value.",
        "Being gentle with yourself is important."
    ]

    // MARK: - Pattern Insights

    private static let positivePatterns = [
        "You've been consistent this week.",
        "Your recent attention shows.",
        "Things are moving in a good direction.",
        "You've found a sustainable pace."
    ]

    private static let neutralPatterns = [
        "Every day is a fresh start.",
        "Small moments add up over time.",
        "Awareness itself is valuable.",
        "You're keeping track, and that counts."
    ]

    // MARK: - Encouragements

    private static let encouragements = [
        "You're doing better than you think.",
        "What you're doing matters.",
        "Trust your own pace.",
        "You've got this."
    ]

    // MARK: - Public API

    /// Generate check-in data based on activities
    static func generate(activities: [Activity], userName: String?) -> CheckInData {
        let now = Date()
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now

        // Calculate recent completions
        var recentCompletions = 0
        var totalCompletionsAllTime = 0

        for activity in activities {
            totalCompletionsAllTime += activity.completions.count
            let recentForActivity = activity.completions.filter { $0.completedDate >= oneWeekAgo }
            recentCompletions += recentForActivity.count
        }

        let level = calculateEngagementLevel(
            completions: recentCompletions,
            activities: activities.count
        )

        let mainMessage = generateMainMessage(level: level, userName: userName)
        let recentInsight = generateRecentActivityInsight(
            recentCompletions: recentCompletions,
            totalActivities: activities.count
        )
        let patternInsight = generatePatternInsight(level: level)
        let encouragement = shouldShowEncouragement(level: level) ? encouragements.randomElement() : nil

        return CheckInData(
            mainMessage: mainMessage,
            recentActivityInsight: recentInsight,
            patternInsight: patternInsight,
            encouragement: encouragement,
            generatedDate: now
        )
    }

    /// Calculate engagement level based on recent activity
    static func calculateEngagementLevel(completions: Int, activities: Int) -> EngagementLevel {
        guard activities > 0 else { return .quiet }

        // Calculate completion rate as completions per activity this week
        // A "healthy" rate would be about 1 completion per activity per week
        let rate = Double(completions) / Double(activities)

        if rate >= 0.7 {
            return .high
        } else if rate >= 0.4 {
            return .moderate
        } else if rate >= 0.1 {
            return .low
        } else {
            return .quiet
        }
    }

    /// Generate main message with optional name personalization (60% frequency)
    static func generateMainMessage(level: EngagementLevel, userName: String?) -> String {
        let messages: [String]
        switch level {
        case .high:
            messages = highEngagementMessages
        case .moderate:
            messages = moderateEngagementMessages
        case .low:
            messages = lowEngagementMessages
        case .quiet:
            messages = quietMessages
        }

        let baseMessage = messages.randomElement() ?? "You're doing fine."

        // 60% chance to personalize with name if available
        if let name = userName, !name.isEmpty, Double.random(in: 0...1) < 0.6 {
            return "\(name), \(baseMessage.lowercased())"
        }

        return baseMessage
    }

    // MARK: - Private Helpers

    private static func generateRecentActivityInsight(recentCompletions: Int, totalActivities: Int) -> String {
        if recentCompletions == 0 {
            return "No recent completions - and that's okay."
        } else if recentCompletions == 1 {
            return "You completed 1 thing this week."
        } else {
            return "You completed \(recentCompletions) things this week."
        }
    }

    private static func generatePatternInsight(level: EngagementLevel) -> String {
        switch level {
        case .high, .moderate:
            return positivePatterns.randomElement() ?? neutralPatterns.randomElement()!
        case .low, .quiet:
            return neutralPatterns.randomElement()!
        }
    }

    private static func shouldShowEncouragement(level: EngagementLevel) -> Bool {
        // Show encouragement more often for lower engagement
        switch level {
        case .high:
            return Double.random(in: 0...1) < 0.3
        case .moderate:
            return Double.random(in: 0...1) < 0.5
        case .low, .quiet:
            return true
        }
    }
}
