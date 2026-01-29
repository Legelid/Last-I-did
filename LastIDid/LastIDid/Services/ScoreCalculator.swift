//
//  ScoreCalculator.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import Foundation

/// Calculates a private "Life Maintenance Score" (0-100)
/// This is meant to be encouraging and private, not a source of anxiety
struct ScoreCalculator {

    // MARK: - Score Calculation

    /// Calculate overall maintenance score (0-100)
    static func calculateScore(for activities: [Activity]) -> Int {
        guard !activities.isEmpty else { return 100 } // No activities = nothing to maintain!

        var totalWeight: Double = 0
        var weightedScore: Double = 0

        for activity in activities {
            let weight = activityWeight(for: activity)
            let score = activityScore(for: activity)

            totalWeight += weight
            weightedScore += weight * score
        }

        guard totalWeight > 0 else { return 100 }

        return Int((weightedScore / totalWeight) * 100)
    }

    /// Weight based on activity importance (recurring = more important)
    private static func activityWeight(for activity: Activity) -> Double {
        if activity.reminderEnabled && activity.reminderType == .recurring {
            // Shorter intervals = higher importance
            if let days = activity.reminderIntervalDays {
                if days <= 7 { return 2.0 }
                if days <= 30 { return 1.5 }
                return 1.2
            }
        }
        return 1.0
    }

    /// Score for individual activity (0.0 to 1.0)
    private static func activityScore(for activity: Activity) -> Double {
        switch activity.agingState {
        case .fresh:
            return 1.0
        case .aging:
            // Gradual decline from 1.0 to 0.5 over aging period
            let days = activity.daysSinceLastCompleted
            let progress = Double(days - 7) / 23.0 // 7-30 days
            return max(0.5, 1.0 - (progress * 0.5))
        case .stale:
            // Below 0.5, declining further
            let days = activity.daysSinceLastCompleted
            let overdueDays = days - 30
            let decline = min(0.4, Double(overdueDays) / 100.0)
            return max(0.1, 0.5 - decline)
        case .never:
            return 0.3 // Not completed yet, but not heavily penalized
        }
    }

    // MARK: - Score Breakdown

    struct ScoreBreakdown {
        let overallScore: Int
        let freshCount: Int
        let agingCount: Int
        let staleCount: Int
        let neverCount: Int
        let categoryScores: [CategoryScore]
        let trend: ScoreTrend
    }

    struct CategoryScore: Identifiable {
        let id: UUID
        let name: String
        let score: Int
        let activityCount: Int
    }

    enum ScoreTrend {
        case improving
        case stable
        case declining

        var icon: String {
            switch self {
            case .improving: return "arrow.up.right"
            case .stable: return "arrow.right"
            case .declining: return "arrow.down.right"
            }
        }

        var label: String {
            switch self {
            case .improving: return "Improving"
            case .stable: return "Stable"
            case .declining: return "Needs attention"
            }
        }
    }

    static func calculateBreakdown(for activities: [Activity]) -> ScoreBreakdown {
        let overallScore = calculateScore(for: activities)

        let freshCount = activities.filter { $0.agingState == .fresh }.count
        let agingCount = activities.filter { $0.agingState == .aging }.count
        let staleCount = activities.filter { $0.agingState == .stale }.count
        let neverCount = activities.filter { $0.agingState == .never }.count

        // Calculate per-category scores
        var categoryMap: [UUID: (name: String, activities: [Activity])] = [:]
        for activity in activities {
            for category in activity.categories {
                if categoryMap[category.id] == nil {
                    categoryMap[category.id] = (category.name, [])
                }
                categoryMap[category.id]?.activities.append(activity)
            }
        }

        let categoryScores = categoryMap.map { id, data in
            CategoryScore(
                id: id,
                name: data.name,
                score: calculateScore(for: data.activities),
                activityCount: data.activities.count
            )
        }.sorted { $0.score < $1.score } // Lowest first (needs attention)

        // Calculate trend (compare to 7 days ago - simplified)
        let trend = calculateTrend(activities: activities)

        return ScoreBreakdown(
            overallScore: overallScore,
            freshCount: freshCount,
            agingCount: agingCount,
            staleCount: staleCount,
            neverCount: neverCount,
            categoryScores: categoryScores,
            trend: trend
        )
    }

    private static func calculateTrend(activities: [Activity]) -> ScoreTrend {
        // Count completions this week vs last week
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now)!

        let thisWeekCompletions = activities.flatMap { $0.completions }
            .filter { $0.completedDate >= weekAgo }
            .count

        let lastWeekCompletions = activities.flatMap { $0.completions }
            .filter { $0.completedDate >= twoWeeksAgo && $0.completedDate < weekAgo }
            .count

        if thisWeekCompletions > lastWeekCompletions + 2 {
            return .improving
        } else if thisWeekCompletions < lastWeekCompletions - 2 {
            return .declining
        }
        return .stable
    }

    // MARK: - Score Messages

    static func message(for score: Int) -> String {
        switch score {
        case 90...100:
            return "Excellent! You're on top of everything."
        case 75..<90:
            return "Great job! Most things are in good shape."
        case 60..<75:
            return "Doing well! A few things could use attention."
        case 40..<60:
            return "Some maintenance tasks are piling up."
        case 20..<40:
            return "Time to catch up on some overdue items."
        default:
            return "Let's start fresh and tackle a few things!"
        }
    }

    static func encouragement(for score: Int) -> String {
        switch score {
        case 90...100:
            return "Keep up the amazing work!"
        case 75..<90:
            return "You're doing great!"
        case 60..<75:
            return "A little effort goes a long way!"
        case 40..<60:
            return "Pick one thing to do today - you've got this!"
        default:
            return "Every journey starts with a single step."
        }
    }
}
