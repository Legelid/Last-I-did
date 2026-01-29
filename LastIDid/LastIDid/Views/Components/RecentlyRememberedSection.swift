//
//  RecentlyRememberedSection.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import SwiftUI
import SwiftData

/// A horizontal scroll view showing recently completed activities (last 7 days)
struct RecentlyRememberedSection: View {
    @Query private var activities: [Activity]

    private var recentCompletions: [(activity: Activity, completion: CompletionRecord)] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()

        var completions: [(activity: Activity, completion: CompletionRecord)] = []

        for activity in activities {
            for completion in activity.completions {
                if completion.completedDate >= sevenDaysAgo {
                    completions.append((activity: activity, completion: completion))
                }
            }
        }

        return completions.sorted { $0.completion.completedDate > $1.completion.completedDate }
    }

    var body: some View {
        if !recentCompletions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Recently Completed")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(recentCompletions.prefix(10), id: \.completion.id) { item in
                            RecentCompletionCard(activity: item.activity, completion: item.completion)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Recent Completion Card

struct RecentCompletionCard: View {
    let activity: Activity
    let completion: CompletionRecord

    private var relativeTime: String {
        let days = Calendar.current.dateComponents([.day], from: completion.completedDate, to: Date()).day ?? 0
        return SoftLanguage.timeSince(days)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Icon/Emoji
            if let emoji = activity.emoji, !emoji.isEmpty {
                Text(emoji)
                    .font(.system(size: 24))
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(SoftColors.softGreen)
            }

            // Activity name
            Text(activity.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)

            // Time
            Text(relativeTime)
                .font(.caption)
                .foregroundStyle(.secondary)

            // Note preview (if any)
            if let notes = completion.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .frame(width: 120, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        RecentlyRememberedSection()
    }
    .modelContainer(for: [Activity.self, CompletionRecord.self], inMemory: true)
    .background(Color.black)
    .preferredColorScheme(.dark)
}
