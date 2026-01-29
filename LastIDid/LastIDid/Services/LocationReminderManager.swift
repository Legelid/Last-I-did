//
//  LocationReminderManager.swift
//  LastIDid
//
//  Created by Claude on 1/21/26.
//

import Foundation
import CoreLocation
import UserNotifications
import SwiftData
import Combine

class LocationReminderManager: NSObject, ObservableObject {
    static let shared = LocationReminderManager()

    // MARK: - Published Properties

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentlyMonitored: Set<UUID> = []
    @Published var userLocation: CLLocation?
    @Published var isCheckingPermission = false

    // MARK: - Private Properties

    private let locationManager = CLLocationManager()
    private var modelContext: ModelContext?

    // iOS hard limit for monitored regions
    private let maxMonitoredRegions = 20

    // Refresh threshold for significant location change (meters)
    private let significantDistanceThreshold: Double = 5000 // 5km

    private var lastRefreshLocation: CLLocation?

    // MARK: - Initialization

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.allowsBackgroundLocationUpdates = false
        checkAuthorizationStatus()
    }

    // MARK: - Model Context Setup

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Permission Handling

    func checkAuthorizationStatus() {
        authorizationStatus = locationManager.authorizationStatus
    }

    var hasLocationPermission: Bool {
        authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse
    }

    var hasAlwaysPermission: Bool {
        authorizationStatus == .authorizedAlways
    }

    var permissionDescription: String {
        switch authorizationStatus {
        case .notDetermined:
            return "Not determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedWhenInUse:
            return "When in use"
        case .authorizedAlways:
            return "Always"
        @unknown default:
            return "Unknown"
        }
    }

    func requestWhenInUsePermission() {
        isCheckingPermission = true
        locationManager.requestWhenInUseAuthorization()
    }

    func requestAlwaysPermission() {
        isCheckingPermission = true
        locationManager.requestAlwaysAuthorization()
    }

    func requestPermissions() {
        if authorizationStatus == .notDetermined {
            requestWhenInUsePermission()
        } else if authorizationStatus == .authorizedWhenInUse {
            requestAlwaysPermission()
        }
    }

    // MARK: - Location Updates

    func startUpdatingLocation() {
        guard hasLocationPermission else { return }
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func requestCurrentLocation() {
        guard hasLocationPermission else { return }
        locationManager.requestLocation()
    }

    // MARK: - Geofence Management

    func refreshGeofences() {
        guard hasLocationPermission, let context = modelContext else { return }

        // Stop monitoring all current regions
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        currentlyMonitored.removeAll()

        // Fetch all reminders
        let descriptor = FetchDescriptor<LocationReminder>()
        guard let allReminders = try? context.fetch(descriptor) else { return }

        // Select top reminders for monitoring
        let remindersToMonitor = selectRemindersForMonitoring(from: allReminders)

        // Register each with CoreLocation
        for reminder in remindersToMonitor {
            let region = reminder.region
            locationManager.startMonitoring(for: region)
            currentlyMonitored.insert(reminder.id)
        }

        lastRefreshLocation = userLocation
    }

    // MARK: - Selection Algorithm

    private func selectRemindersForMonitoring(from reminders: [LocationReminder]) -> [LocationReminder] {
        // Step 1: Filter eligible reminders (enabled and not in cooldown)
        var eligible = reminders.filter { $0.isEligibleForMonitoring }

        // Step 2: Sort by priority and distance
        if let location = userLocation {
            eligible.sort { reminder1, reminder2 in
                // Manual priority takes precedence (lower = higher priority)
                if let p1 = reminder1.manualPriority, let p2 = reminder2.manualPriority {
                    if p1 != p2 { return p1 < p2 }
                } else if reminder1.manualPriority != nil {
                    return true
                } else if reminder2.manualPriority != nil {
                    return false
                }

                // Then sort by distance (closer = higher priority)
                return reminder1.distance(from: location) < reminder2.distance(from: location)
            }
        } else {
            // No user location - sort by manual priority, then creation date
            eligible.sort { reminder1, reminder2 in
                if let p1 = reminder1.manualPriority, let p2 = reminder2.manualPriority {
                    if p1 != p2 { return p1 < p2 }
                } else if reminder1.manualPriority != nil {
                    return true
                } else if reminder2.manualPriority != nil {
                    return false
                }
                return reminder1.createdDate < reminder2.createdDate
            }
        }

        // Step 3: Take top 20
        return Array(eligible.prefix(maxMonitoredRegions))
    }

    // MARK: - Reminder CRUD Operations

    func addReminder(_ reminder: LocationReminder) {
        guard let context = modelContext else { return }
        context.insert(reminder)
        try? context.save()
        refreshGeofences()
    }

    func updateReminder(_ reminder: LocationReminder) {
        guard let context = modelContext else { return }
        try? context.save()
        refreshGeofences()
    }

    func deleteReminder(_ reminder: LocationReminder) {
        guard let context = modelContext else { return }

        // Stop monitoring if active
        if currentlyMonitored.contains(reminder.id) {
            let region = reminder.region
            locationManager.stopMonitoring(for: region)
            currentlyMonitored.remove(reminder.id)
        }

        context.delete(reminder)
        try? context.save()
        refreshGeofences()
    }

    func toggleReminder(_ reminder: LocationReminder) {
        reminder.isEnabled.toggle()
        guard let context = modelContext else { return }
        try? context.save()
        refreshGeofences()
    }

    // MARK: - Status Helpers

    func status(for reminder: LocationReminder) -> ReminderStatus {
        if !reminder.isEnabled {
            return .paused
        }
        if reminder.isInCooldown {
            return .cooldown
        }
        if currentlyMonitored.contains(reminder.id) {
            return .monitoring
        }
        return .tooFar
    }

    // MARK: - Notification Handling

    private func sendNotification(for reminder: LocationReminder) {
        let content = UNMutableNotificationContent()
        content.title = gentleTitle()
        content.body = "You're near \(reminder.locationName). \(reminder.title)"
        content.sound = .default
        content.userInfo = ["reminderID": reminder.id.uuidString]

        let request = UNNotificationRequest(
            identifier: "location-\(reminder.id.uuidString)",
            content: content,
            trigger: nil // Deliver immediately
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send location reminder notification: \(error.localizedDescription)")
            }
        }
    }

    private func gentleTitle() -> String {
        let titles = [
            "Location reminder",
            "You're nearby",
            "Just a heads up",
            "While you're here"
        ]
        return titles.randomElement() ?? "Location reminder"
    }

    // MARK: - Refresh Triggers

    private func shouldRefreshBasedOnLocation(_ newLocation: CLLocation) -> Bool {
        guard let lastLocation = lastRefreshLocation else {
            return true
        }
        return newLocation.distance(from: lastLocation) > significantDistanceThreshold
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationReminderManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            self.isCheckingPermission = false

            if self.hasLocationPermission {
                self.requestCurrentLocation()
                self.refreshGeofences()
            } else {
                // Stop monitoring all regions if permission revoked
                for region in manager.monitoredRegions {
                    manager.stopMonitoring(for: region)
                }
                self.currentlyMonitored.removeAll()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        DispatchQueue.main.async {
            self.userLocation = location

            // Check if we should refresh based on significant movement
            if self.shouldRefreshBasedOnLocation(location) {
                self.refreshGeofences()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion,
              let context = modelContext,
              let reminderID = UUID(uuidString: circularRegion.identifier) else { return }

        // Find the reminder
        let descriptor = FetchDescriptor<LocationReminder>(
            predicate: #Predicate { reminder in
                reminder.id == reminderID
            }
        )

        guard let reminders = try? context.fetch(descriptor),
              let reminder = reminders.first else { return }

        // Send notification
        sendNotification(for: reminder)

        // Mark as triggered and apply cooldown
        DispatchQueue.main.async {
            reminder.markTriggered()
            try? context.save()

            // Refresh geofences to rotate in next-closest
            self.refreshGeofences()
        }
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        if let region = region {
            print("Monitoring failed for region \(region.identifier): \(error.localizedDescription)")
        } else {
            print("Monitoring failed: \(error.localizedDescription)")
        }
    }
}
