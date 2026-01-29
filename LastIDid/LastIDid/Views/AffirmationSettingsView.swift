//
//  AffirmationSettingsView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/23/26.
//

import SwiftUI

/// Settings view for daily affirmation notifications
struct AffirmationSettingsView: View {
    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex

    @AppStorage(AppPreferenceKey.affirmationNotificationsEnabled) private var isEnabled = false
    @AppStorage(AppPreferenceKey.affirmationHour) private var preferredHour = 18
    @AppStorage(AppPreferenceKey.affirmationMinute) private var preferredMinute = 0

    @State private var selectedTime: Date = Date()

    private var themeColors: ThemeColors {
        ThemeColors(theme: theme, customHex: customHex)
    }

    var body: some View {
        List {
            // Enable/Disable Section
            Section {
                Toggle(isOn: $isEnabled) {
                    Label("Daily Affirmations", systemImage: "sparkles")
                }
                .onChange(of: isEnabled) { _, newValue in
                    if newValue {
                        AffirmationNotificationManager.shared.scheduleDaily()
                    } else {
                        AffirmationNotificationManager.shared.cancelDaily()
                    }
                }
            } footer: {
                Text("Receive a gentle, supportive message once a day to help you feel noticed and encouraged.")
            }

            // Time Picker Section
            if isEnabled {
                Section {
                    DatePicker(
                        "Notification Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .onChange(of: selectedTime) { _, newValue in
                        let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                        if let hour = components.hour, let minute = components.minute {
                            preferredHour = hour
                            preferredMinute = minute
                            AffirmationNotificationManager.shared.updateTime(hour: hour, minute: minute)
                        }
                    }
                } header: {
                    Text("When")
                } footer: {
                    Text("Choose a time that works for you. Many people prefer evening as a moment of reflection.")
                }

                // Preview Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Example Messages")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("\"You're doing better than you think.\"")
                            .font(.subheadline)
                            .italic()

                        Text("\"Small efforts add up over time.\"")
                            .font(.subheadline)
                            .italic()

                        Text("\"Awareness itself is valuable.\"")
                            .font(.subheadline)
                            .italic()
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Preview")
                }
            }

            // Info Section
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.blue)
                        Text("How it works")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    Text("Notifications are only sent if you've used the app within the last 7 days. This ensures messages feel relevant and not intrusive.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .scrollContentBackground(.hidden)
        .background(themeColors.primaryColor)
        .navigationTitle("Affirmations")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Initialize time picker with stored values
            var components = DateComponents()
            components.hour = preferredHour
            components.minute = preferredMinute
            if let date = Calendar.current.date(from: components) {
                selectedTime = date
            }
        }
    }
}

#Preview {
    NavigationStack {
        AffirmationSettingsView()
    }
    .preferredColorScheme(.dark)
}
