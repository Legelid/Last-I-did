//
//  LocationRemindersView.swift
//  LastIDid
//
//  Created by Claude on 1/21/26.
//

import SwiftUI
import SwiftData

struct LocationRemindersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LocationReminder.createdDate, order: .reverse) private var reminders: [LocationReminder]

    @StateObject private var locationManager = LocationReminderManager.shared

    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex

    @State private var showingAddSheet = false
    @State private var selectedReminder: LocationReminder?

    var body: some View {
        NavigationStack {
            Group {
                if reminders.isEmpty {
                    emptyStateView
                } else {
                    remindersList
                }
            }
            .scrollContentBackground(.hidden)
            .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)
            .navigationTitle("Location Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddLocationReminderView()
            }
            .sheet(item: $selectedReminder) { reminder in
                LocationReminderDetailView(reminder: reminder)
            }
            .onAppear {
                locationManager.setModelContext(modelContext)
                if locationManager.hasLocationPermission {
                    locationManager.requestCurrentLocation()
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Location Reminders")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Get notified when you arrive at specific places.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if !locationManager.hasLocationPermission {
                VStack(spacing: 12) {
                    Text("Location access required")
                        .font(.caption)
                        .foregroundStyle(.orange)

                    Button("Enable Location") {
                        locationManager.requestPermissions()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top, 8)
            } else {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add Reminder", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Reminders List

    private var remindersList: some View {
        List {
            // Permission banner if needed
            if !locationManager.hasAlwaysPermission && locationManager.hasLocationPermission {
                Section {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Background access recommended")
                                .font(.subheadline)
                            Text("Enable 'Always' for reminders when app is closed")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button("Enable") {
                            locationManager.requestAlwaysPermission()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }

            // Status header
            Section {
                HStack {
                    Text("Monitoring \(locationManager.currentlyMonitored.count) of \(eligibleCount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("iOS limit: 20")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Reminders grouped by status
            if !monitoringReminders.isEmpty {
                Section("Active") {
                    ForEach(monitoringReminders) { reminder in
                        reminderRow(for: reminder)
                    }
                    .onDelete { offsets in
                        deleteReminders(from: monitoringReminders, at: offsets)
                    }
                }
            }

            if !cooldownReminders.isEmpty {
                Section("In Cooldown") {
                    ForEach(cooldownReminders) { reminder in
                        reminderRow(for: reminder)
                    }
                    .onDelete { offsets in
                        deleteReminders(from: cooldownReminders, at: offsets)
                    }
                }
            }

            if !otherReminders.isEmpty {
                Section("Inactive") {
                    ForEach(otherReminders) { reminder in
                        reminderRow(for: reminder)
                    }
                    .onDelete { offsets in
                        deleteReminders(from: otherReminders, at: offsets)
                    }
                }
            }
        }
    }

    // MARK: - Reminder Row

    private func reminderRow(for reminder: LocationReminder) -> some View {
        LocationReminderRow(
            reminder: reminder,
            status: locationManager.status(for: reminder),
            userLocation: locationManager.userLocation
        )
        .onTapGesture {
            selectedReminder = reminder
        }
        .swipeActions(edge: .leading) {
            Button {
                locationManager.toggleReminder(reminder)
            } label: {
                Label(
                    reminder.isEnabled ? "Pause" : "Resume",
                    systemImage: reminder.isEnabled ? "pause" : "play"
                )
            }
            .tint(reminder.isEnabled ? .orange : .green)
        }
    }

    // MARK: - Filtering

    private var eligibleCount: Int {
        reminders.filter { $0.isEligibleForMonitoring }.count
    }

    private var monitoringReminders: [LocationReminder] {
        reminders.filter { locationManager.status(for: $0) == .monitoring }
    }

    private var cooldownReminders: [LocationReminder] {
        reminders.filter { locationManager.status(for: $0) == .cooldown }
    }

    private var otherReminders: [LocationReminder] {
        reminders.filter {
            let status = locationManager.status(for: $0)
            return status == .tooFar || status == .paused
        }
    }

    // MARK: - Actions

    private func deleteReminders(from list: [LocationReminder], at offsets: IndexSet) {
        for index in offsets {
            let reminder = list[index]
            locationManager.deleteReminder(reminder)
        }
    }
}

#Preview {
    LocationRemindersView()
        .modelContainer(for: [LocationReminder.self], inMemory: true)
        .preferredColorScheme(.dark)
}
