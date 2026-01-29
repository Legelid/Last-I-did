//
//  OnboardingView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/23/26.
//

import SwiftUI

/// First-launch welcome screen with affirmation opt-in
struct OnboardingView: View {
    @AppStorage(AppPreferenceKey.hasSeenOnboarding) private var hasSeenOnboarding = false
    @AppStorage(AppPreferenceKey.affirmationNotificationsEnabled) private var affirmationsEnabled = false

    @State private var currentPage = 0

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "0D1B2A") ?? .black,
                    Color(hex: "1B2838") ?? .black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Main content
                VStack(spacing: 32) {
                    // App icon / illustration
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(SoftColors.softGreen)

                    // Welcome text
                    VStack(spacing: 12) {
                        Text("Welcome to Last I Did")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text("A gentle companion for tracking life's recurring moments")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }

                Spacer()

                // Affirmation opt-in card
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.yellow)
                            Text("Daily Affirmations")
                                .font(.headline)
                        }

                        Text("Receive a gentle, supportive message once a day to help you feel noticed and encouraged.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Toggle(isOn: $affirmationsEnabled) {
                            Text("Enable daily affirmations")
                                .font(.subheadline)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: SoftColors.softGreen))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.05))
                    )
                    .padding(.horizontal)
                }

                Spacer()
                    .frame(height: 40)

                // Get Started button
                Button {
                    completeOnboarding()
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(SoftColors.softGreen)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func completeOnboarding() {
        // Schedule affirmations if enabled
        if affirmationsEnabled {
            AffirmationNotificationManager.shared.scheduleDaily()
        }

        // Mark onboarding as complete
        withAnimation {
            hasSeenOnboarding = true
        }
    }
}

#Preview {
    OnboardingView()
        .preferredColorScheme(.dark)
}
