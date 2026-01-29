//
//  CompletionFormView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import SwiftUI
import SwiftData

struct CompletionFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex
    @Bindable var activity: Activity

    @State private var completedDate = Date()
    @State private var notes = ""
    @State private var showingQuickPicks = true

    private let quickPicks: [(String, Date)] = {
        let calendar = Calendar.current
        let now = Date()
        return [
            ("Now", now),
            ("Yesterday", calendar.date(byAdding: .day, value: -1, to: now)!),
            ("2 days ago", calendar.date(byAdding: .day, value: -2, to: now)!),
            ("Last week", calendar.date(byAdding: .day, value: -7, to: now)!),
        ]
    }()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(activity.name)
                        .font(.headline)
                } header: {
                    Text("Activity")
                }

                Section {
                    // Quick pick buttons
                    if showingQuickPicks {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(quickPicks, id: \.0) { label, date in
                                    Button {
                                        withAnimation {
                                            completedDate = date
                                        }
                                    } label: {
                                        Text(label)
                                            .font(.subheadline)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                Calendar.current.isDate(completedDate, inSameDayAs: date) ?
                                                    Color.accentColor : Color.secondary.opacity(0.2)
                                            )
                                            .foregroundStyle(
                                                Calendar.current.isDate(completedDate, inSameDayAs: date) ?
                                                    .white : .primary
                                            )
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }

                    DatePicker(
                        "Completion Date",
                        selection: $completedDate,
                        in: ...Date(),
                        displayedComponents: [.date, .hourAndMinute]
                    )

                    if !Calendar.current.isDateInToday(completedDate) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundStyle(.orange)
                            Text("This will be marked as backdated")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                } header: {
                    Text("When did you complete this?")
                }

                Section {
                    TextField("Add a note (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes")
                } footer: {
                    Text("Notes help you remember details about this completion.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)
            .navigationTitle("Log Completion")
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
                }
            }
        }
    }

    private func save() {
        let isBackdated = !Calendar.current.isDateInToday(completedDate)
        activity.markCompleted(
            notes: notes.isEmpty ? nil : notes,
            backdatedTo: isBackdated ? completedDate : nil
        )
        NotificationManager.shared.rescheduleRecurringReminder(for: activity)
        dismiss()
    }
}

// MARK: - Quick Completion Alert View
struct QuickCompletionAlert: View {
    @Binding var isPresented: Bool
    @Binding var notes: String
    let onSave: (String?) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Add a Note")
                .font(.headline)

            TextField("Optional note", text: $notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)

            HStack {
                Button("Skip") {
                    onSave(nil)
                    isPresented = false
                }
                .buttonStyle(.bordered)

                Button("Save") {
                    onSave(notes.isEmpty ? nil : notes)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 20)
    }
}

#Preview {
    CompletionFormView(activity: Activity(name: "Change air filter"))
        .preferredColorScheme(.dark)
}
