//
//  PatternDetector.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import Foundation

/// Service for detecting patterns in activity completion behavior
struct PatternDetector {

    // MARK: - Pattern Types

    struct DayPattern: Identifiable {
        let id = UUID()
        let activityName: String
        let dayOfWeek: Int  // 1 = Sunday, 7 = Saturday
        let confidence: Double  // 0.0 to 1.0

        var dayName: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            let calendar = Calendar.current
            let sunday = calendar.date(from: DateComponents(weekday: 1))!
            let targetDay = calendar.date(byAdding: .day, value: dayOfWeek - 1, to: sunday)!
            return formatter.string(from: targetDay)
        }
    }

    struct TimeOfDayPattern: Identifiable {
        let id = UUID()
        let activityName: String
        let timeOfDay: TimeOfDay
        let confidence: Double

        enum TimeOfDay: String {
            case morning = "morning"      // 5-11
            case afternoon = "afternoon"  // 12-16
            case evening = "evening"      // 17-20
            case night = "night"          // 21-4
        }
    }

    struct FrequencyPattern: Identifiable {
        let id = UUID()
        let activityName: String
        let averageDaysBetween: Int
        let consistency: Double  // How consistent the intervals are
    }

    struct WeekendWeekdayPattern: Identifiable {
        let id = UUID()
        let activityName: String
        let prefersWeekend: Bool
        let confidence: Double
    }

    // MARK: - Detection Methods

    /// Detect which day of the week an activity is usually done
    static func detectDayPattern(for activity: Activity) -> DayPattern? {
        let completions = activity.completions
        guard completions.count >= 3 else { return nil }

        var dayCounts: [Int: Int] = [:]
        for completion in completions {
            let weekday = Calendar.current.component(.weekday, from: completion.completedDate)
            dayCounts[weekday, default: 0] += 1
        }

        guard let (mostCommonDay, count) = dayCounts.max(by: { $0.value < $1.value }) else {
            return nil
        }

        let confidence = Double(count) / Double(completions.count)

        // Only return if there's a clear pattern (>40% on one day)
        guard confidence >= 0.4 else { return nil }

        return DayPattern(
            activityName: activity.name,
            dayOfWeek: mostCommonDay,
            confidence: confidence
        )
    }

    /// Detect preferred time of day for an activity
    static func detectTimeOfDayPattern(for activity: Activity) -> TimeOfDayPattern? {
        let completions = activity.completions
        guard completions.count >= 3 else { return nil }

        var timeCounts: [TimeOfDayPattern.TimeOfDay: Int] = [:]

        for completion in completions {
            let hour = Calendar.current.component(.hour, from: completion.completedDate)
            let timeOfDay: TimeOfDayPattern.TimeOfDay

            switch hour {
            case 5...11: timeOfDay = .morning
            case 12...16: timeOfDay = .afternoon
            case 17...20: timeOfDay = .evening
            default: timeOfDay = .night
            }

            timeCounts[timeOfDay, default: 0] += 1
        }

        guard let (mostCommonTime, count) = timeCounts.max(by: { $0.value < $1.value }) else {
            return nil
        }

        let confidence = Double(count) / Double(completions.count)
        guard confidence >= 0.4 else { return nil }

        return TimeOfDayPattern(
            activityName: activity.name,
            timeOfDay: mostCommonTime,
            confidence: confidence
        )
    }

    /// Detect average frequency pattern
    static func detectFrequencyPattern(for activity: Activity) -> FrequencyPattern? {
        let sortedCompletions = activity.completions.sorted { $0.completedDate < $1.completedDate }
        guard sortedCompletions.count >= 3 else { return nil }

        var intervals: [Int] = []
        for i in 1..<sortedCompletions.count {
            let days = Calendar.current.dateComponents(
                [.day],
                from: sortedCompletions[i-1].completedDate,
                to: sortedCompletions[i].completedDate
            ).day ?? 0
            intervals.append(days)
        }

        let average = intervals.reduce(0, +) / intervals.count

        // Calculate consistency (lower variance = higher consistency)
        let variance = intervals.map { pow(Double($0 - average), 2) }.reduce(0, +) / Double(intervals.count)
        let standardDeviation = sqrt(variance)
        let consistency = max(0, 1.0 - (standardDeviation / Double(average + 1)))

        guard average > 0 else { return nil }

        return FrequencyPattern(
            activityName: activity.name,
            averageDaysBetween: average,
            consistency: consistency
        )
    }

    /// Detect weekend vs weekday preference
    static func detectWeekendWeekdayPattern(for activity: Activity) -> WeekendWeekdayPattern? {
        let completions = activity.completions
        guard completions.count >= 5 else { return nil }

        var weekendCount = 0
        var weekdayCount = 0

        for completion in completions {
            if Calendar.current.isDateInWeekend(completion.completedDate) {
                weekendCount += 1
            } else {
                weekdayCount += 1
            }
        }

        let total = weekendCount + weekdayCount
        let weekendRatio = Double(weekendCount) / Double(total)

        // Only flag if there's a clear preference (>60% one way)
        guard weekendRatio >= 0.6 || weekendRatio <= 0.4 else { return nil }

        return WeekendWeekdayPattern(
            activityName: activity.name,
            prefersWeekend: weekendRatio >= 0.5,
            confidence: weekendRatio >= 0.5 ? weekendRatio : (1 - weekendRatio)
        )
    }

    // MARK: - Pattern Summary

    struct PatternSummary {
        let dayPatterns: [DayPattern]
        let timePatterns: [TimeOfDayPattern]
        let frequencyPatterns: [FrequencyPattern]
        let weekendPatterns: [WeekendWeekdayPattern]
    }

    /// Get all patterns for a list of activities
    static func analyzePatterns(for activities: [Activity]) -> PatternSummary {
        var dayPatterns: [DayPattern] = []
        var timePatterns: [TimeOfDayPattern] = []
        var frequencyPatterns: [FrequencyPattern] = []
        var weekendPatterns: [WeekendWeekdayPattern] = []

        for activity in activities {
            if let pattern = detectDayPattern(for: activity) {
                dayPatterns.append(pattern)
            }
            if let pattern = detectTimeOfDayPattern(for: activity) {
                timePatterns.append(pattern)
            }
            if let pattern = detectFrequencyPattern(for: activity) {
                frequencyPatterns.append(pattern)
            }
            if let pattern = detectWeekendWeekdayPattern(for: activity) {
                weekendPatterns.append(pattern)
            }
        }

        return PatternSummary(
            dayPatterns: dayPatterns.sorted { $0.confidence > $1.confidence },
            timePatterns: timePatterns.sorted { $0.confidence > $1.confidence },
            frequencyPatterns: frequencyPatterns.sorted { $0.consistency > $1.consistency },
            weekendPatterns: weekendPatterns.sorted { $0.confidence > $1.confidence }
        )
    }
}
