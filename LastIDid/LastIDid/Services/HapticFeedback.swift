//
//  HapticFeedback.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import UIKit
import SwiftUI

/// Utility for providing haptic feedback throughout the app
struct HapticFeedback {

    // MARK: - Feedback Generators

    private static let impactLight = UIImpactFeedbackGenerator(style: .light)
    private static let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private static let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private static let notificationGenerator = UINotificationFeedbackGenerator()
    private static let selectionGenerator = UISelectionFeedbackGenerator()

    // MARK: - Completion Haptics

    /// Celebratory haptic for completing an activity
    static func completion() {
        notificationGenerator.notificationOccurred(.success)
    }

    /// Light tap for quick completions (like swipe-to-complete)
    static func quickCompletion() {
        impactMedium.impactOccurred()
    }

    /// Satisfying tap for marking done with the button
    static func markDone() {
        impactHeavy.impactOccurred()

        // Add a subtle second tap for extra satisfaction
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            impactLight.impactOccurred()
        }
    }

    // MARK: - UI Interaction Haptics

    /// Selection change (picker, toggle)
    static func selection() {
        selectionGenerator.selectionChanged()
    }

    /// Light tap for button presses
    static func tap() {
        impactLight.impactOccurred()
    }

    /// Medium tap for more significant actions
    static func mediumTap() {
        impactMedium.impactOccurred()
    }

    // MARK: - Notification Haptics

    /// Success notification
    static func success() {
        notificationGenerator.notificationOccurred(.success)
    }

    /// Warning notification
    static func warning() {
        notificationGenerator.notificationOccurred(.warning)
    }

    /// Error notification (used sparingly!)
    static func error() {
        notificationGenerator.notificationOccurred(.error)
    }

    // MARK: - Special Patterns

    /// Double tap pattern for undo
    static func undo() {
        impactMedium.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            impactLight.impactOccurred()
        }
    }

    /// Streak celebration (escalating pattern)
    static func streakCelebration(streakCount: Int) {
        let intensity: UIImpactFeedbackGenerator.FeedbackStyle

        switch streakCount {
        case 0...4:
            intensity = .light
        case 5...9:
            intensity = .medium
        default:
            intensity = .heavy
        }

        let generator = UIImpactFeedbackGenerator(style: intensity)
        generator.impactOccurred()

        // Extra pulse for milestone streaks
        if streakCount % 5 == 0 && streakCount > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                notificationGenerator.notificationOccurred(.success)
            }
        }
    }

    /// Toast appearance
    static func toast() {
        impactLight.impactOccurred()
    }

    // MARK: - Prepare Generators

    /// Prepare generators before expected use (reduces latency)
    static func prepare() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
}

// MARK: - View Modifier for Haptic Feedback

extension View {
    /// Adds haptic feedback when a value changes
    func hapticFeedback<Value: Equatable>(
        on value: Value,
        type: HapticType = .selection
    ) -> some View {
        self.onChange(of: value) { _, _ in
            switch type {
            case .selection:
                HapticFeedback.selection()
            case .tap:
                HapticFeedback.tap()
            case .success:
                HapticFeedback.success()
            case .completion:
                HapticFeedback.completion()
            }
        }
    }
}

enum HapticType {
    case selection
    case tap
    case success
    case completion
}
