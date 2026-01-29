//
//  ContextualMomentBanner.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/23/26.
//

import SwiftUI

/// A dismissible banner showing contextual welcome messages
struct ContextualMomentBanner: View {
    let message: String
    let onDismiss: () -> Void

    @State private var opacity: Double = 1.0

    var body: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundStyle(.yellow)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.primary)

            Spacer()

            Button {
                withAnimation {
                    onDismiss()
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
        .opacity(opacity)
        .onAppear {
            // Auto-dismiss after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
    }
}

// MARK: - Contextual Moment Manager

/// Manages when and what contextual moments to show
class ContextualMomentManager {
    static let shared = ContextualMomentManager()

    private let userDefaults = UserDefaults.standard

    private init() {}

    // MARK: - Message Pools

    private let welcomeBackMessages = [
        "Welcome back.",
        "Good to see you.",
        "Hey there.",
        "Here you are."
    ]

    private let welcomeBackWithNameMessages = [
        "Welcome back, %@.",
        "Good to see you, %@.",
        "Hey %@.",
        "Here you are, %@."
    ]

    private let activeUserMessages = [
        "You've been keeping up nicely.",
        "Things are moving along.",
        "You're staying on track.",
        "Nice to have you back."
    ]

    private let quietUserMessages = [
        "Take your time.",
        "No rush here.",
        "It's good to check in.",
        "Just being here counts."
    ]

    // MARK: - Public API

    /// Check if we should show a contextual moment (max once per 24 hours, 30% chance)
    func shouldShowMoment() -> Bool {
        let lastShown = userDefaults.object(forKey: AppPreferenceKey.lastContextualMoment) as? Date
        let now = Date()

        // Check 24-hour cooldown
        if let lastShown = lastShown {
            let hoursSince = Calendar.current.dateComponents([.hour], from: lastShown, to: now).hour ?? 0
            if hoursSince < 24 {
                return false
            }
        }

        // 30% chance of showing
        return Double.random(in: 0...1) < 0.3
    }

    /// Get a contextual message based on user activity
    func getMessage(userName: String?, hasRecentActivity: Bool) -> String {
        // Record that we showed a moment
        userDefaults.set(Date(), forKey: AppPreferenceKey.lastContextualMoment)

        // 50% chance to personalize with name
        let shouldPersonalize = userName != nil && !userName!.isEmpty && Double.random(in: 0...1) < 0.5

        if hasRecentActivity {
            if shouldPersonalize {
                let template = welcomeBackWithNameMessages.randomElement() ?? "Welcome back, %@."
                return String(format: template, userName!)
            }
            return activeUserMessages.randomElement() ?? welcomeBackMessages.randomElement()!
        } else {
            if shouldPersonalize {
                let template = welcomeBackWithNameMessages.randomElement() ?? "Welcome back, %@."
                return String(format: template, userName!)
            }
            return quietUserMessages.randomElement() ?? welcomeBackMessages.randomElement()!
        }
    }

    /// Check if user has recent activity (within last 7 days)
    func hasRecentActivity(activities: [Activity]) -> Bool {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()

        for activity in activities {
            if let lastCompleted = activity.lastCompletedDate, lastCompleted >= oneWeekAgo {
                return true
            }
        }
        return false
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack {
            ContextualMomentBanner(message: "Welcome back, Alex.") {
                print("Dismissed")
            }

            Spacer()
        }
        .padding(.top, 20)
    }
    .preferredColorScheme(.dark)
}
