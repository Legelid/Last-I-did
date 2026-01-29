//
//  HomeAffirmationView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/23/26.
//

import SwiftUI

/// Displays a supportive affirmation at the top of the home screen
struct HomeAffirmationView: View {
    let affirmation: String
    let emoji: String?
    let theme: AppLanguageTheme

    var body: some View {
        HStack(spacing: 8) {
            if let emoji = emoji {
                Text(emoji)
                    .font(.body)
            }

            Text(affirmation)
                .font(theme.affirmationFont)
                .foregroundStyle(.primary.opacity(0.9))

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.08))
        )
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 16) {
        HomeAffirmationView(
            affirmation: "Proud of you.",
            emoji: "💚",
            theme: .default
        )

        HomeAffirmationView(
            affirmation: "Solid progress.",
            emoji: "🎮",
            theme: .gamer
        )

        HomeAffirmationView(
            affirmation: "The journey continues.",
            emoji: nil,
            theme: .tabletop
        )
    }
    .padding(.vertical)
    .background(Color.black)
    .preferredColorScheme(.dark)
}
