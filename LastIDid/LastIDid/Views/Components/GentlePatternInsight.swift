//
//  GentlePatternInsight.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import SwiftUI

/// Displays a gentle, observational pattern insight
struct GentlePatternInsight: View {
    let insight: PatternInsight

    enum PatternInsight {
        case dayPreference(activityName: String, day: String, confidence: Double)
        case timePreference(activityName: String, time: String, confidence: Double)
        case frequency(activityName: String, days: Int, consistency: Double)
        case weekendPreference(activityName: String, prefersWeekend: Bool, confidence: Double)

        var title: String {
            switch self {
            case .dayPreference(let name, _, _):
                return name
            case .timePreference(let name, _, _):
                return name
            case .frequency(let name, _, _):
                return name
            case .weekendPreference(let name, _, _):
                return name
            }
        }

        var description: String {
            switch self {
            case .dayPreference(_, let day, _):
                return "You often do this on \(day)s"
            case .timePreference(_, let time, _):
                return "Usually done in the \(time)"
            case .frequency(_, let days, _):
                if days == 1 {
                    return "You tend to do this daily"
                } else if days == 7 {
                    return "You tend to do this weekly"
                } else if days == 14 {
                    return "You tend to do this every couple weeks"
                } else if days == 30 {
                    return "You tend to do this monthly"
                } else {
                    return "Usually every \(days) days or so"
                }
            case .weekendPreference(_, let prefersWeekend, _):
                return prefersWeekend ? "Usually a weekend activity" : "Usually a weekday activity"
            }
        }

        var icon: String {
            switch self {
            case .dayPreference: return "calendar"
            case .timePreference: return "clock.fill"
            case .frequency: return "repeat"
            case .weekendPreference(_, let prefersWeekend, _):
                return prefersWeekend ? "sun.max.fill" : "briefcase.fill"
            }
        }

        var color: Color {
            switch self {
            case .dayPreference: return SoftColors.softBlue
            case .timePreference: return SoftColors.warmAmber
            case .frequency: return SoftColors.softGreen
            case .weekendPreference: return SoftColors.softPurple
            }
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(insight.color.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: insight.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(insight.color)
            }

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(insight.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Pattern Insights Card

struct PatternInsightsCard: View {
    let patterns: PatternDetector.PatternSummary

    private var insights: [GentlePatternInsight.PatternInsight] {
        var results: [GentlePatternInsight.PatternInsight] = []

        // Add top day patterns
        for pattern in patterns.dayPatterns.prefix(2) {
            results.append(.dayPreference(
                activityName: pattern.activityName,
                day: pattern.dayName,
                confidence: pattern.confidence
            ))
        }

        // Add top time patterns
        for pattern in patterns.timePatterns.prefix(2) {
            results.append(.timePreference(
                activityName: pattern.activityName,
                time: pattern.timeOfDay.rawValue,
                confidence: pattern.confidence
            ))
        }

        // Add top frequency patterns
        for pattern in patterns.frequencyPatterns.prefix(2) where pattern.consistency > 0.5 {
            results.append(.frequency(
                activityName: pattern.activityName,
                days: pattern.averageDaysBetween,
                consistency: pattern.consistency
            ))
        }

        // Add weekend patterns
        for pattern in patterns.weekendPatterns.prefix(1) {
            results.append(.weekendPreference(
                activityName: pattern.activityName,
                prefersWeekend: pattern.prefersWeekend,
                confidence: pattern.confidence
            ))
        }

        return results
    }

    var body: some View {
        if !insights.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(SoftColors.warmAmber)
                    Text("Your Patterns")
                        .font(.headline)
                }

                Text("We've noticed some patterns in how you work. These are just observations — you know yourself best!")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ForEach(insights.prefix(4), id: \.title) { insight in
                    GentlePatternInsight(insight: insight)
                }
            }
            .padding()
            .background(Color(white: 0.12))
            .cornerRadius(16)
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            GentlePatternInsight(insight: .dayPreference(
                activityName: "Water plants",
                day: "Sunday",
                confidence: 0.7
            ))

            GentlePatternInsight(insight: .timePreference(
                activityName: "Exercise",
                time: "morning",
                confidence: 0.65
            ))

            GentlePatternInsight(insight: .frequency(
                activityName: "Change filter",
                days: 30,
                consistency: 0.8
            ))

            GentlePatternInsight(insight: .weekendPreference(
                activityName: "Deep clean",
                prefersWeekend: true,
                confidence: 0.75
            ))
        }
        .padding()
    }
    .background(Color.black)
    .preferredColorScheme(.dark)
}
