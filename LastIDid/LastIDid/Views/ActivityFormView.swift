//
//  ActivityFormView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import SwiftUI
import SwiftData

struct ActivityFormView: View {
    enum Mode: Identifiable {
        case add
        case edit(Activity)

        var id: String {
            switch self {
            case .add:
                return "add"
            case .edit(let activity):
                return activity.id.uuidString
            }
        }
    }

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex
    @Query(sort: \Category.sortOrder) private var allCategories: [Category]

    let mode: Mode

    @State private var name: String = ""
    @State private var notes: String = ""
    @State private var emoji: String? = nil

    // Initial completion (for new activities)
    @State private var setInitialCompletion: Bool = true
    @State private var initialCompletionDate: Date = Date()

    // Categories
    @State private var selectedCategories: Set<UUID> = []

    // Reminder state
    @State private var reminderEnabled: Bool = false
    @State private var reminderType: ReminderType = .oneTime
    @State private var reminderDate: Date = Date().addingTimeInterval(86400) // Default to tomorrow
    @State private var reminderIntervalDays: Int = 7

    // Template state
    @State private var showingTemplates: Bool = false

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var title: String {
        isEditing ? "Edit Activity" : "New Activity"
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Activity name", text: $name)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section {
                    EmojiSelectorButton(selectedEmoji: $emoji)
                } header: {
                    Text("Icon")
                } footer: {
                    Text("Add an emoji to personalize this activity.")
                }

                // Initial completion section (only for new activities)
                if !isEditing {
                    Section {
                        Toggle("Set initial completion", isOn: $setInitialCompletion)

                        if setInitialCompletion {
                            DatePicker(
                                "Last completed",
                                selection: $initialCompletionDate,
                                in: ...Date(),
                                displayedComponents: [.date]
                            )
                        }
                    } header: {
                        Text("Completion")
                    } footer: {
                        Text("Optionally set when you last completed this activity.")
                    }
                }

                // Categories section
                if !allCategories.isEmpty {
                    Section {
                        ForEach(allCategories) { category in
                            Button {
                                if selectedCategories.contains(category.id) {
                                    selectedCategories.remove(category.id)
                                } else {
                                    selectedCategories.insert(category.id)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: category.systemIcon)
                                        .foregroundStyle(category.color)
                                        .frame(width: 24)

                                    Text(category.name)
                                        .foregroundStyle(.primary)

                                    Spacer()

                                    if selectedCategories.contains(category.id) {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Color.accentColor)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Categories")
                    }
                }

                Section {
                    Toggle("Remind me", isOn: $reminderEnabled)

                    if reminderEnabled {
                        Picker("Reminder type", selection: $reminderType) {
                            Text("One-time").tag(ReminderType.oneTime)
                            Text("Recurring").tag(ReminderType.recurring)
                        }

                        if reminderType == .oneTime {
                            DatePicker("Remind on", selection: $reminderDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                        } else {
                            Stepper("Every \(reminderIntervalDays) days after completion", value: $reminderIntervalDays, in: 1...365)
                        }
                    }
                } header: {
                    Text("Reminders")
                }

                // Template section (only for new activities)
                if !isEditing {
                    Section {
                        Button {
                            showingTemplates = true
                        } label: {
                            HStack {
                                Image(systemName: "doc.on.doc.fill")
                                    .foregroundStyle(Color.accentColor)
                                Text("Use a Template")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } footer: {
                        Text("Pre-fill with a common activity template.")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if case .edit(let activity) = mode {
                    name = activity.name
                    notes = activity.notes ?? ""
                    emoji = activity.emoji
                    selectedCategories = Set(activity.categories.map(\.id))
                    reminderEnabled = activity.reminderEnabled
                    reminderType = activity.reminderType ?? .oneTime
                    reminderDate = activity.reminderDate ?? Date().addingTimeInterval(86400)
                    reminderIntervalDays = activity.reminderIntervalDays ?? 7
                }
            }
            .sheet(isPresented: $showingTemplates) {
                TemplatePickerView { template in
                    applyTemplate(template)
                }
            }
        }
    }

    private func applyTemplate(_ template: ActivityTemplate) {
        name = template.name

        // Find matching category
        if let matchingCategory = allCategories.first(where: { $0.name == template.category }) {
            selectedCategories = [matchingCategory.id]
        }

        // Set up reminder if template suggests one
        if let days = template.suggestedReminderDays {
            reminderEnabled = true
            reminderType = .recurring
            reminderIntervalDays = days
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        switch mode {
        case .add:
            let activity = Activity(
                name: trimmedName,
                notes: trimmedNotes.isEmpty ? nil : trimmedNotes
            )
            activity.emoji = emoji

            // Set initial completion if requested
            if setInitialCompletion {
                let isBackdated = !Calendar.current.isDateInToday(initialCompletionDate)
                activity.markCompleted(backdatedTo: isBackdated ? initialCompletionDate : nil)
            }

            // Assign categories
            activity.categories = allCategories.filter { selectedCategories.contains($0.id) }

            configureReminder(for: activity)
            modelContext.insert(activity)
            NotificationManager.shared.scheduleReminder(for: activity)

        case .edit(let activity):
            activity.name = trimmedName
            activity.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
            activity.emoji = emoji

            // Update categories
            activity.categories = allCategories.filter { selectedCategories.contains($0.id) }

            configureReminder(for: activity)
            if activity.reminderEnabled {
                NotificationManager.shared.scheduleReminder(for: activity)
            } else {
                NotificationManager.shared.cancelReminder(for: activity)
            }
        }
    }

    private func configureReminder(for activity: Activity) {
        activity.reminderEnabled = reminderEnabled
        if reminderEnabled {
            activity.reminderType = reminderType
            activity.reminderDate = reminderType == .oneTime ? reminderDate : nil
            activity.reminderIntervalDays = reminderType == .recurring ? reminderIntervalDays : nil
        } else {
            activity.reminderType = nil
            activity.reminderDate = nil
            activity.reminderIntervalDays = nil
        }
    }
}

#Preview("Add") {
    ActivityFormView(mode: .add)
        .modelContainer(for: [Activity.self, CompletionRecord.self, Category.self], inMemory: true)
        .preferredColorScheme(.dark)
}

#Preview("Edit") {
    let activity = Activity(name: "Water plants", notes: "All indoor plants")
    return ActivityFormView(mode: .edit(activity))
        .modelContainer(for: [Activity.self, CompletionRecord.self, Category.self], inMemory: true)
        .preferredColorScheme(.dark)
}

// MARK: - Template Picker View

struct TemplatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex

    let onSelect: (ActivityTemplate) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(ActivityTemplate.allCategoriesOrdered, id: \.self) { category in
                    Section(category) {
                        if let templates = ActivityTemplate.allTemplates[category] {
                            ForEach(templates) { template in
                                Button {
                                    onSelect(template)
                                    dismiss()
                                } label: {
                                    HStack {
                                        Image(systemName: template.icon)
                                            .foregroundStyle(Color.accentColor)
                                            .frame(width: 28)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(template.name)
                                                .foregroundStyle(.primary)

                                            if let days = template.suggestedReminderDays {
                                                Text("Suggested: every \(days) days")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)
            .navigationTitle("Choose Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
