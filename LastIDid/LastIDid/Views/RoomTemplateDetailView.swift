//
//  RoomTemplateDetailView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import SwiftUI
import SwiftData

struct RoomTemplateDetailView: View {
    let template: RoomTemplate

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    @State private var selectedActivities: Set<UUID> = []
    @State private var showingImportConfirmation = false
    @State private var showingScheduleSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Text(template.emoji)
                        .font(.system(size: 60))

                    Text(template.roomName)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(template.description)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()

                // Activity List
                List {
                    Section {
                        Text("Select activities you'd like to add. You can customize or remove them later.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Section {
                        ForEach(template.activities) { activity in
                            ActivitySelectionRow(
                                activity: activity,
                                isSelected: selectedActivities.contains(activity.id)
                            ) {
                                toggleSelection(activity)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)

                // Bottom Action Bar
                VStack(spacing: 12) {
                    Button {
                        selectAll()
                    } label: {
                        Text("Select All (\(template.activities.count))")
                            .font(.callout)
                    }
                    .disabled(selectedActivities.count == template.activities.count)

                    HStack(spacing: 12) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)

                        Button {
                            showingImportConfirmation = true
                        } label: {
                            Text("Add \(selectedActivities.count) Activities")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedActivities.isEmpty)
                    }
                }
                .padding()
                .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)
            }
            .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)
            .navigationBarTitleDisplayMode(.inline)
            .alert("Add Activities?", isPresented: $showingImportConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Add") {
                    showingScheduleSheet = true
                }
            } message: {
                Text("Add \(selectedActivities.count) activities to your list? You can edit or remove them anytime.")
            }
            .sheet(isPresented: $showingScheduleSheet) {
                ReminderScheduleSheet(
                    activityCount: selectedActivities.count,
                    onSkip: {
                        importSelectedActivities(withReminder: nil)
                    },
                    onSchedule: { intervalDays, reminderTime in
                        importSelectedActivities(withReminder: (intervalDays, reminderTime))
                    }
                )
            }
        }
    }

    private func toggleSelection(_ activity: TemplateActivity) {
        if selectedActivities.contains(activity.id) {
            selectedActivities.remove(activity.id)
        } else {
            selectedActivities.insert(activity.id)
        }
    }

    private func selectAll() {
        selectedActivities = Set(template.activities.map { $0.id })
    }

    private func importSelectedActivities(withReminder reminderSettings: (intervalDays: Int, time: Date)?) {
        let activitiesToImport = template.activities.filter { selectedActivities.contains($0.id) }

        for templateActivity in activitiesToImport {
            let activity = Activity(
                name: templateActivity.name,
                notes: templateActivity.suggestedFrequency  // Store as notes, informational only
            )
            activity.emoji = templateActivity.suggestedEmoji
            activity.templateSourceID = "room-\(templateActivity.id.uuidString)"

            // Assign category if matching one exists
            if let category = categories.first(where: { $0.name == templateActivity.categoryName }) {
                activity.categories = [category]
            }

            // Configure reminder if user opted in
            if let reminder = reminderSettings {
                activity.reminderEnabled = true
                activity.reminderType = .recurring
                activity.reminderIntervalDays = reminder.intervalDays

                // Adjust the createdDate to include the selected time
                // This ensures the reminder fires at the user's preferred time
                let calendar = Calendar.current
                var components = calendar.dateComponents([.year, .month, .day], from: activity.createdDate)
                let timeComponents = calendar.dateComponents([.hour, .minute], from: reminder.time)
                components.hour = timeComponents.hour
                components.minute = timeComponents.minute
                if let adjustedDate = calendar.date(from: components) {
                    activity.createdDate = adjustedDate
                }
            }

            modelContext.insert(activity)

            // Schedule notification if reminder is enabled
            if reminderSettings != nil {
                NotificationManager.shared.scheduleReminder(for: activity)
            }
        }

        HapticFeedback.success()

        let message = reminderSettings != nil
            ? "Added \(activitiesToImport.count) activities with reminders"
            : "Added \(activitiesToImport.count) activities"
        ToastManager.shared.show(message)

        dismiss()
    }
}

#Preview {
    RoomTemplateDetailView(template: RoomTemplateData.kitchen)
        .modelContainer(for: [Activity.self, Category.self], inMemory: true)
        .preferredColorScheme(.dark)
}
