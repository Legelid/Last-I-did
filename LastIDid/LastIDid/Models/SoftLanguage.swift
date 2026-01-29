//
//  SoftLanguage.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import Foundation

/// Centralized gentle copy constants for a supportive, non-judgmental user experience
struct SoftLanguage {

    // MARK: - Aging Labels (replaces harsh terms)
    struct AgingLabels {
        static let fresh = "On track"
        static let aging = "Been a while"
        static let stale = "Waiting for you"      // NOT "Overdue"
        static let never = "Not yet started"       // NOT "Never done"
    }

    // MARK: - Time Since Descriptions
    static func timeSince(_ days: Int) -> String {
        switch days {
        case 0:
            return "Today"
        case 1:
            return "Yesterday"
        case 2...7:
            return "\(days) days ago"
        case 8...14:
            return "About a week ago"
        case 15...30:
            return "A couple weeks ago"
        case 31...60:
            return "About a month ago"
        case 61...90:
            return "A few months ago"
        default:
            return "A while back"
        }
    }

    // MARK: - Empty State Messages
    struct EmptyStates {
        static let noActivities = "Your journey starts here"
        static let noActivitiesSubtitle = "Add your first activity to begin tracking what matters to you"

        static let noCompletions = "No completions yet"
        static let noCompletionsSubtitle = "Every journey begins with a first step"

        static let noHistory = "History will appear here"
        static let noHistorySubtitle = "Complete this activity to see your progress"

        static let noInsights = "Insights coming soon"
        static let noInsightsSubtitle = "Complete a few activities to unlock patterns"

        static let noCategorizedActivities = "No activities in this category yet"
        static let noFilteredActivities = "Nothing matches your filter"
    }

    // MARK: - Action Labels
    struct Actions {
        static let markDone = "I did it!"
        static let markDoneSimple = "Done"
        static let logPast = "Log a past completion"
        static let addNote = "Add a note"
        static let addReflection = "Add a reflection"
        static let skip = "Skip for now"
        static let undo = "Undo"
    }

    // MARK: - Insights (observational, not judgmental)
    struct Insights {
        static let longestWaiting = "Longest waiting"       // NOT "Most Overdue"
        static let mostActive = "Most active"
        static let needsAttention = "Could use some love"   // NOT "Needs attention"
        static let streakGoing = "Streak going"

        static func patternObservation(_ activityName: String, _ pattern: String) -> String {
            "You often do \(activityName) \(pattern)"
        }

        static let averageCompletion = "Average pace"
        static let totalCompletions = "Times completed"
    }

    // MARK: - Score Labels
    struct Scores {
        static func healthLabel(for score: Int) -> String {
            switch score {
            case 80...100:
                return "Wonderful!"
            case 60..<80:
                return "Going well"
            case 40..<60:
                return "Room to grow"
            default:
                return "Fresh start ahead"
            }
        }
    }

    // MARK: - Streak Messages
    struct Streaks {
        static func message(for count: Int) -> String {
            switch count {
            case 0:
                return "Start your journey"
            case 1:
                return "First step taken!"
            case 2...4:
                return "Building momentum"
            case 5...9:
                return "Consistency is key"
            case 10...19:
                return "You're on a roll"
            case 20...49:
                return "Impressive dedication"
            default:
                return "Remarkable commitment"
            }
        }

        static let dailyStreak = "Daily streak"
        static let weeklyStreak = "Weekly streak"
        static let onTimeStreak = "On-time streak"
        static let bestStreak = "Personal best"
    }

    // MARK: - Reminder Copy
    struct Reminders {
        static let gentleTitles = [
            "Gentle reminder",
            "When you have a moment",
            "Just a thought",
            "Friendly nudge",
            "Quick reminder"
        ]

        static func bodyMessage(for activityName: String, daysSince: Int) -> String {
            switch daysSince {
            case Int.max:
                return "You haven't tried \"\(activityName)\" yet. No pressure!"
            case 0:
                return "Ready for \(activityName.lowercased())? Take your time."
            case 1:
                return "It's been a day since \"\(activityName)\". Whenever works for you!"
            case 2...7:
                return "It's been \(daysSince) days since \"\(activityName)\". Just a gentle reminder."
            case 8...30:
                return "It's been a little while since \"\(activityName)\". When you're ready!"
            default:
                return "\"\(activityName)\" is patiently waiting for you. No rush!"
            }
        }
    }

    // MARK: - Completion Celebration
    struct Celebration {
        static let completed = "Nice work!"
        static let firstTime = "First time! Exciting!"
        static let streakContinued = "Streak continues!"
        static let caughtUp = "All caught up!"
    }

    // MARK: - App Promise
    struct AppPromise {
        static let title = "Our Promise to You"
        static let promises = [
            "We celebrate what you do, never what you don't",
            "No guilt, no shame, just gentle awareness",
            "Your data stays private and on your device",
            "Life happens — we understand"
        ]
        static let tagline = "Calm, non-judgmental awareness tracking"
    }
}
