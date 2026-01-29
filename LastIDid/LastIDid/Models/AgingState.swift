//
//  AgingState.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import Foundation
import SwiftUI

enum AgingState: String, CaseIterable {
    case fresh      // Green: 0-7 days
    case aging      // Yellow: 8-30 days
    case stale      // Red: 31+ days
    case never      // Gray: Never completed

    var color: Color {
        switch self {
        case .fresh: return .green
        case .aging: return .yellow
        case .stale: return .red
        case .never: return .gray
        }
    }

    var icon: String {
        switch self {
        case .fresh: return "checkmark.circle.fill"
        case .aging: return "clock.fill"
        case .stale: return "exclamationmark.circle.fill"
        case .never: return "circle.dashed"
        }
    }

    var label: String {
        switch self {
        case .fresh: return "Fresh"
        case .aging: return "Aging"
        case .stale: return "Overdue"
        case .never: return "Never done"
        }
    }

    static func from(daysSince: Int) -> AgingState {
        if daysSince == Int.max {
            return .never
        } else if daysSince <= 7 {
            return .fresh
        } else if daysSince <= 30 {
            return .aging
        } else {
            return .stale
        }
    }
}

// Extension for intensity-aware colors
extension AgingState {
    func color(intensity: AgingColorIntensity) -> Color {
        switch intensity {
        case .subtle:
            return color.opacity(0.7)
        case .standard:
            return color
        case .highContrast:
            // Brighter, more saturated versions
            switch self {
            case .fresh: return Color(red: 0.2, green: 1.0, blue: 0.2)
            case .aging: return Color(red: 1.0, green: 0.9, blue: 0.0)
            case .stale: return Color(red: 1.0, green: 0.2, blue: 0.2)
            case .never: return Color(white: 0.6)
            }
        }
    }
}

// Extension to get aging state from Activity
extension Activity {
    var agingState: AgingState {
        AgingState.from(daysSince: daysSinceLastCompleted)
    }
}
