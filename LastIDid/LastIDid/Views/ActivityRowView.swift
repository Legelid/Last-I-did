//
//  ActivityRowView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import SwiftUI

struct ActivityRowView: View {
    @Environment(\.agingColorIntensity) private var colorIntensity
    @AppStorage(AppPreferenceKey.useSoftColors) private var useSoftColors = true
    @AppStorage(AppPreferenceKey.useSoftLanguage) private var useSoftLanguage = true

    let activity: Activity
    var onMarkDone: (() -> Void)?
    var onMarkDoneYesterday: (() -> Void)?
    var onMarkDoneWithNote: (() -> Void)?

    private var agingColor: Color {
        if useSoftColors {
            return activity.agingState.softColor
        }
        return activity.agingState.color(intensity: colorIntensity)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Emoji or Aging indicator
            if let emoji = activity.emoji, !emoji.isEmpty {
                Text(emoji)
                    .font(.system(size: 24))
                    .frame(width: 28, height: 28)
            } else {
                AgingIndicator(state: activity.agingState, size: .medium, useSoftColors: useSoftColors)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(activity.name)
                    .font(.headline)

                HStack(spacing: 8) {
                    Text(relativeTimeString)
                        .font(.subheadline)
                        .foregroundStyle(agingColor)

                    if let lastCompleted = activity.lastCompletedDate {
                        Text("•")
                            .foregroundStyle(.tertiary)
                        Text(lastCompleted.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                // Category badges (compact)
                if !activity.categories.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(activity.categories.prefix(3)) { category in
                            HStack(spacing: 2) {
                                Image(systemName: category.systemIcon)
                                    .font(.system(size: 8))
                                Text(category.name)
                                    .font(.system(size: 10))
                            }
                            .foregroundStyle(category.color)
                        }
                        if activity.categories.count > 3 {
                            Text("+\(activity.categories.count - 3)")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Spacer()

            // Reminder indicator
            if activity.reminderEnabled {
                Image(systemName: activity.reminderType == .recurring ? "repeat" : "bell.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .contextMenu {
            Button {
                onMarkDone?()
            } label: {
                Label("Mark Done", systemImage: "checkmark.circle.fill")
            }

            Button {
                onMarkDoneYesterday?()
            } label: {
                Label("Mark Done Yesterday", systemImage: "clock.arrow.circlepath")
            }

            Button {
                onMarkDoneWithNote?()
            } label: {
                Label("Mark with Note...", systemImage: "note.text")
            }

            Divider()

            if let days = activity.reminderIntervalDays, activity.reminderType == .recurring {
                Text("Reminds every \(days) days")
            }
        }
    }

    private var relativeTimeString: String {
        let days = activity.daysSinceLastCompleted
        if useSoftLanguage {
            return SoftLanguage.timeSince(days)
        }

        if days == Int.max {
            return "Never done"
        }
        switch days {
        case 0:
            return "Today"
        case 1:
            return "Yesterday"
        default:
            return "\(days) days ago"
        }
    }
}

#Preview {
    List {
        ActivityRowView(
            activity: {
                let a = Activity(name: "Water plants")
                a.markCompleted()
                return a
            }()
        )
        ActivityRowView(
            activity: {
                let a = Activity(name: "Change air filter")
                a.markCompleted(backdatedTo: Calendar.current.date(byAdding: .day, value: -15, to: Date()))
                return a
            }()
        )
        ActivityRowView(
            activity: {
                let a = Activity(name: "Oil change")
                a.markCompleted(backdatedTo: Calendar.current.date(byAdding: .day, value: -45, to: Date()))
                return a
            }()
        )
        ActivityRowView(activity: Activity(name: "New task - never done"))
    }
    .preferredColorScheme(.dark)
}
