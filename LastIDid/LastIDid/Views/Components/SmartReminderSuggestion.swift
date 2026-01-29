//
//  SmartReminderSuggestion.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import SwiftUI

/// A gentle suggestion for setting up a reminder based on detected patterns
struct SmartReminderSuggestion: View {
    let activity: Activity
    let suggestedDays: Int
    let onAccept: () -> Void
    let onDismiss: () -> Void

    @State private var isDismissed = false

    var body: some View {
        if !isDismissed && !activity.reminderEnabled {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(SoftColors.warmAmber)

                    Text("Suggestion")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    Button {
                        withAnimation {
                            isDismissed = true
                        }
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(suggestionText)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Button {
                        HapticFeedback.tap()
                        onAccept()
                    } label: {
                        Text("Set Reminder")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .cornerRadius(8)
                    }

                    Button {
                        withAnimation {
                            isDismissed = true
                        }
                        onDismiss()
                    } label: {
                        Text("Not now")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(SoftColors.warmAmber.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(SoftColors.warmAmber.opacity(0.3), lineWidth: 1)
            )
            .transition(.scale.combined(with: .opacity))
        }
    }

    private var suggestionText: String {
        if suggestedDays == 1 {
            return "You seem to do \"\(activity.name)\" daily. Want a daily reminder?"
        } else if suggestedDays == 7 {
            return "You tend to do \"\(activity.name)\" about once a week. Want a weekly reminder?"
        } else if suggestedDays == 14 {
            return "You usually do \"\(activity.name)\" every couple weeks. Set a reminder?"
        } else if suggestedDays == 30 {
            return "You typically do \"\(activity.name)\" monthly. Would a monthly reminder help?"
        } else {
            return "Based on your history, you do \"\(activity.name)\" about every \(suggestedDays) days. Want a reminder?"
        }
    }
}

// MARK: - Smart Reminder Generator

struct SmartReminderGenerator {

    /// Generate a reminder suggestion for an activity based on its pattern
    static func suggestReminder(for activity: Activity) -> Int? {
        guard !activity.reminderEnabled else { return nil }

        if let pattern = PatternDetector.detectFrequencyPattern(for: activity) {
            // Only suggest if there's decent consistency
            guard pattern.consistency > 0.4 else { return nil }

            // Round to common intervals
            let days = pattern.averageDaysBetween

            switch days {
            case 1...2:
                return 1  // Daily
            case 3...5:
                return days
            case 6...9:
                return 7  // Weekly
            case 10...17:
                return 14  // Bi-weekly
            case 18...45:
                return 30  // Monthly
            default:
                return nil  // Too infrequent to suggest
            }
        }

        return nil
    }
}

// MARK: - Preview

#Preview {
    VStack {
        SmartReminderSuggestion(
            activity: Activity(name: "Water plants"),
            suggestedDays: 7,
            onAccept: {},
            onDismiss: {}
        )

        SmartReminderSuggestion(
            activity: Activity(name: "Change filter"),
            suggestedDays: 30,
            onAccept: {},
            onDismiss: {}
        )
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
