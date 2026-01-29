//
//  LanguageThemeSettingsView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/23/26.
//

import SwiftUI

/// Settings view for selecting the app's language theme
struct LanguageThemeSettingsView: View {
    @AppStorage(AppPreferenceKey.selectedLanguageTheme) private var selectedThemeRaw = "default"
    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex

    private var selectedTheme: AppLanguageTheme {
        AppLanguageTheme.from(selectedThemeRaw)
    }

    var body: some View {
        List {
            Section {
                ForEach(AppLanguageTheme.allCases) { languageTheme in
                    Button {
                        selectedThemeRaw = languageTheme.rawValue
                    } label: {
                        HStack {
                            Image(systemName: languageTheme.systemIcon)
                                .foregroundStyle(Color.accentColor)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(languageTheme.displayName)
                                    .foregroundStyle(.primary)

                                Text(languageTheme.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if selectedTheme == languageTheme {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                }
            } header: {
                Text("Theme")
            } footer: {
                Text("Choose a personality for affirmations and context messages. This changes the tone and style of supportive text throughout the app.")
            }

            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Preview")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HomeAffirmationView(
                        affirmation: HomeAffirmations.random(for: selectedTheme),
                        emoji: HomeAffirmations.randomEmoji(for: selectedTheme),
                        theme: selectedTheme
                    )
                    .padding(.horizontal, -16)

                    Text(GentleContextSentences.random(for: selectedTheme))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            } header: {
                Text("Sample Messages")
            }
        }
        .scrollContentBackground(.hidden)
        .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)
        .navigationTitle("Language Theme")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LanguageThemeSettingsView()
    }
    .preferredColorScheme(.dark)
}
