//
//  MainTabView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/21/26.
//

import SwiftUI

// MARK: - Main Tab Enum

enum MainTab: String, CaseIterable, Identifiable {
    case activities = "Activities"
    case calendar = "Calendar"
    case add = "Add"
    case insights = "Insights"
    case reminders = "Reminders"
    case settings = "Settings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .activities: return "house.fill"
        case .calendar: return "calendar"
        case .add: return "plus"
        case .insights: return "chart.bar.fill"
        case .reminders: return "mappin.and.ellipse"
        case .settings: return "gearshape.fill"
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab: MainTab = .activities
    @State private var showingAddSheet = false

    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content area
            Group {
                switch selectedTab {
                case .activities:
                    ActivitiesTabView()
                case .calendar:
                    CalendarTabView()
                case .add:
                    Color.clear
                case .insights:
                    InsightsTabView()
                case .reminders:
                    RemindersTabView()
                case .settings:
                    SettingsTabView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            CustomTabBar(
                selectedTab: $selectedTab,
                showingAddSheet: $showingAddSheet
            )
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showingAddSheet) {
            ActivityFormView(mode: .add)
        }
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    @Binding var showingAddSheet: Bool

    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex

    // Tabs on each side of the center button (2 on each side)
    private let leftTabs: [MainTab] = [.activities, .calendar]
    private let rightTabs: [MainTab] = [.insights, .settings]

    var body: some View {
        HStack(spacing: 0) {
            // Left tabs
            ForEach(leftTabs) { tab in
                TabBarButton(tab: tab, selectedTab: $selectedTab)
            }

            // Center Add Button
            AddButton {
                showingAddSheet = true
            }
            .offset(y: -16)

            // Right tabs
            ForEach(rightTabs) { tab in
                TabBarButton(tab: tab, selectedTab: $selectedTab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Tab Bar Button

struct TabBarButton: View {
    let tab: MainTab
    @Binding var selectedTab: MainTab

    var isSelected: Bool {
        selectedTab == tab
    }

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20))
                    .symbolRenderingMode(.hierarchical)

                Text(tab.rawValue)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(isSelected ? Color.accentColor : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Prominent Add Button

struct AddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.accentColor.opacity(0.4), radius: 8, x: 0, y: 4)

                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 70)
    }
}

// MARK: - Activities Tab View (Wrapper)

struct ActivitiesTabView: View {
    var body: some View {
        ActivityListView()
    }
}

// MARK: - Insights Tab View (Wrapper)

struct InsightsTabView: View {
    var body: some View {
        NavigationStack {
            InsightsView()
        }
    }
}

// MARK: - Reminders Tab View (Wrapper)

struct RemindersTabView: View {
    var body: some View {
        LocationRemindersView()
    }
}

// MARK: - Settings Tab View (Wrapper)

struct SettingsTabView: View {
    var body: some View {
        SettingsView()
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
        .modelContainer(for: [Activity.self, CompletionRecord.self, Category.self, LocationReminder.self], inMemory: true)
}
