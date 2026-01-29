//
//  ReminderScheduleSheet.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import SwiftUI

enum ReminderFrequency: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Every 2 Weeks"
    case monthly = "Monthly"
    case custom = "Custom"

    var id: String { rawValue }

    var intervalDays: Int {
        switch self {
        case .daily: return 1
        case .weekly: return 7
        case .biweekly: return 14
        case .monthly: return 30
        case .custom: return 7 // Default, will be overridden
        }
    }

    var description: String {
        switch self {
        case .daily: return "Remind every day"
        case .weekly: return "Remind every 7 days"
        case .biweekly: return "Remind every 14 days"
        case .monthly: return "Remind every 30 days"
        case .custom: return "Set your own interval"
        }
    }
}

struct ReminderScheduleSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex

    let activityCount: Int
    let onSkip: () -> Void
    let onSchedule: (Int, Date) -> Void // (intervalDays, reminderTime)

    @State private var selectedFrequency: ReminderFrequency = .weekly
    @State private var customIntervalDays: Int = 7
    @State private var reminderTime: Date = {
        // Default to 9:00 AM
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 9
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()

    private var effectiveIntervalDays: Int {
        selectedFrequency == .custom ? customIntervalDays : selectedFrequency.intervalDays
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 50))
                        .foregroundStyle(SoftColors.softBlue)

                    Text("Schedule Reminders?")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Would you like to set up gentle reminders for these \(activityCount) activities?")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 24)
                .padding(.bottom, 16)

                // Options
                Form {
                    Section {
                        ForEach(ReminderFrequency.allCases) { frequency in
                            Button {
                                selectedFrequency = frequency
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(frequency.rawValue)
                                            .font(.body)
                                            .foregroundStyle(.primary)
                                        Text(frequency.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    if selectedFrequency == frequency {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(SoftColors.softGreen)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }

                        if selectedFrequency == .custom {
                            Stepper("Every \(customIntervalDays) days", value: $customIntervalDays, in: 1...365)
                                .padding(.top, 4)
                        }
                    } header: {
                        Text("Frequency")
                    }

                    Section {
                        DatePicker(
                            "Reminder Time",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                    } header: {
                        Text("Time of Day")
                    } footer: {
                        Text("You'll receive a gentle reminder at this time.")
                    }
                }
                .scrollContentBackground(.hidden)
                .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)

                // Bottom buttons
                VStack(spacing: 12) {
                    Button {
                        onSchedule(effectiveIntervalDays, reminderTime)
                        dismiss()
                    } label: {
                        Text("Add Reminders")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        onSkip()
                        dismiss()
                    } label: {
                        Text("Skip for Now")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)
            }
            .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)
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

#Preview {
    ReminderScheduleSheet(
        activityCount: 5,
        onSkip: { print("Skipped") },
        onSchedule: { interval, time in print("Scheduled: \(interval) days at \(time)") }
    )
    .preferredColorScheme(.dark)
}
