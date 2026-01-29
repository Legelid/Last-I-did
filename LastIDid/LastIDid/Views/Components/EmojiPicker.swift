//
//  EmojiPicker.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import SwiftUI

/// A simple emoji picker for activity icons
struct EmojiPicker: View {
    @Binding var selectedEmoji: String?
    @Environment(\.dismiss) private var dismiss

    // Common emojis organized by category
    private let emojiCategories: [(name: String, emojis: [String])] = [
        ("Favorites", ["✨", "🎯", "💪", "🌟", "❤️", "🔥", "✅", "🏆"]),
        ("Activities", ["🏃", "🧘", "🚴", "🏋️", "⚽", "🎾", "🏊", "🚶"]),
        ("Home", ["🏠", "🧹", "🧺", "🌱", "🪴", "🛠️", "🔧", "💡"]),
        ("Health", ["💊", "🩺", "🧴", "🦷", "😴", "🍎", "💧", "🫀"]),
        ("Work", ["💼", "💻", "📧", "📞", "📝", "📊", "🎨", "📸"]),
        ("Self Care", ["🧘‍♀️", "🛁", "💅", "🧖", "💆", "🌸", "🕯️", "📚"]),
        ("Finance", ["💰", "💳", "🏦", "📈", "💵", "🧾", "📋", "🔐"]),
        ("Travel", ["✈️", "🚗", "🚌", "🚂", "⛽", "🅿️", "🛞", "🧳"]),
        ("Nature", ["🌿", "🌻", "🌲", "🌊", "☀️", "🌙", "⭐", "🌈"]),
        ("Food", ["🍳", "🥗", "🍕", "☕", "🧁", "🥤", "🍎", "🥑"]),
        ("Pets", ["🐕", "🐈", "🐦", "🐠", "🐰", "🐹", "🦜", "🐢"]),
        ("Social", ["👋", "🤝", "📱", "💬", "❤️", "🎉", "🎂", "🎁"])
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Clear option
                    if selectedEmoji != nil {
                        Button {
                            selectedEmoji = nil
                            HapticFeedback.selection()
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                                Text("Remove emoji")
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }

                    // Emoji categories
                    ForEach(emojiCategories, id: \.name) { category in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(category.name)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                                ForEach(category.emojis, id: \.self) { emoji in
                                    Button {
                                        selectedEmoji = emoji
                                        HapticFeedback.selection()
                                        dismiss()
                                    } label: {
                                        Text(emoji)
                                            .font(.system(size: 28))
                                            .frame(width: 44, height: 44)
                                            .background(
                                                selectedEmoji == emoji ?
                                                Color.accentColor.opacity(0.3) :
                                                Color.clear
                                            )
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(white: 0.1))
            .navigationTitle("Choose Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Emoji Selector Button (for forms)

struct EmojiSelectorButton: View {
    @Binding var selectedEmoji: String?
    @State private var showingPicker = false

    var body: some View {
        Button {
            showingPicker = true
        } label: {
            HStack {
                if let emoji = selectedEmoji, !emoji.isEmpty {
                    Text(emoji)
                        .font(.system(size: 28))
                } else {
                    Image(systemName: "face.smiling")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(selectedEmoji == nil ? "Add emoji" : "Change")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingPicker) {
            EmojiPicker(selectedEmoji: $selectedEmoji)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EmojiPicker(selectedEmoji: .constant("🏃"))
    }
    .preferredColorScheme(.dark)
}
