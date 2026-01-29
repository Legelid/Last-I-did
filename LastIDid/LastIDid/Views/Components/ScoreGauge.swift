//
//  ScoreGauge.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import SwiftUI
import SwiftData

struct ScoreGauge: View {
    let score: Int
    var size: Size = .medium
    var showLabel: Bool = true

    enum Size {
        case small, medium, large

        var diameter: CGFloat {
            switch self {
            case .small: return 60
            case .medium: return 100
            case .large: return 150
            }
        }

        var lineWidth: CGFloat {
            switch self {
            case .small: return 6
            case .medium: return 10
            case .large: return 14
            }
        }

        var fontSize: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 28
            case .large: return 42
            }
        }
    }

    private var scoreColor: Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .yellow
        case 40..<60: return .orange
        default: return .red
        }
    }

    private var gradientColors: [Color] {
        [scoreColor.opacity(0.7), scoreColor]
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: size.lineWidth)
                .frame(width: size.diameter, height: size.diameter)

            // Progress arc
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: size.lineWidth, lineCap: .round)
                )
                .frame(width: size.diameter, height: size.diameter)
                .rotationEffect(.degrees(-90))

            // Score text
            VStack(spacing: 0) {
                Text("\(score)")
                    .font(.system(size: size.fontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(scoreColor)

                if showLabel && size != .small {
                    Text("score")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Score Card View
struct ScoreCardView: View {
    @Query private var activities: [Activity]

    private var breakdown: ScoreCalculator.ScoreBreakdown {
        ScoreCalculator.calculateBreakdown(for: activities)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Main score
            HStack {
                ScoreGauge(score: breakdown.overallScore, size: .large)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Maintenance Score")
                        .font(.headline)

                    Text(ScoreCalculator.message(for: breakdown.overallScore))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack {
                        Image(systemName: breakdown.trend.icon)
                        Text(breakdown.trend.label)
                    }
                    .font(.caption)
                    .foregroundStyle(breakdown.trend == .declining ? .orange : .green)
                }

                Spacer()
            }

            Divider()

            // Activity status breakdown
            HStack(spacing: 20) {
                StatusPill(count: breakdown.freshCount, label: "Fresh", color: .green)
                StatusPill(count: breakdown.agingCount, label: "Aging", color: .yellow)
                StatusPill(count: breakdown.staleCount, label: "Overdue", color: .red)
                if breakdown.neverCount > 0 {
                    StatusPill(count: breakdown.neverCount, label: "New", color: .gray)
                }
            }

            // Category scores (if any need attention)
            let needsAttention = breakdown.categoryScores.filter { $0.score < 70 }
            if !needsAttention.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Categories needing attention")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ForEach(needsAttention.prefix(3)) { category in
                        HStack {
                            Text(category.name)
                                .font(.subheadline)
                            Spacer()
                            ScoreGauge(score: category.score, size: .small, showLabel: false)
                        }
                    }
                }
            }

            // Encouragement
            Text(ScoreCalculator.encouragement(for: breakdown.overallScore))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct StatusPill: View {
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(color)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Compact Score Badge (for headers)
struct CompactScoreBadge: View {
    let score: Int

    private var scoreColor: Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .yellow
        case 40..<60: return .orange
        default: return .red
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(scoreColor)
                .frame(width: 8, height: 8)
            Text("\(score)")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(scoreColor.opacity(0.2))
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            ScoreGauge(score: 95, size: .small)
            ScoreGauge(score: 72, size: .medium)
            ScoreGauge(score: 45, size: .large)
        }

        ScoreCardView()

        HStack {
            CompactScoreBadge(score: 85)
            CompactScoreBadge(score: 65)
            CompactScoreBadge(score: 35)
        }
    }
    .padding()
    .modelContainer(for: [Activity.self, CompletionRecord.self, Category.self], inMemory: true)
    .preferredColorScheme(.dark)
}
