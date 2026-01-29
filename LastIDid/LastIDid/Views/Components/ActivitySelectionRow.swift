//
//  ActivitySelectionRow.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import SwiftUI

struct ActivitySelectionRow: View {
    let activity: TemplateActivity
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                if let emoji = activity.suggestedEmoji {
                    Text(emoji)
                        .font(.title3)
                        .frame(width: 32)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.name)
                        .font(.body)
                        .foregroundStyle(.primary)

                    if let frequency = activity.suggestedFrequency {
                        Text(frequency)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? SoftColors.softGreen : .secondary)
                    .font(.title3)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    List {
        ActivitySelectionRow(
            activity: TemplateActivity(
                name: "Do dishes",
                suggestedEmoji: "🧼",
                suggestedFrequency: "Usually done daily",
                categoryName: "Home"
            ),
            isSelected: false,
            onToggle: {}
        )

        ActivitySelectionRow(
            activity: TemplateActivity(
                name: "Clean oven",
                suggestedEmoji: "🔥",
                suggestedFrequency: "Often done every few months",
                categoryName: "Home"
            ),
            isSelected: true,
            onToggle: {}
        )
    }
    .preferredColorScheme(.dark)
}
