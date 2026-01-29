//
//  AppLanguageTheme.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/23/26.
//

import SwiftUI

/// Language theme options for the app's tone and personality
enum AppLanguageTheme: String, CaseIterable, Identifiable {
    case `default` = "default"
    case gamer = "gamer"
    case tabletop = "tabletop"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .default: return "Default"
        case .gamer: return "Gamer"
        case .tabletop: return "Tabletop"
        }
    }

    var description: String {
        switch self {
        case .default:
            return "Calm, supportive language for gentle awareness."
        case .gamer:
            return "Gaming-inspired language with quests, achievements, and progress."
        case .tabletop:
            return "Tabletop RPG-inspired language with adventures and journeys."
        }
    }

    var systemIcon: String {
        switch self {
        case .default: return "heart.fill"
        case .gamer: return "gamecontroller.fill"
        case .tabletop: return "die.face.6.fill"
        }
    }

    /// Theme-aware font for affirmations
    var affirmationFont: Font {
        switch self {
        case .default:
            return .subheadline.italic()
        case .gamer:
            // Custom font with system fallback
            return .custom("PixelOperator", size: 14)
        case .tabletop:
            // Custom font with system fallback
            return .custom("IMFellEnglish-Regular", size: 15).italic()
        }
    }

    /// Create from raw string value with fallback
    static func from(_ rawValue: String) -> AppLanguageTheme {
        AppLanguageTheme(rawValue: rawValue) ?? .default
    }
}
