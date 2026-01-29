//
//  LocationReminderDetailView.swift
//  LastIDid
//
//  Created by Claude on 1/21/26.
//

import SwiftUI
import MapKit

struct LocationReminderDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @StateObject private var locationManager = LocationReminderManager.shared

    @Bindable var reminder: LocationReminder

    @State private var showingDeleteAlert = false
    @State private var editedTitle: String = ""
    @State private var editedRadius: Double = 100
    @State private var editedCooldown: CooldownDuration = .twentyFourHours
    @State private var editedPriority: Int? = nil

    var body: some View {
        NavigationStack {
            Form {
                // Status section
                Section {
                    HStack {
                        Text("Status")
                        Spacer()
                        ReminderStatusBadge(
                            status: locationManager.status(for: reminder),
                            cooldownRemaining: reminder.cooldownRemainingFormatted
                        )
                    }

                    if let distance = formattedDistance {
                        HStack {
                            Text("Distance")
                            Spacer()
                            Text(distance)
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack {
                        Text("Trigger count")
                        Spacer()
                        Text("\(reminder.triggerCount)")
                            .foregroundStyle(.secondary)
                    }

                    if let lastTriggered = reminder.lastTriggeredDate {
                        HStack {
                            Text("Last triggered")
                            Spacer()
                            Text(lastTriggered, style: .relative)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Edit section
                Section {
                    TextField("Title", text: $editedTitle)
                        .onChange(of: editedTitle) { _, newValue in
                            reminder.title = newValue
                        }
                } header: {
                    Text("Details")
                }

                // Location section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundStyle(.red)
                            Text(reminder.locationName)
                                .fontWeight(.medium)
                        }

                        // Map preview
                        Map(position: .constant(.region(MKCoordinateRegion(
                            center: reminder.coordinate,
                            latitudinalMeters: editedRadius * 3,
                            longitudinalMeters: editedRadius * 3
                        )))) {
                            MapCircle(center: reminder.coordinate, radius: editedRadius)
                                .foregroundStyle(.blue.opacity(0.2))
                                .stroke(.blue, lineWidth: 2)
                            Marker(reminder.locationName, coordinate: reminder.coordinate)
                        }
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .disabled(true)
                    }
                } header: {
                    Text("Location")
                }

                // Settings section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Trigger radius")
                            Spacer()
                            Text("\(Int(editedRadius))m")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $editedRadius, in: 50...500, step: 25)
                            .onChange(of: editedRadius) { _, newValue in
                                reminder.radius = newValue
                            }
                    }

                    Picker("Cooldown", selection: $editedCooldown) {
                        ForEach(CooldownDuration.allCases) { duration in
                            Text(duration.label).tag(duration)
                        }
                    }
                    .onChange(of: editedCooldown) { _, newValue in
                        reminder.cooldownHours = newValue.rawValue
                    }

                    Picker("Priority", selection: $editedPriority) {
                        Text("Auto").tag(nil as Int?)
                        ForEach(1...5, id: \.self) { priority in
                            Text("\(priority) - \(priorityLabel(priority))").tag(priority as Int?)
                        }
                    }
                    .onChange(of: editedPriority) { _, newValue in
                        reminder.manualPriority = newValue
                    }
                } header: {
                    Text("Settings")
                } footer: {
                    Text("Higher priority reminders are monitored first. 'Auto' prioritizes by distance.")
                }

                // Toggle section
                Section {
                    Toggle("Enabled", isOn: Binding(
                        get: { reminder.isEnabled },
                        set: { newValue in
                            reminder.isEnabled = newValue
                            locationManager.refreshGeofences()
                        }
                    ))
                }

                // Info section
                Section {
                    HStack {
                        Text("Created")
                        Spacer()
                        Text(reminder.createdDate, style: .date)
                            .foregroundStyle(.secondary)
                    }
                }

                // Delete section
                Section {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Reminder")
                        }
                    }
                }
            }
            .navigationTitle("Reminder Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveChanges()
                        dismiss()
                    }
                }
            }
            .alert("Delete Reminder?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    locationManager.deleteReminder(reminder)
                    dismiss()
                }
            } message: {
                Text("This cannot be undone.")
            }
            .onAppear {
                loadValues()
                locationManager.setModelContext(modelContext)
            }
        }
    }

    // MARK: - Helpers

    private var formattedDistance: String? {
        guard let location = locationManager.userLocation else { return nil }
        return reminder.distanceFormatted(from: location)
    }

    private func priorityLabel(_ priority: Int) -> String {
        switch priority {
        case 1: return "Highest"
        case 2: return "High"
        case 3: return "Normal"
        case 4: return "Low"
        case 5: return "Lowest"
        default: return ""
        }
    }

    private func loadValues() {
        editedTitle = reminder.title
        editedRadius = reminder.radius
        editedCooldown = CooldownDuration(rawValue: reminder.cooldownHours) ?? .twentyFourHours
        editedPriority = reminder.manualPriority
    }

    private func saveChanges() {
        locationManager.updateReminder(reminder)
    }
}

#Preview {
    let reminder = LocationReminder(
        title: "Buy milk",
        locationName: "Walmart Supercenter",
        latitude: 37.7749,
        longitude: -122.4194
    )

    return LocationReminderDetailView(reminder: reminder)
        .modelContainer(for: [LocationReminder.self], inMemory: true)
        .preferredColorScheme(.dark)
}
