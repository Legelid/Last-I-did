//
//  LastIDidWidget.swift
//  LastIDidWidget
//
//  Created by Andrew Collins on 1/20/26.
//

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Widget Bundle
@main
struct LastIDidWidgetBundle: WidgetBundle {
    var body: some Widget {
        OverdueActivitiesWidget()
        RecentActivityWidget()
        NextTaskWidget()
    }
}

// MARK: - Shared Data Provider
struct ActivityEntry: TimelineEntry {
    let date: Date
    let activities: [WidgetActivity]
    let configuration: ConfigurationAppIntent
}

struct WidgetActivity: Identifiable {
    let id: UUID
    let name: String
    let daysSince: Int
    let agingState: WidgetAgingState
    let categoryIcon: String?
    let categoryColorHex: String?
}

enum WidgetAgingState {
    case fresh, aging, stale, never

    var color: Color {
        switch self {
        case .fresh: return .green
        case .aging: return .yellow
        case .stale: return .red
        case .never: return .gray
        }
    }

    static func from(daysSince: Int) -> WidgetAgingState {
        if daysSince == Int.max { return .never }
        if daysSince <= 7 { return .fresh }
        if daysSince <= 30 { return .aging }
        return .stale
    }
}

// MARK: - Configuration Intent
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("Configure the widget")

    @Parameter(title: "Show Category Icons", default: true)
    var showCategoryIcons: Bool
}

// MARK: - Timeline Provider
struct ActivityTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> ActivityEntry {
        ActivityEntry(
            date: Date(),
            activities: [
                WidgetActivity(id: UUID(), name: "Change HVAC filter", daysSince: 45, agingState: .stale, categoryIcon: "house.fill", categoryColorHex: "F97316"),
                WidgetActivity(id: UUID(), name: "Oil change", daysSince: 12, agingState: .aging, categoryIcon: "car.fill", categoryColorHex: "3B82F6"),
                WidgetActivity(id: UUID(), name: "Water plants", daysSince: 2, agingState: .fresh, categoryIcon: "leaf.fill", categoryColorHex: "22C55E"),
            ],
            configuration: ConfigurationAppIntent()
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> ActivityEntry {
        await getEntry(for: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<ActivityEntry> {
        let entry = await getEntry(for: configuration)

        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    private func getEntry(for configuration: ConfigurationAppIntent) async -> ActivityEntry {
        // In a real implementation, you'd fetch from shared container/SwiftData
        // For now, return sample data
        let activities = await fetchActivities()
        return ActivityEntry(date: Date(), activities: activities, configuration: configuration)
    }

    @MainActor
    private func fetchActivities() async -> [WidgetActivity] {
        // This would use App Groups to access shared SwiftData
        // For now, return empty array - will be populated when App Groups are configured
        return []
    }
}

// MARK: - Overdue Activities Widget
struct OverdueActivitiesWidget: Widget {
    let kind: String = "OverdueActivitiesWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: ActivityTimelineProvider()
        ) { entry in
            OverdueWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Overdue Activities")
        .description("Shows activities that need attention")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct OverdueWidgetView: View {
    var entry: ActivityEntry

    private var overdueActivities: [WidgetActivity] {
        entry.activities
            .filter { $0.agingState == .stale || $0.agingState == .aging }
            .sorted { $0.daysSince > $1.daysSince }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.orange)
                Text("Needs Attention")
                    .font(.headline)
            }

            if overdueActivities.isEmpty {
                Spacer()
                Text("All caught up!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                ForEach(overdueActivities.prefix(3)) { activity in
                    HStack {
                        Circle()
                            .fill(activity.agingState.color)
                            .frame(width: 8, height: 8)
                        Text(activity.name)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                        Text("\(activity.daysSince)d")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Recent Activity Widget
struct RecentActivityWidget: Widget {
    let kind: String = "RecentActivityWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: ActivityTimelineProvider()
        ) { entry in
            RecentWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Recent Activity")
        .description("Shows your most recently completed activities")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct RecentWidgetView: View {
    var entry: ActivityEntry

    private var recentActivities: [WidgetActivity] {
        entry.activities
            .filter { $0.agingState == .fresh }
            .sorted { $0.daysSince < $1.daysSince }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Recently Done")
                    .font(.headline)
            }

            if recentActivities.isEmpty {
                Spacer()
                Text("No recent completions")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                ForEach(recentActivities.prefix(3)) { activity in
                    HStack {
                        if let icon = activity.categoryIcon {
                            Image(systemName: icon)
                                .font(.caption)
                                .foregroundStyle(Color(hex: activity.categoryColorHex ?? "808080") ?? .gray)
                        }
                        Text(activity.name)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                        Text(activity.daysSince == 0 ? "Today" : "\(activity.daysSince)d ago")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Next Task Widget
struct NextTaskWidget: Widget {
    let kind: String = "NextTaskWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: ActivityTimelineProvider()
        ) { entry in
            NextTaskWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Next Task")
        .description("Shows the activity that needs attention most")
        .supportedFamilies([.systemSmall])
    }
}

struct NextTaskWidgetView: View {
    var entry: ActivityEntry

    private var nextTask: WidgetActivity? {
        entry.activities.max { $0.daysSince < $1.daysSince }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let task = nextTask {
                HStack {
                    Circle()
                        .fill(task.agingState.color)
                        .frame(width: 12, height: 12)
                    Text("Next Up")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(task.name)
                    .font(.headline)
                    .lineLimit(2)

                Spacer()

                Text(task.daysSince == Int.max ? "Never done" : "\(task.daysSince) days ago")
                    .font(.caption)
                    .foregroundStyle(task.agingState.color)
            } else {
                Text("No activities")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

// MARK: - Color Extension (duplicated for widget target)
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Previews
#Preview("Overdue - Small", as: .systemSmall) {
    OverdueActivitiesWidget()
} timeline: {
    ActivityEntry(
        date: Date(),
        activities: [
            WidgetActivity(id: UUID(), name: "Change HVAC filter", daysSince: 45, agingState: .stale, categoryIcon: "house.fill", categoryColorHex: "F97316"),
            WidgetActivity(id: UUID(), name: "Oil change", daysSince: 12, agingState: .aging, categoryIcon: "car.fill", categoryColorHex: "3B82F6"),
        ],
        configuration: ConfigurationAppIntent()
    )
}

#Preview("Recent - Medium", as: .systemMedium) {
    RecentActivityWidget()
} timeline: {
    ActivityEntry(
        date: Date(),
        activities: [
            WidgetActivity(id: UUID(), name: "Water plants", daysSince: 0, agingState: .fresh, categoryIcon: "leaf.fill", categoryColorHex: "22C55E"),
            WidgetActivity(id: UUID(), name: "Replace toothbrush", daysSince: 2, agingState: .fresh, categoryIcon: "heart.fill", categoryColorHex: "EF4444"),
        ],
        configuration: ConfigurationAppIntent()
    )
}
