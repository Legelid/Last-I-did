//
//  MarkCompletedIntent.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import AppIntents
import SwiftData

// MARK: - Mark Activity Completed Intent
struct MarkCompletedIntent: AppIntent {
    static var title: LocalizedStringResource = "Mark Activity as Done"
    static var description = IntentDescription("Marks an activity as completed in Last I Did")

    @Parameter(title: "Activity")
    var activity: ActivityEntity

    @Parameter(title: "Notes", default: nil)
    var notes: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Mark \(\.$activity) as done") {
            \.$notes
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try ModelContainer(for: Activity.self, CompletionRecord.self, Category.self)
        let context = container.mainContext

        // Fetch all activities and filter in memory
        let descriptor = FetchDescriptor<Activity>()
        let activities = try context.fetch(descriptor)

        guard let activityModel = activities.first(where: { $0.id == activity.id }) else {
            return .result(dialog: "Couldn't find that activity.")
        }

        activityModel.markCompleted(notes: notes)
        NotificationManager.shared.rescheduleRecurringReminder(for: activityModel)

        try context.save()

        return .result(dialog: "Done! Marked \(activityModel.name) as completed.")
    }

    static var openAppWhenRun: Bool = false
}

// MARK: - Get Overdue Activities Intent
struct GetOverdueActivitiesIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Overdue Activities"
    static var description = IntentDescription("Lists activities that need attention")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try ModelContainer(for: Activity.self, CompletionRecord.self, Category.self)
        let context = container.mainContext

        // Fetch all activities and filter in memory (no predicate)
        let descriptor = FetchDescriptor<Activity>()
        let allActivities = try context.fetch(descriptor)

        // Filter in memory
        let activities = allActivities.filter { !$0.isArchived }
        let overdue = activities.filter { $0.agingState == .stale }

        if overdue.isEmpty {
            return .result(dialog: "You're all caught up! No overdue activities.")
        }

        let names = overdue.prefix(5).map { $0.name }.joined(separator: ", ")
        let count = overdue.count

        if count == 1 {
            return .result(dialog: "You have 1 overdue activity: \(names)")
        } else if count <= 5 {
            return .result(dialog: "You have \(count) overdue activities: \(names)")
        } else {
            return .result(dialog: "You have \(count) overdue activities including: \(names)")
        }
    }

    static var openAppWhenRun: Bool = false
}

// MARK: - When Did I Last Intent
struct WhenDidILastIntent: AppIntent {
    static var title: LocalizedStringResource = "When Did I Last..."
    static var description = IntentDescription("Tells you when you last completed an activity")

    @Parameter(title: "Activity")
    var activity: ActivityEntity

    static var parameterSummary: some ParameterSummary {
        Summary("When did I last \(\.$activity)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try ModelContainer(for: Activity.self, CompletionRecord.self, Category.self)
        let context = container.mainContext

        // Fetch all activities and filter in memory
        let descriptor = FetchDescriptor<Activity>()
        let activities = try context.fetch(descriptor)

        guard let activityModel = activities.first(where: { $0.id == activity.id }) else {
            return .result(dialog: "Couldn't find that activity.")
        }

        guard let lastDate = activityModel.lastCompletedDate else {
            return .result(dialog: "You haven't completed \(activityModel.name) yet.")
        }

        let days = activityModel.daysSinceLastCompleted

        if days == 0 {
            return .result(dialog: "You did \(activityModel.name) today!")
        } else if days == 1 {
            return .result(dialog: "You did \(activityModel.name) yesterday.")
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let dateString = formatter.string(from: lastDate)
            return .result(dialog: "You last did \(activityModel.name) \(days) days ago, on \(dateString).")
        }
    }

    static var openAppWhenRun: Bool = false
}

// MARK: - App Shortcuts Provider
struct LastIDidShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: MarkCompletedIntent(),
            phrases: [
                "Mark \(\.$activity) as done in \(.applicationName)",
                "I just did \(\.$activity) in \(.applicationName)",
                "Complete \(\.$activity) in \(.applicationName)",
                "Log \(\.$activity) in \(.applicationName)"
            ],
            shortTitle: "Mark Done",
            systemImageName: "checkmark.circle.fill"
        )

        AppShortcut(
            intent: GetOverdueActivitiesIntent(),
            phrases: [
                "What's overdue in \(.applicationName)",
                "Show overdue activities in \(.applicationName)",
                "What needs attention in \(.applicationName)"
            ],
            shortTitle: "Overdue Activities",
            systemImageName: "exclamationmark.circle.fill"
        )

        AppShortcut(
            intent: WhenDidILastIntent(),
            phrases: [
                "When did I last \(\.$activity) in \(.applicationName)",
                "When was \(\.$activity) last done in \(.applicationName)"
            ],
            shortTitle: "When Did I Last",
            systemImageName: "clock.fill"
        )
    }
}
