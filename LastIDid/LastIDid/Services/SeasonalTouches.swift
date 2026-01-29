//
//  SeasonalTouches.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import Foundation

/// Service for providing seasonal emoji suggestions and touches
struct SeasonalTouches {

    // MARK: - Current Season

    enum Season: String {
        case spring
        case summer
        case fall
        case winter

        static var current: Season {
            let month = Calendar.current.component(.month, from: Date())
            switch month {
            case 3...5: return .spring
            case 6...8: return .summer
            case 9...11: return .fall
            default: return .winter
            }
        }
    }

    // MARK: - Seasonal Emojis

    static var seasonalEmojis: [String] {
        switch Season.current {
        case .spring:
            return ["🌸", "🌷", "🌻", "🐣", "🦋", "🌱", "🌈", "☔"]
        case .summer:
            return ["☀️", "🏖️", "🌊", "🍦", "🌴", "🏕️", "🎆", "🌻"]
        case .fall:
            return ["🍂", "🎃", "🍁", "🌾", "🦃", "🥧", "🌙", "🍎"]
        case .winter:
            return ["❄️", "☃️", "🎄", "🎁", "🧣", "☕", "🏔️", "✨"]
        }
    }

    // MARK: - Holiday Detection

    struct Holiday {
        let name: String
        let emoji: String
        let date: DateComponents
    }

    static let holidays: [Holiday] = [
        Holiday(name: "New Year", emoji: "🎉", date: DateComponents(month: 1, day: 1)),
        Holiday(name: "Valentine's Day", emoji: "❤️", date: DateComponents(month: 2, day: 14)),
        Holiday(name: "St. Patrick's Day", emoji: "☘️", date: DateComponents(month: 3, day: 17)),
        Holiday(name: "Earth Day", emoji: "🌍", date: DateComponents(month: 4, day: 22)),
        Holiday(name: "Independence Day", emoji: "🎆", date: DateComponents(month: 7, day: 4)),
        Holiday(name: "Halloween", emoji: "🎃", date: DateComponents(month: 10, day: 31)),
        Holiday(name: "Thanksgiving", emoji: "🦃", date: DateComponents(month: 11, day: 24)),
        Holiday(name: "Christmas", emoji: "🎄", date: DateComponents(month: 12, day: 25)),
    ]

    /// Check if today is near a holiday (within 3 days)
    static var nearbyHoliday: Holiday? {
        let today = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: today)

        for holiday in holidays {
            var components = holiday.date
            components.year = currentYear

            if let holidayDate = calendar.date(from: components) {
                let daysDiff = calendar.dateComponents([.day], from: today, to: holidayDate).day ?? 100

                // Within 3 days before or on the day
                if daysDiff >= 0 && daysDiff <= 3 {
                    return holiday
                }
            }
        }

        return nil
    }

    // MARK: - Seasonal Greeting Suffix

    static var seasonalGreetingSuffix: String? {
        if let holiday = nearbyHoliday {
            return "\(holiday.emoji) Happy \(holiday.name)!"
        }
        return nil
    }

    // MARK: - Seasonal Activity Suggestions

    struct SeasonalSuggestion {
        let activityName: String
        let emoji: String
        let reminderDays: Int?
    }

    static var seasonalSuggestions: [SeasonalSuggestion] {
        switch Season.current {
        case .spring:
            return [
                SeasonalSuggestion(activityName: "Spring cleaning", emoji: "🧹", reminderDays: nil),
                SeasonalSuggestion(activityName: "Check garden", emoji: "🌱", reminderDays: 7),
                SeasonalSuggestion(activityName: "Change AC filter", emoji: "❄️", reminderDays: 30),
            ]
        case .summer:
            return [
                SeasonalSuggestion(activityName: "Check sunscreen supply", emoji: "☀️", reminderDays: 30),
                SeasonalSuggestion(activityName: "Water plants", emoji: "🌱", reminderDays: 3),
                SeasonalSuggestion(activityName: "Pool maintenance", emoji: "🏊", reminderDays: 7),
            ]
        case .fall:
            return [
                SeasonalSuggestion(activityName: "Check heating system", emoji: "🔥", reminderDays: nil),
                SeasonalSuggestion(activityName: "Clear gutters", emoji: "🍂", reminderDays: nil),
                SeasonalSuggestion(activityName: "Change clocks", emoji: "🕐", reminderDays: nil),
            ]
        case .winter:
            return [
                SeasonalSuggestion(activityName: "Check smoke detectors", emoji: "🚨", reminderDays: nil),
                SeasonalSuggestion(activityName: "Check antifreeze", emoji: "❄️", reminderDays: nil),
                SeasonalSuggestion(activityName: "Shovel snow", emoji: "⛄", reminderDays: nil),
            ]
        }
    }

    // MARK: - Seasonal Accent Color

    static var seasonalAccentEmoji: String {
        switch Season.current {
        case .spring: return "🌸"
        case .summer: return "☀️"
        case .fall: return "🍂"
        case .winter: return "❄️"
        }
    }
}
