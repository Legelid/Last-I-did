//
//  LifeCareCheckInCard.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/23/26.
//

import SwiftUI

/// A compassionate check-in card that replaces the health score with supportive reflection
struct LifeCareCheckInCard: View {
    let activities: [Activity]
    let userName: String?
    var backgroundColor: Color = Color(.secondarySystemBackground)

    private var checkInData: CheckInData {
        CheckInGenerator.generate(activities: activities, userName: userName)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(SoftColors.softGreen)

                Text("Life Care Check-In")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()
            }

            // Main message
            Text(checkInData.mainMessage)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            // Insight rows
            VStack(spacing: 12) {
                InsightRowView(
                    icon: "sparkles",
                    iconColor: .yellow,
                    text: checkInData.recentActivityInsight
                )

                InsightRowView(
                    icon: "calendar",
                    iconColor: .blue,
                    text: checkInData.patternInsight
                )

                if let encouragement = checkInData.encouragement {
                    InsightRowView(
                        icon: "heart",
                        iconColor: SoftColors.softGreen,
                        text: encouragement
                    )
                }
            }

            // Footer
            Text("This is just a reflection, not a scorecard.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(
            ZStack {
                backgroundColor
                SoftColors.softGreen.opacity(0.05)
            }
        )
        .cornerRadius(16)
    }
}

// MARK: - Insight Row View

private struct InsightRowView: View {
    let icon: String
    let iconColor: Color
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(iconColor)
                .frame(width: 20)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        LifeCareCheckInCard(
            activities: [],
            userName: "Alex",
            backgroundColor: Color(.secondarySystemBackground)
        )
        .padding()
    }
    .preferredColorScheme(.dark)
}
