//
//  SoftColors.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import SwiftUI

/// Soft, emotionally neutral color palette for supportive UI
struct SoftColors {
    // Primary soft palette
    static let softGreen = Color(hex: "7BC47F")!      // Fresh/On track
    static let warmAmber = Color(hex: "E8B84A")!      // Aging/Been a while
    static let softOrange = Color(hex: "F5A962")!     // Stale (replaces red!)
    static let gentleGray = Color(hex: "9CA3AF")!     // Never/Not yet started

    // Extended palette for UI elements
    static let softBlue = Color(hex: "6BA3D6")!       // Informational
    static let softPurple = Color(hex: "A78BDA")!     // Highlights
    static let softPink = Color(hex: "E8A0B8")!       // Accents
    static let softTeal = Color(hex: "6BC4B8")!       // Success states

    // Background tints
    static let greenTint = Color(hex: "7BC47F")!.opacity(0.15)
    static let amberTint = Color(hex: "E8B84A")!.opacity(0.15)
    static let orangeTint = Color(hex: "F5A962")!.opacity(0.15)
    static let grayTint = Color(hex: "9CA3AF")!.opacity(0.15)

    // Toast/Affirmation backgrounds
    static let toastBackground = Color(hex: "2D2D30")!
    static let toastBorder = Color(hex: "3D3D40")!
}

// MARK: - AgingState Soft Extensions

extension AgingState {
    /// Soft, emotionally neutral color for the aging state
    var softColor: Color {
        switch self {
        case .fresh:
            return SoftColors.softGreen
        case .aging:
            return SoftColors.warmAmber
        case .stale:
            return SoftColors.softOrange  // NOT red!
        case .never:
            return SoftColors.gentleGray
        }
    }

    /// Soft, non-judgmental label for the aging state
    var softLabel: String {
        switch self {
        case .fresh:
            return SoftLanguage.AgingLabels.fresh
        case .aging:
            return SoftLanguage.AgingLabels.aging
        case .stale:
            return SoftLanguage.AgingLabels.stale
        case .never:
            return SoftLanguage.AgingLabels.never
        }
    }

    /// Soft icon (same icons, just for completeness)
    var softIcon: String {
        switch self {
        case .fresh:
            return "checkmark.circle.fill"
        case .aging:
            return "clock.fill"
        case .stale:
            return "hourglass"  // Less alarming than exclamationmark
        case .never:
            return "circle.dashed"
        }
    }

    /// Returns either soft or standard color based on preference
    func color(useSoftColors: Bool, intensity: AgingColorIntensity = .standard) -> Color {
        if useSoftColors {
            switch intensity {
            case .subtle:
                return softColor.opacity(0.7)
            case .standard:
                return softColor
            case .highContrast:
                return softColor
            }
        } else {
            return color(intensity: intensity)
        }
    }

    /// Returns either soft or standard label based on preference
    func label(useSoftLanguage: Bool) -> String {
        useSoftLanguage ? softLabel : label
    }
}

// MARK: - Environment Key for Soft Colors Preference

private struct UseSoftColorsKey: EnvironmentKey {
    static let defaultValue: Bool = true  // Default to soft colors
}

extension EnvironmentValues {
    var useSoftColors: Bool {
        get { self[UseSoftColorsKey.self] }
        set { self[UseSoftColorsKey.self] = newValue }
    }
}
