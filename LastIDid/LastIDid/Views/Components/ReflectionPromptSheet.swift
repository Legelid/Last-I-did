//
//  ReflectionPromptSheet.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import SwiftUI

/// A gentle sheet that prompts for optional reflection notes after completion
struct ReflectionPromptSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let activity: Activity

    @State private var reflectionText = ""
    @FocusState private var isFocused: Bool

    private var mostRecentCompletion: CompletionRecord? {
        activity.completions.max(by: { $0.completedDate < $1.completedDate })
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(SoftColors.softGreen.opacity(0.2))
                            .frame(width: 60, height: 60)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(SoftColors.softGreen)
                    }

                    Text(SoftLanguage.Celebration.completed)
                        .font(.headline)

                    Text("Would you like to add a quick note?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)

                // Text input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reflection (optional)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextEditor(text: $reflectionText)
                        .frame(height: 100)
                        .padding(12)
                        .background(Color(white: 0.15))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .focused($isFocused)
                }
                .padding(.horizontal)

                // Prompt suggestions
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick prompts")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            PromptChip("How did it go?") { reflectionText = "It went " }
                            PromptChip("Feeling") { reflectionText = "Feeling " }
                            PromptChip("Next time") { reflectionText = "Next time I'll " }
                            PromptChip("Noticed") { reflectionText = "I noticed " }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        saveReflection()
                    } label: {
                        Text(reflectionText.isEmpty ? SoftLanguage.Actions.skip : "Save Note")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(reflectionText.isEmpty ? Color.secondary.opacity(0.3) : Color.accentColor)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("Maybe later")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(Color(white: 0.1))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isFocused = true
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func saveReflection() {
        if !reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Update the most recent completion with the note
            if let completion = mostRecentCompletion {
                completion.notes = reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        HapticFeedback.success()
        dismiss()
    }
}

// MARK: - Prompt Chip

struct PromptChip: View {
    let text: String
    let action: () -> Void

    init(_ text: String, action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ReflectionPromptSheet(activity: Activity(name: "Test Activity"))
        .preferredColorScheme(.dark)
}
