//
//  Activity.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import Foundation
import SwiftData

enum ReminderType: String, Codable {
    case oneTime    // Specific date/time
    case recurring  // X days after last completion
}

@Model
final class Activity {
    var id: UUID
    var name: String
    var notes: String?
    var emoji: String?
    var createdDate: Date
    var isArchived: Bool = false
    var templateSourceID: String?

    // Reminder properties
    var reminderEnabled: Bool = false
    var reminderType: ReminderType?
    var reminderDate: Date?           // For one-time reminders
    var reminderIntervalDays: Int?    // For recurring (e.g., 7 = remind 7 days after completion)
    var reminderNotificationID: String?

    // Location reminder relationship (optional)
    var locationReminderIDs: [UUID] = []

    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \CompletionRecord.activity)
    var completions: [CompletionRecord] = []

    @Relationship(inverse: \Category.activities)
    var categories: [Category] = []

    init(name: String, notes: String? = nil, createdDate: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.notes = notes
        self.createdDate = createdDate
        self.reminderEnabled = false
        self.isArchived = false
    }

    // Computed property - replaces stored lastCompletedDate
    var lastCompletedDate: Date? {
        completions.max(by: { $0.completedDate < $1.completedDate })?.completedDate
    }

    var daysSinceLastCompleted: Int {
        guard let lastCompleted = lastCompletedDate else { return Int.max }
        return Calendar.current.dateComponents([.day], from: lastCompleted, to: Date()).day ?? 0
    }

    func markCompleted(notes: String? = nil, backdatedTo date: Date? = nil) {
        let completionDate = date ?? Date()
        let record = CompletionRecord(
            completedDate: completionDate,
            notes: notes,
            wasBackdated: date != nil
        )
        record.activity = self
        completions.append(record)
    }
}
