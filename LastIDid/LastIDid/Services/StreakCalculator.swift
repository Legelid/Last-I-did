//
//  StreakCalculator.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import Foundation

/// Calculates positive, non-guilting streaks for activities
/// Focus is on celebrating consistency, not punishing gaps
struct StreakCalculator {

    // MARK: - Streak Types

    struct Streak {
        let count: Int
        let type: StreakType
        let activity: Activity?

        enum StreakType {
            case onTime           // Completed within expected interval
            case consecutive      // Completed multiple times in a row
            case weekly           // At least once per week
            case bestEver         // Longest streak achieved
        }

        var celebrationMessage: String {
            switch type {
            case .onTime:
                return "\(count) on-time completion\(count == 1 ? "" : "s")!"
            case .consecutive:
                return "\(count) in a row!"
            case .weekly:
                return "\(count) week streak!"
            case .bestEver:
                return "Personal best: \(count)!"
            }
        }

        var icon: String {
            switch type {
            case .onTime: return "clock.badge.checkmark.fill"
            case .consecutive: return "flame.fill"
            case .weekly: return "calendar.badge.checkmark"
            case .bestEver: return "trophy.fill"
            }
        }
    }

    // MARK: - Activity Streaks

    /// Calculate on-time streak for an activity with a recurring reminder
    static func onTimeStreak(for activity: Activity) -> Int {
        guard let intervalDays = activity.reminderIntervalDays else { return 0 }

        let completions = activity.completions.sorted { $0.completedDate > $1.completedDate }
        guard completions.count >= 2 else { return completions.count }

        var streak = 0
        let calendar = Calendar.current

        for i in 0..<(completions.count - 1) {
            let current = completions[i].completedDate
            let previous = completions[i + 1].completedDate

            let daysBetween = calendar.dateComponents([.day], from: previous, to: current).day ?? 0

            // Consider "on time" if within expected interval + 3 day grace period
            if daysBetween <= intervalDays + 3 {
                streak += 1
            } else {
                break
            }
        }

        return streak + 1 // Add 1 for the most recent completion
    }

    /// Calculate weekly streak (at least one completion per week)
    static func weeklyStreak(for activity: Activity) -> Int {
        let completions = activity.completions.sorted { $0.completedDate > $1.completedDate }
        guard !completions.isEmpty else { return 0 }

        let calendar = Calendar.current
        var streak = 1
        var currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()

        // Check if there's a completion this week
        let hasCompletionThisWeek = completions.contains {
            calendar.isDate($0.completedDate, equalTo: Date(), toGranularity: .weekOfYear)
        }

        if !hasCompletionThisWeek {
            return 0
        }

        // Count consecutive weeks with completions
        var weekOffset = 1
        while true {
            guard let previousWeekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: currentWeekStart) else {
                break
            }

            let hasCompletionInWeek = completions.contains {
                calendar.isDate($0.completedDate, equalTo: previousWeekStart, toGranularity: .weekOfYear)
            }

            if hasCompletionInWeek {
                streak += 1
                weekOffset += 1
            } else {
                break
            }
        }

        return streak
    }

    /// Get the best (longest) streak ever achieved for an activity
    static func bestStreak(for activity: Activity) -> Int {
        guard let intervalDays = activity.reminderIntervalDays else {
            return weeklyStreak(for: activity)
        }

        let completions = activity.completions.sorted { $0.completedDate < $1.completedDate }
        guard completions.count >= 2 else { return completions.count }

        var bestStreak = 1
        var currentStreak = 1
        let calendar = Calendar.current

        for i in 1..<completions.count {
            let current = completions[i].completedDate
            let previous = completions[i - 1].completedDate

            let daysBetween = calendar.dateComponents([.day], from: previous, to: current).day ?? 0

            if daysBetween <= intervalDays + 3 {
                currentStreak += 1
                bestStreak = max(bestStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }

        return bestStreak
    }

    // MARK: - Global Streaks

    /// Calculate overall daily completion streak (at least one activity completed per day)
    static func dailyCompletionStreak(activities: [Activity]) -> Int {
        let allCompletions = activities.flatMap { $0.completions }
            .sorted { $0.completedDate > $1.completedDate }

        guard !allCompletions.isEmpty else { return 0 }

        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        // Check each day going backwards
        while true {
            let hasCompletionOnDay = allCompletions.contains {
                calendar.isDate($0.completedDate, inSameDayAs: checkDate)
            }

            if hasCompletionOnDay {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                    break
                }
                checkDate = previousDay
            } else {
                break
            }
        }

        return streak
    }

    // MARK: - Streak Summary

    struct StreakSummary {
        let dailyStreak: Int
        let activityStreaks: [ActivityStreakInfo]
        let totalOnTimeCompletions: Int
        let bestOverallStreak: Int
    }

    struct ActivityStreakInfo: Identifiable {
        let id: UUID
        let activityName: String
        let currentStreak: Int
        let bestStreak: Int
        let weeklyStreak: Int
    }

    static func calculateSummary(for activities: [Activity]) -> StreakSummary {
        let dailyStreak = dailyCompletionStreak(activities: activities)

        let activityStreaks = activities.map { activity in
            ActivityStreakInfo(
                id: activity.id,
                activityName: activity.name,
                currentStreak: onTimeStreak(for: activity),
                bestStreak: bestStreak(for: activity),
                weeklyStreak: weeklyStreak(for: activity)
            )
        }

        let totalOnTime = activityStreaks.reduce(0) { $0 + $1.currentStreak }
        let bestOverall = activityStreaks.map { $0.bestStreak }.max() ?? 0

        return StreakSummary(
            dailyStreak: dailyStreak,
            activityStreaks: activityStreaks,
            totalOnTimeCompletions: totalOnTime,
            bestOverallStreak: bestOverall
        )
    }
}
