//
//  GentleContextView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/23/26.
//

import SwiftUI

/// Displays a gentle context sentence above surfaced activities
struct GentleContextView: View {
    let sentence: String

    var body: some View {
        Text(sentence)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
    }
}

#Preview {
    List {
        Section {
            GentleContextView(sentence: "A few things haven't been touched in a while — that's totally okay.")
        }
    }
    .listStyle(.plain)
    .preferredColorScheme(.dark)
}
