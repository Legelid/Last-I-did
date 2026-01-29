//
//  ActivitySurfacing.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/23/26.
//

import Foundation

/// Handles surfacing activities that haven't been touched recently
struct ActivitySurfacing {

    /// Get the top 3 activities that haven't been completed recently
    /// - Parameter activities: All activities to consider
    /// - Returns: Up to 3 activities sorted by days since last completion (most days first)
    static func getSurfacedActivities(_ activities: [Activity]) -> [Activity] {
        // Only include activities with completion history
        let withHistory = activities.filter { !$0.completions.isEmpty }

        // Sort by days since completion (most days first)
        let sorted = withHistory.sorted {
            $0.daysSinceLastCompleted > $1.daysSinceLastCompleted
        }

        // Return top 3
        return Array(sorted.prefix(3))
    }

    /// Get remaining activities (not in surfaced list)
    /// - Parameters:
    ///   - activities: All activities
    ///   - surfaced: Activities that were surfaced
    /// - Returns: Activities not in the surfaced list
    static func getRemainingActivities(_ activities: [Activity], excluding surfaced: [Activity]) -> [Activity] {
        let surfacedIDs = Set(surfaced.map { $0.id })
        return activities.filter { !surfacedIDs.contains($0.id) }
    }
}
