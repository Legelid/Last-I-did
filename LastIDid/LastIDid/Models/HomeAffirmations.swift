//
//  HomeAffirmations.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/23/26.
//

import Foundation

/// Collection of affirmations for the home screen
enum HomeAffirmations {

    // MARK: - Default Affirmations (25)

    static let defaultAffirmations: [String] = [
        "Proud of you.",
        "Hope today feels kind.",
        "You're doing okay.",
        "One moment at a time.",
        "You showed up today.",
        "That counts for something.",
        "Gentle progress is still progress.",
        "You're allowed to rest.",
        "Small steps matter.",
        "Be kind to yourself.",
        "You're doing your best.",
        "Today is enough.",
        "You matter.",
        "Take it easy.",
        "You're on the right track.",
        "Breathe. You've got this.",
        "Every little bit helps.",
        "You're making it work.",
        "It's okay to go slow.",
        "You're doing great.",
        "Just being here is enough.",
        "Give yourself credit.",
        "You're handling it.",
        "Trust yourself.",
        "You're exactly where you need to be."
    ]

    // MARK: - Default Emojis (9)

    static let defaultEmojis: [String] = [
        "💚", "🌟", "✨", "🌿", "☀️", "🌙", "💙", "🕊️", "💫"
    ]

    // MARK: - Gamer Theme Affirmations (25)

    static let gamerAffirmations: [String] = [
        "Solid progress.",
        "Still in the game.",
        "Achievement unlocked: showing up.",
        "Loading... life handled.",
        "GG on today.",
        "You're doing fine, player one.",
        "Save point reached.",
        "Main quest: being you. Going well.",
        "No rush. Play at your pace.",
        "You're leveling up quietly.",
        "Side quest complete.",
        "Inventory: full of good stuff.",
        "HP restored.",
        "New day, new spawn.",
        "Skills loading...",
        "Tutorial complete. You've got this.",
        "Auto-save: progress kept.",
        "Buff active: self-care.",
        "Quest log updated.",
        "Boss battle postponed. That's okay.",
        "Party status: holding steady.",
        "XP gained: experience.",
        "Checkpoint reached.",
        "Loading next chapter...",
        "Player stats looking good."
    ]

    // MARK: - Gamer Theme Emojis (9)

    static let gamerEmojis: [String] = [
        "🎮", "🕹️", "👾", "🎯", "🏆", "⚡", "🌐", "💎", "🔋"
    ]

    // MARK: - Tabletop Theme Affirmations (25)

    static let tabletopAffirmations: [String] = [
        "The journey continues.",
        "Your party is in good spirits.",
        "Roll for self-compassion. Natural 20.",
        "The path unfolds as it should.",
        "Your character sheet looks fine.",
        "No encounter today. Rest well.",
        "The tavern is warm. Stay awhile.",
        "Your story is still being written.",
        "The dice favor the patient.",
        "A moment of peace in the campaign.",
        "Your inventory is enough.",
        "The quest continues tomorrow.",
        "Fellow travelers believe in you.",
        "Your wisdom stat is high today.",
        "The map shows you're on course.",
        "A long rest does wonders.",
        "Your initiative is perfect.",
        "The narrative unfolds gently.",
        "Advantage on kindness rolls.",
        "The DM smiles upon you.",
        "Your hit points are restored.",
        "A new chapter begins.",
        "The guild has your back.",
        "Charisma check: passed.",
        "Your alignment: doing your best."
    ]

    // MARK: - Tabletop Theme Emojis (9)

    static let tabletopEmojis: [String] = [
        "🧙", "⚔️", "🛡️", "📜", "🎲", "🗝️", "🏰", "🌙", "✨"
    ]

    // MARK: - Public API

    /// Get a random affirmation for the given theme
    static func random(for theme: AppLanguageTheme) -> String {
        switch theme {
        case .default:
            return defaultAffirmations.randomElement() ?? "You're doing okay."
        case .gamer:
            return gamerAffirmations.randomElement() ?? "Solid progress."
        case .tabletop:
            return tabletopAffirmations.randomElement() ?? "The journey continues."
        }
    }

    /// Get a random emoji for the given theme
    static func randomEmoji(for theme: AppLanguageTheme) -> String {
        switch theme {
        case .default:
            return defaultEmojis.randomElement() ?? "💚"
        case .gamer:
            return gamerEmojis.randomElement() ?? "🎮"
        case .tabletop:
            return tabletopEmojis.randomElement() ?? "🎲"
        }
    }
}
