//
//  InsightsView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex
    @Query private var activities: [Activity]
    @AppStorage(AppPreferenceKey.useSoftLanguage) private var useSoftLanguage = true
    @AppStorage(AppPreferenceKey.useSoftColors) private var useSoftColors = true
    @AppStorage("userName") private var userName: String = ""

    private var calculator: InsightsCalculator {
        InsightsCalculator(activities: activities)
    }

    private var patterns: PatternDetector.PatternSummary {
        PatternDetector.analyzePatterns(for: activities)
    }

    private var themeColors: ThemeColors {
        ThemeColors(theme: theme, customHex: customHex)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Life Care Check-In (replaces Health Score)
                    LifeCareCheckInCard(
                        activities: activities,
                        userName: userName.isEmpty ? nil : userName,
                        backgroundColor: themeColors.secondaryColor
                    )

                    // Overview Stats
                    OverviewStatsCard(calculator: calculator, backgroundColor: themeColors.secondaryColor)

                    // Aging Distribution
                    AgingDistributionCard(calculator: calculator, backgroundColor: themeColors.secondaryColor)

                    // Weekly Trend
                    WeeklyTrendCard(calculator: calculator, backgroundColor: themeColors.secondaryColor)

                    // Top Activities
                    TopActivitiesCard(calculator: calculator, backgroundColor: themeColors.secondaryColor)

                    // Category Breakdown
                    CategoryBreakdownCard(calculator: calculator, backgroundColor: themeColors.secondaryColor)

                    // Pattern Insights (when using soft language)
                    if useSoftLanguage {
                        PatternInsightsCard(patterns: patterns)
                    }
                }
                .padding()
            }
            .background(themeColors.primaryColor)
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Health Score Card
struct HealthScoreCard: View {
    let score: Int
    var backgroundColor: Color = Color(.secondarySystemBackground)
    var useSoftColors: Bool = true
    var useSoftLanguage: Bool = true

    private var scoreColor: Color {
        if useSoftColors {
            if score >= 80 { return SoftColors.softGreen }
            if score >= 60 { return SoftColors.warmAmber }
            return SoftColors.softOrange
        } else {
            if score >= 80 { return .green }
            if score >= 60 { return .yellow }
            return .red
        }
    }

    private var scoreLabel: String {
        if useSoftLanguage {
            return SoftLanguage.Scores.healthLabel(for: score)
        }
        if score >= 80 { return "Great!" }
        if score >= 60 { return "Good" }
        if score >= 40 { return "Needs attention" }
        return "Time to catch up"
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Maintenance Score")
                .font(.headline)
                .foregroundStyle(.secondary)

            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 12)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack {
                    Text("\(score)")
                        .font(.system(size: 36, weight: .bold))
                    Text(scoreLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(backgroundColor)
        .cornerRadius(16)
    }
}

// MARK: - Overview Stats Card
struct OverviewStatsCard: View {
    let calculator: InsightsCalculator
    var backgroundColor: Color = Color(.secondarySystemBackground)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatBox(title: "Activities", value: "\(calculator.totalActivities)", icon: "list.bullet", color: .blue, backgroundColor: backgroundColor.lightened(by: 0.05))
                StatBox(title: "Total Completions", value: "\(calculator.totalCompletions)", icon: "checkmark.circle", color: .green, backgroundColor: backgroundColor.lightened(by: 0.05))
                StatBox(title: "This Week", value: "\(calculator.completionsThisWeek)", icon: "calendar", color: .purple, backgroundColor: backgroundColor.lightened(by: 0.05))
                StatBox(title: SoftLanguage.Insights.needsAttention, value: "\(calculator.activitiesNeedingAttention)", icon: "heart", color: SoftColors.softOrange, backgroundColor: backgroundColor.lightened(by: 0.05))
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(16)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var backgroundColor: Color = Color(.tertiarySystemBackground)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

// MARK: - Aging Distribution Card
struct AgingDistributionCard: View {
    let calculator: InsightsCalculator
    var backgroundColor: Color = Color(.secondarySystemBackground)

    private var distribution: [AgingState: Int] {
        calculator.activitiesByAgingState()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Health")
                .font(.headline)

            HStack(spacing: 0) {
                ForEach(AgingState.allCases, id: \.self) { state in
                    let count = distribution[state] ?? 0
                    let total = calculator.totalActivities
                    let percentage = total > 0 ? CGFloat(count) / CGFloat(total) : 0

                    if percentage > 0 {
                        Rectangle()
                            .fill(state.color)
                            .frame(width: percentage * 300, height: 24)
                    }
                }
            }
            .cornerRadius(8)
            .frame(maxWidth: .infinity)

            HStack(spacing: 16) {
                ForEach(AgingState.allCases, id: \.self) { state in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(state.color)
                            .frame(width: 8, height: 8)
                        Text("\(distribution[state] ?? 0) \(state.label)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(16)
    }
}

// MARK: - Weekly Trend Card
struct WeeklyTrendCard: View {
    let calculator: InsightsCalculator
    var backgroundColor: Color = Color(.secondarySystemBackground)

    private var trendData: [WeeklyCompletion] {
        calculator.completionTrend(weeks: 4)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Completions")
                .font(.headline)

            if #available(iOS 16.0, *) {
                Chart(trendData) { week in
                    BarMark(
                        x: .value("Week", week.weekLabel),
                        y: .value("Completions", week.count)
                    )
                    .foregroundStyle(.blue.gradient)
                }
                .frame(height: 150)
            } else {
                // Fallback for older iOS
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(trendData) { week in
                        VStack {
                            Text("\(week.count)")
                                .font(.caption2)
                            Rectangle()
                                .fill(.blue)
                                .frame(width: 40, height: CGFloat(week.count * 10))
                            Text(week.weekLabel)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(16)
    }
}

// MARK: - Top Activities Card
struct TopActivitiesCard: View {
    let calculator: InsightsCalculator
    var backgroundColor: Color = Color(.secondarySystemBackground)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Insights")
                .font(.headline)

            if let mostCompleted = calculator.mostCompletedActivity {
                InsightRow(
                    icon: "star.fill",
                    iconColor: .yellow,
                    title: "Most Completed",
                    subtitle: mostCompleted.name,
                    value: "\(mostCompleted.completions.count) times"
                )
            }

            if let mostOverdue = calculator.mostOverdueActivity,
               mostOverdue.daysSinceLastCompleted != Int.max {
                InsightRow(
                    icon: "hourglass",
                    iconColor: SoftColors.softOrange,
                    title: SoftLanguage.Insights.longestWaiting,
                    subtitle: mostOverdue.name,
                    value: SoftLanguage.timeSince(mostOverdue.daysSinceLastCompleted)
                )
            }

            InsightRow(
                icon: "chart.line.uptrend.xyaxis",
                iconColor: .green,
                title: "Avg. per Week",
                subtitle: "All activities",
                value: String(format: "%.1f", calculator.averageCompletionsPerWeek)
            )
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(16)
    }
}

struct InsightRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .frame(width: 24)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Category Breakdown Card
struct CategoryBreakdownCard: View {
    let calculator: InsightsCalculator
    var backgroundColor: Color = Color(.secondarySystemBackground)

    private var categoryData: [(category: String, count: Int)] {
        calculator.completionsByCategory()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Completions by Category")
                .font(.headline)

            if categoryData.isEmpty {
                Text("No category data yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(categoryData.prefix(5), id: \.category) { item in
                    HStack {
                        Text(item.category)
                            .font(.subheadline)
                        Spacer()
                        Text("\(item.count)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(16)
    }
}

#Preview {
    InsightsView()
        .modelContainer(for: [Activity.self, CompletionRecord.self, Category.self], inMemory: true)
        .preferredColorScheme(.dark)
}
