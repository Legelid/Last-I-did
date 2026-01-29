//
//  LocationReminder.swift
//  LastIDid
//
//  Created by Claude on 1/21/26.
//

import Foundation
import SwiftData
import CoreLocation

enum ReminderStatus: String, Codable, CaseIterable {
    case monitoring    // Actively registered with CoreLocation
    case cooldown      // Recently triggered, waiting for cooldown
    case tooFar        // Not in top 20 by distance
    case paused        // User disabled

    var label: String {
        switch self {
        case .monitoring: return "Monitoring"
        case .cooldown: return "Cooldown"
        case .tooFar: return "Too far"
        case .paused: return "Paused"
        }
    }

    var icon: String {
        switch self {
        case .monitoring: return "checkmark.circle.fill"
        case .cooldown: return "clock.fill"
        case .tooFar: return "location.slash"
        case .paused: return "pause.circle.fill"
        }
    }
}

enum CooldownDuration: Int, Codable, CaseIterable, Identifiable {
    case oneHour = 1
    case sixHours = 6
    case twentyFourHours = 24
    case oneWeek = 168

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .oneHour: return "1 hour"
        case .sixHours: return "6 hours"
        case .twentyFourHours: return "24 hours"
        case .oneWeek: return "1 week"
        }
    }

    var description: String {
        switch self {
        case .oneHour: return "Frequent tasks"
        case .sixHours: return "Regular tasks"
        case .twentyFourHours: return "Default"
        case .oneWeek: return "Infrequent tasks"
        }
    }
}

@Model
final class LocationReminder {
    var id: UUID
    var title: String                       // "Buy milk at Walmart"
    var locationName: String                // "Walmart Supercenter"
    var latitude: Double
    var longitude: Double
    var radius: Double                      // Meters (default: 100)
    var isEnabled: Bool                     // User can disable
    var linkedActivityID: UUID?             // Optional link to Activity

    // Trigger management
    var lastTriggeredDate: Date?
    var cooldownHours: Int                  // Default: 24
    var triggerCount: Int

    // Metadata
    var createdDate: Date
    var manualPriority: Int?                // User-set priority 1-5

    init(
        title: String,
        locationName: String,
        latitude: Double,
        longitude: Double,
        radius: Double = 100,
        linkedActivityID: UUID? = nil,
        cooldownHours: Int = 24,
        manualPriority: Int? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.isEnabled = true
        self.linkedActivityID = linkedActivityID
        self.lastTriggeredDate = nil
        self.cooldownHours = cooldownHours
        self.triggerCount = 0
        self.createdDate = Date()
        self.manualPriority = manualPriority
    }

    // MARK: - Computed Properties

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var region: CLCircularRegion {
        let region = CLCircularRegion(
            center: coordinate,
            radius: radius,
            identifier: id.uuidString
        )
        region.notifyOnEntry = true
        region.notifyOnExit = false
        return region
    }

    var isInCooldown: Bool {
        guard let lastTriggered = lastTriggeredDate else {
            return false
        }
        let cooldownEnd = lastTriggered.addingTimeInterval(TimeInterval(cooldownHours * 3600))
        return Date() < cooldownEnd
    }

    var cooldownEndDate: Date? {
        guard let lastTriggered = lastTriggeredDate else {
            return nil
        }
        return lastTriggered.addingTimeInterval(TimeInterval(cooldownHours * 3600))
    }

    var cooldownRemainingFormatted: String? {
        guard let endDate = cooldownEndDate, isInCooldown else {
            return nil
        }
        let remaining = endDate.timeIntervalSince(Date())
        let hours = Int(remaining / 3600)
        let minutes = Int((remaining.truncatingRemainder(dividingBy: 3600)) / 60)

        if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }

    var isEligibleForMonitoring: Bool {
        isEnabled && !isInCooldown
    }

    func distance(from location: CLLocation) -> CLLocationDistance {
        let reminderLocation = CLLocation(latitude: latitude, longitude: longitude)
        return location.distance(from: reminderLocation)
    }

    func distanceFormatted(from location: CLLocation) -> String {
        let distance = distance(from: location)
        let miles = distance / 1609.34

        if miles < 0.1 {
            let feet = distance * 3.28084
            return String(format: "%.0f ft", feet)
        } else if miles < 10 {
            return String(format: "%.1f mi", miles)
        } else {
            return String(format: "%.0f mi", miles)
        }
    }

    // MARK: - Methods

    func markTriggered() {
        lastTriggeredDate = Date()
        triggerCount += 1
    }
}
