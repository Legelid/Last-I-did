//
//  InsightsCalculator.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import Foundation

struct InsightsCalculator {
    let activities: [Activity]

    // MARK: - Overview Stats

    var totalActivities: Int {
        activities.count
    }

    var totalCompletions: Int {
        activities.reduce(0) { $0 + $1.completions.count }
    }

    var activitiesNeedingAttention: Int {
        activities.filter { $0.agingState == .stale || $0.agingState == .never }.count
    }

    var freshActivities: Int {
        activities.filter { $0.agingState == .fresh }.count
    }

    var agingActivities: Int {
        activities.filter { $0.agingState == .aging }.count
    }

    // MARK: - Time-Based Stats

    var completionsThisWeek: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return activities.flatMap { $0.completions }
            .filter { $0.completedDate >= weekAgo }
            .count
    }

    var completionsThisMonth: Int {
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        return activities.flatMap { $0.completions }
            .filter { $0.completedDate >= monthAgo }
            .count
    }

    var averageCompletionsPerWeek: Double {
        guard !activities.isEmpty else { return 0 }

        let allCompletions = activities.flatMap { $0.completions }
        guard let oldest = allCompletions.min(by: { $0.completedDate < $1.completedDate })?.completedDate else {
            return 0
        }

        let weeksSinceOldest = max(1, Calendar.current.dateComponents([.day], from: oldest, to: Date()).day! / 7)
        return Double(allCompletions.count) / Double(weeksSinceOldest)
    }

    // MARK: - Activity Insights

    var mostCompletedActivity: Activity? {
        activities.max(by: { $0.completions.count < $1.completions.count })
    }

    var leastCompletedActivity: Activity? {
        activities.filter { !$0.completions.isEmpty }
            .min(by: { $0.completions.count < $1.completions.count })
    }

    var mostOverdueActivity: Activity? {
        activities.max(by: { $0.daysSinceLastCompleted < $1.daysSinceLastCompleted })
    }

    func averageCompletionInterval(for activity: Activity) -> Int? {
        let completions = activity.completions.sorted { $0.completedDate < $1.completedDate }
        guard completions.count >= 2 else { return nil }

        var totalDays = 0
        for i in 1..<completions.count {
            let days = Calendar.current.dateComponents([.day], from: completions[i-1].completedDate, to: completions[i].completedDate).day ?? 0
            totalDays += days
        }

        return totalDays / (completions.count - 1)
    }

    // MARK: - Category Insights

    func completionsByCategory() -> [(category: String, count: Int)] {
        var counts: [String: Int] = [:]

        for activity in activities {
            for category in activity.categories {
                counts[category.name, default: 0] += activity.completions.count
            }
        }

        return counts.map { ($0.key, $0.value) }
            .sorted { $0.count > $1.count }
    }

    func activitiesByAgingState() -> [AgingState: Int] {
        var result: [AgingState: Int] = [:]
        for state in AgingState.allCases {
            result[state] = activities.filter { $0.agingState == state }.count
        }
        return result
    }

    // MARK: - Trend Analysis

    func completionTrend(weeks: Int = 4) -> [WeeklyCompletion] {
        var result: [WeeklyCompletion] = []
        let calendar = Calendar.current
        let now = Date()

        for weekOffset in (0..<weeks).reversed() {
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: now)!
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!

            let count = activities.flatMap { $0.completions }
                .filter { $0.completedDate >= weekStart && $0.completedDate < weekEnd }
                .count

            let weekLabel = weekOffset == 0 ? "This week" :
                           weekOffset == 1 ? "Last week" :
                           "\(weekOffset) weeks ago"

            result.append(WeeklyCompletion(weekLabel: weekLabel, count: count, weekStart: weekStart))
        }

        return result
    }

    // MARK: - Health Score

    var maintenanceHealthScore: Int {
        guard !activities.isEmpty else { return 100 }

        let weights = activities.map { activity -> Double in
            switch activity.agingState {
            case .fresh: return 1.0
            case .aging: return 0.5
            case .stale: return 0.0
            case .never: return 0.25
            }
        }

        let average = weights.reduce(0, +) / Double(weights.count)
        return Int(average * 100)
    }
}

struct WeeklyCompletion: Identifiable {
    let id = UUID()
    let weekLabel: String
    let count: Int
    let weekStart: Date
}

struct ActivityInsight: Identifiable {
    let id = UUID()
    let activity: Activity
    let avgInterval: Int?
    let totalCompletions: Int
    let daysSinceLast: Int
}
