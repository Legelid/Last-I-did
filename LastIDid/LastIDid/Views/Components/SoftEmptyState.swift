//
//  SoftEmptyState.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import SwiftUI

/// A supportive, encouraging empty state component
struct SoftEmptyState: View {
    let title: String
    let subtitle: String
    var icon: String = "leaf.fill"
    var iconColor: Color = SoftColors.softGreen
    var action: (() -> Void)? = nil
    var actionLabel: String = "Get Started"

    var body: some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(iconColor)
            }

            // Text
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(.horizontal, 32)

            // Optional action button
            if let action = action {
                Button(action: action) {
                    Text(actionLabel)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Preset Empty States

extension SoftEmptyState {
    /// Empty state for no activities
    static func noActivities(action: @escaping () -> Void) -> SoftEmptyState {
        SoftEmptyState(
            title: SoftLanguage.EmptyStates.noActivities,
            subtitle: SoftLanguage.EmptyStates.noActivitiesSubtitle,
            icon: "sparkles",
            iconColor: SoftColors.softPurple,
            action: action,
            actionLabel: "Add Activity"
        )
    }

    /// Empty state for no completions on an activity
    static var noCompletions: SoftEmptyState {
        SoftEmptyState(
            title: SoftLanguage.EmptyStates.noCompletions,
            subtitle: SoftLanguage.EmptyStates.noCompletionsSubtitle,
            icon: "flag.fill",
            iconColor: SoftColors.softBlue
        )
    }

    /// Empty state for no history
    static var noHistory: SoftEmptyState {
        SoftEmptyState(
            title: SoftLanguage.EmptyStates.noHistory,
            subtitle: SoftLanguage.EmptyStates.noHistorySubtitle,
            icon: "clock.fill",
            iconColor: SoftColors.warmAmber
        )
    }

    /// Empty state for no insights
    static var noInsights: SoftEmptyState {
        SoftEmptyState(
            title: SoftLanguage.EmptyStates.noInsights,
            subtitle: SoftLanguage.EmptyStates.noInsightsSubtitle,
            icon: "chart.line.uptrend.xyaxis",
            iconColor: SoftColors.softTeal
        )
    }

    /// Empty state for no filtered results
    static var noFilteredActivities: SoftEmptyState {
        SoftEmptyState(
            title: SoftLanguage.EmptyStates.noFilteredActivities,
            subtitle: "Try adjusting your filters",
            icon: "magnifyingglass",
            iconColor: SoftColors.gentleGray
        )
    }

    /// Empty state for no categorized activities
    static var noCategorizedActivities: SoftEmptyState {
        SoftEmptyState(
            title: SoftLanguage.EmptyStates.noCategorizedActivities,
            subtitle: "Activities you add to this category will appear here",
            icon: "folder.fill",
            iconColor: SoftColors.softOrange
        )
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 40) {
            SoftEmptyState.noActivities {
                print("Add activity tapped")
            }

            Divider()

            SoftEmptyState.noCompletions

            Divider()

            SoftEmptyState.noHistory

            Divider()

            SoftEmptyState.noInsights

            Divider()

            SoftEmptyState.noFilteredActivities
        }
        .padding()
    }
    .background(Color.black)
    .preferredColorScheme(.dark)
}
