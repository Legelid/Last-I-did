//
//  LocationReminderRow.swift
//  LastIDid
//
//  Created by Claude on 1/21/26.
//

import SwiftUI
import CoreLocation

struct LocationReminderRow: View {
    let reminder: LocationReminder
    let status: ReminderStatus
    var userLocation: CLLocation?

    var body: some View {
        HStack(spacing: 12) {
            // Location icon
            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundStyle(Color.accentColor)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .font(.body)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(reminder.locationName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    if let location = userLocation {
                        Text("(\(reminder.distanceFormatted(from: location)))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Status badge
            ReminderStatusBadge(
                status: status,
                cooldownRemaining: reminder.cooldownRemainingFormatted
            )
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

#Preview {
    let reminder = LocationReminder(
        title: "Buy milk",
        locationName: "Walmart Supercenter",
        latitude: 37.7749,
        longitude: -122.4194
    )

    return List {
        LocationReminderRow(
            reminder: reminder,
            status: .monitoring,
            userLocation: CLLocation(latitude: 37.78, longitude: -122.42)
        )
        LocationReminderRow(
            reminder: reminder,
            status: .cooldown,
            userLocation: CLLocation(latitude: 37.78, longitude: -122.42)
        )
        LocationReminderRow(
            reminder: reminder,
            status: .tooFar,
            userLocation: nil
        )
        LocationReminderRow(
            reminder: reminder,
            status: .paused,
            userLocation: nil
        )
    }
    .preferredColorScheme(.dark)
}
