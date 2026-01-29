//
//  TemplateListView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import SwiftUI
import SwiftData

struct TemplateListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex
    @Query private var existingActivities: [Activity]
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    @State private var searchText = ""
    @State private var addedTemplates: Set<String> = []

    private var filteredTemplates: [String: [ActivityTemplate]] {
        if searchText.isEmpty {
            return ActivityTemplate.allTemplates
        }

        var filtered: [String: [ActivityTemplate]] = [:]
        for (category, templates) in ActivityTemplate.allTemplates {
            let matching = templates.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
            if !matching.isEmpty {
                filtered[category] = matching
            }
        }
        return filtered
    }

    var body: some View {
        NavigationStack {
            List {
                if filteredTemplates.isEmpty {
                    ContentUnavailableView(
                        "No Templates Found",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("Try a different search term")
                    )
                } else {
                    ForEach(ActivityTemplate.allCategoriesOrdered, id: \.self) { categoryName in
                        if let templates = filteredTemplates[categoryName] {
                            Section(categoryName) {
                                ForEach(templates) { template in
                                    TemplateRowView(
                                        template: template,
                                        isAdded: isTemplateAdded(template),
                                        onAdd: { addTemplate(template) }
                                    )
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)
            .searchable(text: $searchText, prompt: "Search templates")
            .navigationTitle("Activity Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func isTemplateAdded(_ template: ActivityTemplate) -> Bool {
        addedTemplates.contains(template.id) ||
        existingActivities.contains { $0.templateSourceID == template.id }
    }

    private func addTemplate(_ template: ActivityTemplate) {
        let activity = Activity(name: template.name)
        activity.templateSourceID = template.id

        // Set up reminder if template suggests one
        if let days = template.suggestedReminderDays {
            activity.reminderEnabled = true
            activity.reminderType = .recurring
            activity.reminderIntervalDays = days
        }

        // Try to match category
        if let matchingCategory = categories.first(where: { $0.name == template.category }) {
            activity.categories = [matchingCategory]
        }

        modelContext.insert(activity)
        addedTemplates.insert(template.id)
    }
}

struct TemplateRowView: View {
    let template: ActivityTemplate
    let isAdded: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack {
            Image(systemName: template.icon)
                .font(.system(size: 20))
                .foregroundStyle(.secondary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(template.name)
                    .font(.body)

                if let days = template.suggestedReminderDays {
                    Text("Suggested: every \(days) days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if isAdded {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Button {
                    onAdd()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.accentColor)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TemplateListView()
        .modelContainer(for: [Activity.self, Category.self], inMemory: true)
        .preferredColorScheme(.dark)
}
