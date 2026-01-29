//
//  CalendarStripView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/21/26.
//

import SwiftUI
import SwiftData

// MARK: - Calendar Display Mode

enum CalendarDisplayMode: String, CaseIterable, Identifiable {
    case staticWeek = "staticWeek"
    case centeredScrolling = "centeredScrolling"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .staticWeek: return "Static Week"
        case .centeredScrolling: return "Centered Scrolling"
        }
    }

    static func from(_ rawValue: String) -> CalendarDisplayMode {
        CalendarDisplayMode(rawValue: rawValue) ?? .staticWeek
    }
}

// MARK: - Calendar Strip View

struct CalendarStripView: View {
    @Binding var selectedDate: Date?
    @AppStorage("calendarDisplayMode") private var calendarDisplayModeRaw = "staticWeek"
    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex

    @Query(filter: #Predicate<Activity> { !$0.isArchived })
    private var activities: [Activity]

    @State private var currentWeekStart: Date = Calendar.current.startOfWeek(for: Date())
    @State private var scrollOffset: CGFloat = 0

    private var calendarDisplayMode: CalendarDisplayMode {
        CalendarDisplayMode.from(calendarDisplayModeRaw)
    }

    private var themeColors: ThemeColors {
        ThemeColors(theme: theme, customHex: customHex)
    }

    private var calendar: Calendar {
        Calendar.current
    }

    var body: some View {
        VStack(spacing: 0) {
            // Month header
            monthHeader
                .padding(.horizontal, 16)
                .padding(.top, 8)

            // Calendar based on mode
            switch calendarDisplayMode {
            case .staticWeek:
                staticWeekView
            case .centeredScrolling:
                centeredScrollingView
            }
        }
        .background(themeColors.primaryColor)
        .offset(y: -50)
        .padding(.bottom, -50)
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    currentWeekStart = calendar.date(byAdding: .day, value: -7, to: currentWeekStart) ?? currentWeekStart
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(Circle().fill(themeColors.secondaryColor.opacity(0.5)))
            }

            Spacer()

            Text(monthYearString(for: currentWeekStart))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            Spacer()

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    currentWeekStart = calendar.date(byAdding: .day, value: 7, to: currentWeekStart) ?? currentWeekStart
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(Circle().fill(themeColors.secondaryColor.opacity(0.5)))
            }
        }
    }

    // MARK: - Static Week View (Mode A)
    // Full week always visible, today is 50% larger but position doesn't change

    private var staticWeekView: some View {
        HStack(spacing: 6) {
            ForEach(weekDays, id: \.self) { date in
                enhancedDayPill(for: date)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Centered Scrolling View (Mode B)
    // Today always centered and 50% larger, week scrolls around it

    private var centeredScrollingView: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(extendedWeekDays, id: \.self) { date in
                            enhancedDayPill(for: date)
                                .id(date)
                        }
                    }
                    .padding(.horizontal, (geometry.size.width - 90) / 2) // Center today
                }
                .onAppear {
                    // Scroll to today on appear
                    proxy.scrollTo(calendar.startOfDay(for: Date()), anchor: .center)
                }
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Enhanced Day Pill

    @ViewBuilder
    private func enhancedDayPill(for date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let isSelected = selectedDate != nil && calendar.isDate(date, inSameDayAs: selectedDate!)
        let completionStatus = completionStatusFor(date: date)

        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                if isSelected {
                    selectedDate = nil
                } else {
                    selectedDate = date
                }
            }
        } label: {
            VStack(spacing: 4) {
                // Month abbreviation (for first day of month or today)
                if calendar.component(.day, from: date) == 1 || isToday {
                    Text(monthAbbrev(for: date))
                        .font(.system(size: isToday ? 11 : 9))
                        .fontWeight(.medium)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                }

                // Day number
                Text(dayNumber(for: date))
                    .font(.system(size: isToday ? 24 : 18, weight: .bold))
                    .foregroundStyle(
                        isSelected ? .white :
                            (isToday ? Color.accentColor : .primary)
                    )

                // Day name
                Text(dayOfWeekAbbrev(for: date))
                    .font(.system(size: isToday ? 12 : 10))
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)

                // Completion indicator
                completionIndicator(status: completionStatus, isSelected: isSelected)
            }
            .frame(
                width: isToday ? 72 : 48,
                height: isToday ? 110 : 80
            )
            .background(
                RoundedRectangle(cornerRadius: isToday ? 16 : 12)
                    .fill(
                        isSelected ? Color.accentColor :
                            (isToday ? themeColors.secondaryColor : themeColors.secondaryColor.opacity(0.4))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: isToday ? 16 : 12)
                    .stroke(isToday && !isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Completion Indicator

    @ViewBuilder
    private func completionIndicator(status: CompletionStatus, isSelected: Bool) -> some View {
        switch status {
        case .allCompleted:
            Circle()
                .fill(isSelected ? .white : .green)
                .frame(width: 8, height: 8)
        case .someCompleted:
            Circle()
                .fill(isSelected ? .white : .orange)
                .frame(width: 8, height: 8)
        case .missed:
            Circle()
                .fill(isSelected ? .white : .red.opacity(0.7))
                .frame(width: 8, height: 8)
        case .none:
            Circle()
                .fill(Color.clear)
                .frame(width: 8, height: 8)
        }
    }

    // MARK: - Completion Status

    enum CompletionStatus {
        case allCompleted
        case someCompleted
        case missed
        case none
    }

    private func completionStatusFor(date: Date) -> CompletionStatus {
        let completionsOnDate = activities.reduce(0) { count, activity in
            count + activity.completions.filter { completion in
                calendar.isDate(completion.completedDate, inSameDayAs: date)
            }.count
        }

        if completionsOnDate > 0 {
            return .someCompleted
        }

        return .none
    }

    // MARK: - Computed Properties

    private var weekDays: [Date] {
        (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: currentWeekStart)
        }
    }

    private var extendedWeekDays: [Date] {
        // For centered scrolling, provide 21 days (3 weeks) for smooth scrolling
        let startDate = calendar.date(byAdding: .day, value: -7, to: currentWeekStart) ?? currentWeekStart
        return (0..<21).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startDate)
        }
    }

    // MARK: - Helper Functions

    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func monthAbbrev(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }

    private func dayOfWeekAbbrev(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private func dayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

// MARK: - Calendar Extension

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
}

#Preview("Static Week") {
    VStack {
        CalendarStripView(selectedDate: .constant(nil))
            .environment(\.backgroundTheme, .pureBlack)
        Spacer()
    }
    .preferredColorScheme(.dark)
    .modelContainer(for: [Activity.self, CompletionRecord.self, Category.self], inMemory: true)
}

#Preview("Centered Scrolling") {
    VStack {
        CalendarStripView(selectedDate: .constant(Date()))
            .environment(\.backgroundTheme, .pureBlack)
        Spacer()
    }
    .preferredColorScheme(.dark)
    .modelContainer(for: [Activity.self, CompletionRecord.self, Category.self], inMemory: true)
}
