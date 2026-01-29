//
//  CalendarManager.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import Foundation
import EventKit

class CalendarManager: ObservableObject {
    static let shared = CalendarManager()

    private let eventStore = EKEventStore()

    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var hasCalendarAccess = false

    private init() {
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    func checkAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        hasCalendarAccess = authorizationStatus == .fullAccess || authorizationStatus == .authorized
    }

    func requestAccess() async -> Bool {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            await MainActor.run {
                hasCalendarAccess = granted
                checkAuthorizationStatus()
            }
            return granted
        } catch {
            print("Calendar access error: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Calendar Events

    /// Get events from the user's calendar for context
    func getUpcomingEvents(days: Int = 7) -> [EKEvent] {
        guard hasCalendarAccess else { return [] }

        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: days, to: startDate)!

        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)

        return events.sorted { $0.startDate < $1.startDate }
    }

    /// Check if there are busy periods that might conflict with activity reminders
    func getBusyPeriods(on date: Date) -> [DateInterval] {
        guard hasCalendarAccess else { return [] }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        let events = eventStore.events(matching: predicate)

        return events.compactMap { event -> DateInterval? in
            guard !event.isAllDay else { return nil }
            return DateInterval(start: event.startDate, end: event.endDate)
        }
    }

    /// Suggest best time to complete an activity based on calendar
    func suggestTimeForActivity(duration: TimeInterval = 30 * 60, within days: Int = 3) -> Date? {
        guard hasCalendarAccess else { return nil }

        let calendar = Calendar.current
        let now = Date()

        for dayOffset in 0..<days {
            guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }

            let busyPeriods = getBusyPeriods(on: targetDate)

            // Try common good times: morning (9am), lunch (12pm), evening (6pm)
            let preferredHours = [9, 12, 18]

            for hour in preferredHours {
                guard var candidateStart = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: targetDate) else { continue }

                // Skip times in the past
                if candidateStart < now {
                    continue
                }

                let candidateEnd = candidateStart.addingTimeInterval(duration)

                // Check if this time conflicts with any busy period
                let hasConflict = busyPeriods.contains { busyPeriod in
                    let candidateInterval = DateInterval(start: candidateStart, end: candidateEnd)
                    return candidateInterval.intersects(busyPeriod)
                }

                if !hasConflict {
                    return candidateStart
                }
            }
        }

        return nil
    }

    // MARK: - Create Calendar Event for Activity

    func createReminderEvent(for activity: Activity, at date: Date, duration: TimeInterval = 30 * 60) async -> Bool {
        guard hasCalendarAccess else { return false }

        let event = EKEvent(eventStore: eventStore)
        event.title = "Do: \(activity.name)"
        event.startDate = date
        event.endDate = date.addingTimeInterval(duration)
        event.notes = activity.notes ?? "Activity from Last I Did"

        // Add an alert 15 minutes before
        event.addAlarm(EKAlarm(relativeOffset: -15 * 60))

        // Use default calendar
        event.calendar = eventStore.defaultCalendarForNewEvents

        do {
            try eventStore.save(event, span: .thisEvent)
            return true
        } catch {
            print("Failed to create calendar event: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Calendar Context View Data

    struct CalendarContext {
        let upcomingEvents: [EventSummary]
        let suggestedTime: Date?
        let isBusyToday: Bool
    }

    struct EventSummary: Identifiable {
        let id = UUID()
        let title: String
        let startDate: Date
        let isAllDay: Bool
    }

    func getCalendarContext() -> CalendarContext {
        let events = getUpcomingEvents(days: 3)
        let summaries = events.prefix(5).map { event in
            EventSummary(title: event.title, startDate: event.startDate, isAllDay: event.isAllDay)
        }

        let todayEvents = getBusyPeriods(on: Date())
        let suggestedTime = suggestTimeForActivity()

        return CalendarContext(
            upcomingEvents: Array(summaries),
            suggestedTime: suggestedTime,
            isBusyToday: todayEvents.count > 3
        )
    }
}
