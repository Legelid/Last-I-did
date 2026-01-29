//
//  CategoryFormView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import SwiftUI
import SwiftData

struct CategoryFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex
    @Query(sort: \Category.sortOrder) private var existingCategories: [Category]

    let category: Category?

    @State private var name: String = ""
    @State private var selectedIcon: String = "folder.fill"
    @State private var selectedColorHex: String = "3B82F6"

    private var isEditing: Bool {
        category != nil
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private let iconOptions = [
        "folder.fill", "house.fill", "heart.fill", "car.fill",
        "laptopcomputer", "dollarsign.circle.fill", "person.fill",
        "leaf.fill", "drop.fill", "flame.fill", "bolt.fill",
        "star.fill", "moon.fill", "sun.max.fill", "cloud.fill",
        "pawprint.fill", "cart.fill", "bag.fill", "gift.fill",
        "book.fill", "pencil", "hammer.fill", "wrench.fill",
        "paintbrush.fill", "scissors", "bandage.fill", "pills.fill",
        "dumbbell.fill", "figure.run", "bicycle", "airplane",
        "tram.fill", "phone.fill", "tv.fill", "gamecontroller.fill"
    ]

    private let colorOptions = [
        "EF4444", // Red
        "F97316", // Orange
        "F59E0B", // Amber
        "EAB308", // Yellow
        "84CC16", // Lime
        "22C55E", // Green
        "10B981", // Emerald
        "14B8A6", // Teal
        "06B6D4", // Cyan
        "0EA5E9", // Sky
        "3B82F6", // Blue
        "6366F1", // Indigo
        "8B5CF6", // Violet
        "A855F7", // Purple
        "D946EF", // Fuchsia
        "EC4899", // Pink
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Category name", text: $name)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.system(size: 20))
                                    .frame(width: 36, height: 36)
                                    .background(
                                        selectedIcon == icon ?
                                            Color(hex: selectedColorHex)?.opacity(0.3) ?? Color.accentColor.opacity(0.3) :
                                            Color.clear
                                    )
                                    .foregroundStyle(
                                        selectedIcon == icon ?
                                            Color(hex: selectedColorHex) ?? .accentColor :
                                            .secondary
                                    )
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(colorOptions, id: \.self) { colorHex in
                            Button {
                                selectedColorHex = colorHex
                            } label: {
                                Circle()
                                    .fill(Color(hex: colorHex) ?? .gray)
                                    .frame(width: 32, height: 32)
                                    .overlay {
                                        if selectedColorHex == colorHex {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Preview") {
                    HStack {
                        Image(systemName: selectedIcon)
                            .foregroundStyle(Color(hex: selectedColorHex) ?? .gray)
                            .frame(width: 24)

                        Text(name.isEmpty ? "Category Name" : name)
                            .foregroundStyle(name.isEmpty ? .secondary : .primary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)
            .navigationTitle(isEditing ? "Edit Category" : "New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if let category = category {
                    name = category.name
                    selectedIcon = category.systemIcon
                    selectedColorHex = category.colorHex
                }
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if let category = category {
            // Edit existing
            category.name = trimmedName
            category.systemIcon = selectedIcon
            category.colorHex = selectedColorHex
        } else {
            // Create new
            let newCategory = Category(
                name: trimmedName,
                systemIcon: selectedIcon,
                colorHex: selectedColorHex,
                sortOrder: existingCategories.count,
                isSystemCategory: false
            )
            modelContext.insert(newCategory)
        }

        dismiss()
    }
}

#Preview {
    CategoryFormView(category: nil)
        .modelContainer(for: Category.self, inMemory: true)
        .preferredColorScheme(.dark)
}
