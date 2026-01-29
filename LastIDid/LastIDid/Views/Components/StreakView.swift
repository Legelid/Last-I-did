//
//  StreakView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import SwiftUI
import SwiftData

struct StreakView: View {
    let activity: Activity

    private var onTimeStreak: Int {
        StreakCalculator.onTimeStreak(for: activity)
    }

    private var weeklyStreak: Int {
        StreakCalculator.weeklyStreak(for: activity)
    }

    private var bestStreak: Int {
        StreakCalculator.bestStreak(for: activity)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Streaks")
                .font(.headline)

            HStack(spacing: 16) {
                StreakBadge(
                    count: onTimeStreak,
                    label: "On-time",
                    icon: "clock.badge.checkmark.fill",
                    color: .green
                )

                StreakBadge(
                    count: weeklyStreak,
                    label: "Weeks",
                    icon: "calendar.badge.checkmark",
                    color: .blue
                )

                StreakBadge(
                    count: bestStreak,
                    label: "Best",
                    icon: "trophy.fill",
                    color: .orange
                )
            }

            if onTimeStreak >= 3 {
                Text(encouragementMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
    }

    private var encouragementMessage: String {
        SoftLanguage.Streaks.message(for: onTimeStreak)
    }
}

struct StreakBadge: View {
    let count: Int
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)

                VStack(spacing: 0) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundStyle(color)

                    Text("\(count)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(color)
                }
            }

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Compact Streak Indicator (for list rows)
struct CompactStreakIndicator: View {
    let streak: Int

    var body: some View {
        if streak >= 2 {
            HStack(spacing: 2) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 10))
                Text("\(streak)")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(.orange)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.orange.opacity(0.2))
            .cornerRadius(8)
        }
    }
}

// MARK: - Global Streak Summary View
struct StreakSummaryView: View {
    @Query private var activities: [Activity]

    private var summary: StreakCalculator.StreakSummary {
        StreakCalculator.calculateSummary(for: activities)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Daily streak highlight
            if summary.dailyStreak > 0 {
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.title)
                        .foregroundStyle(.orange)

                    VStack(alignment: .leading) {
                        Text("\(summary.dailyStreak) day streak!")
                            .font(.headline)
                        Text("You've completed at least one activity every day")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }

            // Top activity streaks
            if !summary.activityStreaks.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Activity Streaks")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ForEach(summary.activityStreaks.filter { $0.currentStreak >= 2 }.prefix(5)) { streak in
                        HStack {
                            Text(streak.activityName)
                                .font(.subheadline)
                                .lineLimit(1)

                            Spacer()

                            CompactStreakIndicator(streak: streak.currentStreak)
                        }
                    }

                    if summary.activityStreaks.filter({ $0.currentStreak >= 2 }).isEmpty {
                        Text("Complete activities on time to build streaks!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    VStack {
        StreakView(activity: Activity(name: "Test Activity"))
        Divider()
        StreakSummaryView()
    }
    .padding()
    .modelContainer(for: [Activity.self, CompletionRecord.self], inMemory: true)
    .preferredColorScheme(.dark)
}
