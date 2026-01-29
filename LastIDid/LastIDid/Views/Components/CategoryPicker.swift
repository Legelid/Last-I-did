//
//  CategoryPicker.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import SwiftUI
import SwiftData

struct CategoryPicker: View {
    @Binding var selectedCategories: Set<UUID>
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategories.contains(category.id)
                    ) {
                        if selectedCategories.contains(category.id) {
                            selectedCategories.remove(category.id)
                        } else {
                            selectedCategories.insert(category.id)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryChip: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: category.systemIcon)
                    .font(.system(size: 12))
                Text(category.name)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? category.color : Color.secondary.opacity(0.2))
            .foregroundStyle(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Category Filter Bar
struct CategoryFilterBar: View {
    @Binding var selectedCategory: Category?
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All" option
                Button {
                    selectedCategory = nil
                } label: {
                    Text("All")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedCategory == nil ? Color.accentColor : Color.secondary.opacity(0.2))
                        .foregroundStyle(selectedCategory == nil ? .white : .primary)
                        .cornerRadius(16)
                }
                .buttonStyle(.plain)

                ForEach(categories) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: category.systemIcon)
                                .font(.system(size: 12))
                            Text(category.name)
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedCategory?.id == category.id ? category.color : Color.secondary.opacity(0.2))
                        .foregroundStyle(selectedCategory?.id == category.id ? .white : .primary)
                        .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    VStack {
        CategoryPicker(selectedCategories: .constant([]))
        Divider()
        CategoryFilterBar(selectedCategory: .constant(nil))
    }
    .modelContainer(for: Category.self, inMemory: true)
    .preferredColorScheme(.dark)
}
