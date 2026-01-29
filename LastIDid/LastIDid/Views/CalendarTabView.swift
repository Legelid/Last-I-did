//
//  CalendarTabView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/21/26.
//

import SwiftUI
import SwiftData

struct CalendarTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex
    @Query(filter: #Predicate<Activity> { !$0.isArchived })
    private var activities: [Activity]

    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()

    private var themeColors: ThemeColors {
        ThemeColors(theme: theme, customHex: customHex)
    }

    private var calendar: Calendar {
        Calendar.current
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    private var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        let startDate = monthFirstWeek.start
        var dates: [Date] = []

        // Get 6 weeks of dates (42 days) to fill the calendar grid
        for dayOffset in 0..<42 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) {
                dates.append(date)
            }
        }

        return dates
    }

    private var activitiesForSelectedDate: [Activity] {
        activities.filter { activity in
            activity.completions.contains { completion in
                calendar.isDate(completion.completedDate, inSameDayAs: selectedDate)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Month header with navigation
                monthHeader
                    .padding(.horizontal)
                    .padding(.top, 16)

                // Day of week headers
                dayOfWeekHeader
                    .padding(.horizontal)
                    .padding(.top, 12)

                // Calendar grid
                calendarGrid
                    .padding(.horizontal)
                    .padding(.top, 8)

                Divider()
                    .background(themeColors.secondaryColor)
                    .padding(.vertical, 12)

                // Selected date activities
                selectedDateSection

                Spacer()
            }
            .background(themeColors.primaryColor)
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(8)
            }

            Spacer()

            Text(monthYearString)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(8)
            }
        }
    }

    // MARK: - Day of Week Header

    private var dayOfWeekHeader: some View {
        let weekdaySymbols = calendar.shortWeekdaySymbols

        return HStack(spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(daysInMonth, id: \.self) { date in
                calendarDayCell(for: date)
            }
        }
    }

    @ViewBuilder
    private func calendarDayCell(for date: Date) -> some View {
        let isCurrentMonth = calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let completionCount = completionCountFor(date: date)

        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedDate = date
            }
        } label: {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: isToday ? 18 : 15, weight: isToday ? .bold : .medium))
                    .foregroundStyle(
                        isSelected ? .white :
                            (isCurrentMonth ? (isToday ? Color.accentColor : .primary) : .secondary.opacity(0.5))
                    )

                // Activity indicator dots
                if completionCount > 0 && isCurrentMonth {
                    HStack(spacing: 2) {
                        ForEach(0..<min(completionCount, 3), id: \.self) { _ in
                            Circle()
                                .fill(isSelected ? .white : Color.accentColor)
                                .frame(width: 4, height: 4)
                        }
                    }
                } else {
                    // Placeholder for consistent height
                    Color.clear.frame(height: 4)
                }
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isSelected ? Color.accentColor :
                            (isToday ? themeColors.secondaryColor : Color.clear)
                    )
            )
        }
        .disabled(!isCurrentMonth)
    }

    private func completionCountFor(date: Date) -> Int {
        activities.reduce(0) { count, activity in
            count + activity.completions.filter { completion in
                calendar.isDate(completion.completedDate, inSameDayAs: date)
            }.count
        }
    }

    // MARK: - Selected Date Section

    private var selectedDateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(selectedDateString)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                if calendar.isDateInToday(selectedDate) {
                    Text("Today")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal)

            if activitiesForSelectedDate.isEmpty {
                Text("No activities completed on this day")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 8)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(activitiesForSelectedDate) { activity in
                            activityRow(for: activity)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private var selectedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: selectedDate)
    }

    @ViewBuilder
    private func activityRow(for activity: Activity) -> some View {
        HStack {
            if let category = activity.categories.first {
                Image(systemName: category.systemIcon)
                    .foregroundStyle(category.color)
                    .frame(width: 24)
            }

            Text(activity.name)
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(themeColors.secondaryColor)
        )
    }
}

#Preview {
    CalendarTabView()
        .preferredColorScheme(.dark)
        .modelContainer(for: [Activity.self, CompletionRecord.self, Category.self], inMemory: true)
}
