//
//  GentleContextSentences.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/23/26.
//

import Foundation

/// Collection of gentle context sentences for the home screen
enum GentleContextSentences {

    // MARK: - Default Sentences (11)

    static let defaultSentences: [String] = [
        "A few things haven't been touched in a while — that's totally okay.",
        "Some activities are waiting patiently.",
        "Here's what's been resting for a bit.",
        "No pressure, just gentle awareness.",
        "These have been quiet lately.",
        "A few things to maybe revisit when you're ready.",
        "Some activities could use attention, whenever works for you.",
        "Here's what's been on the back burner.",
        "A gentle nudge about these.",
        "These are here when you need them.",
        "Some things have been waiting — no rush."
    ]

    // MARK: - Gamer Theme Sentences (25)

    static let gamerSentences: [String] = [
        "A few side quests are still open. No rush.",
        "Some objectives are waiting in the quest log.",
        "These missions have been idle for a bit.",
        "A few achievements are ready when you are.",
        "Some quests are on cooldown.",
        "These have been in your inventory a while.",
        "A few checkpoints to revisit.",
        "Some levels are waiting to be replayed.",
        "These power-ups are still available.",
        "A few challenges remain. Take your time.",
        "Some bonus stages are unlocked.",
        "These have been in the backlog.",
        "A few respawn points to check.",
        "Some dailies reset soon.",
        "These are marked on your map.",
        "A few tutorials you might revisit.",
        "Some save files need attention.",
        "These have low activity.",
        "A few game modes to explore.",
        "Some multiplayer requests pending.",
        "These are in your favorites.",
        "A few achievements unlockable.",
        "Some rare items waiting.",
        "These are offline for now.",
        "A few DLC quests available."
    ]

    // MARK: - Tabletop Theme Sentences (25)

    static let tabletopSentences: [String] = [
        "Some loose threads remain in the story.",
        "A few quests await in the ledger.",
        "Some chapters have been bookmarked.",
        "The scroll contains pending tasks.",
        "A few adventures need completing.",
        "Some encounters are on hold.",
        "The journal shows unfinished business.",
        "A few plot hooks dangle.",
        "Some NPCs await your return.",
        "The campaign has open threads.",
        "A few dungeons remain unexplored.",
        "Some treasures are unclaimed.",
        "The map shows unmarked territory.",
        "A few allies need checking on.",
        "Some spells are uncast.",
        "The tavern board has notices.",
        "A few rumors to investigate.",
        "Some prophecies unfulfilled.",
        "The guild has pending requests.",
        "A few monsters still roam.",
        "Some potions await brewing.",
        "The library has unopened tomes.",
        "A few artifacts to find.",
        "Some bonds need strengthening.",
        "The story continues when ready."
    ]

    // MARK: - Public API

    /// Get a random context sentence for the given theme
    static func random(for theme: AppLanguageTheme) -> String {
        switch theme {
        case .default:
            return defaultSentences.randomElement() ?? "A few things haven't been touched in a while — that's totally okay."
        case .gamer:
            return gamerSentences.randomElement() ?? "A few side quests are still open. No rush."
        case .tabletop:
            return tabletopSentences.randomElement() ?? "Some loose threads remain in the story."
        }
    }
}
