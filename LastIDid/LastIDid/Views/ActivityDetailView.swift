//
//  ActivityDetailView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import SwiftUI
import SwiftData

struct ActivityDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex
    @Bindable var activity: Activity

    @AppStorage(AppPreferenceKey.useSoftColors) private var useSoftColors = true
    @AppStorage(AppPreferenceKey.useSoftLanguage) private var useSoftLanguage = true
    @AppStorage(AppPreferenceKey.showAffirmations) private var showAffirmations = true
    @AppStorage(AppPreferenceKey.showReflectionPrompt) private var showReflectionPrompt = false

    @State private var showingCompletionForm = false
    @State private var showingEditForm = false
    @State private var completionToDelete: CompletionRecord?
    @State private var showingReflectionSheet = false

    private var sortedCompletions: [CompletionRecord] {
        activity.completions.sorted { $0.completedDate > $1.completedDate }
    }

    var body: some View {
        List {
            // Activity Info Section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        AgingIndicator(state: activity.agingState, size: .large, useSoftColors: useSoftColors)
                        Spacer()
                        Text(activity.agingState.label(useSoftLanguage: useSoftLanguage))
                            .font(.subheadline)
                            .foregroundStyle(activity.agingState.color(useSoftColors: useSoftColors))
                    }

                    if let lastCompleted = activity.lastCompletedDate {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Last completed")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(useSoftLanguage ? SoftLanguage.timeSince(activity.daysSinceLastCompleted) : lastCompleted.formatted(.relative(presentation: .named)))
                                .font(.headline)
                            Text(lastCompleted.formatted(date: .long, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text(useSoftLanguage ? SoftLanguage.AgingLabels.never : "Never completed")
                            .foregroundStyle(.secondary)
                    }

                    if let notes = activity.notes, !notes.isEmpty {
                        Divider()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(notes)
                                .font(.body)
                        }
                    }

                    // Categories
                    if !activity.categories.isEmpty {
                        Divider()
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Categories")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            FlowLayout(spacing: 8) {
                                ForEach(activity.categories) { category in
                                    CategoryBadge(category: category)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }

            // Quick Actions Section
            Section("Actions") {
                Button {
                    completeActivity()
                } label: {
                    Label(useSoftLanguage ? SoftLanguage.Actions.markDone : "Mark as Done Now", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(useSoftColors ? SoftColors.softGreen : .green)
                }

                Button {
                    showingCompletionForm = true
                } label: {
                    Label("Log Past Completion", systemImage: "clock.arrow.circlepath")
                }

                Button {
                    showingEditForm = true
                } label: {
                    Label("Edit Activity", systemImage: "pencil")
                }
            }

            // Completion History Section
            Section {
                if sortedCompletions.isEmpty {
                    Text(useSoftLanguage ? SoftLanguage.EmptyStates.noHistorySubtitle : "No completion history yet")
                        .foregroundStyle(.secondary)
                        .italic()
                } else {
                    ForEach(sortedCompletions) { record in
                        CompletionRecordRow(record: record)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    completionToDelete = record
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            } header: {
                HStack {
                    Text("Completion History")
                    Spacer()
                    Text("\(activity.completions.count) total")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Reminder Info Section
            if activity.reminderEnabled {
                Section("Reminder") {
                    if let reminderType = activity.reminderType {
                        switch reminderType {
                        case .oneTime:
                            if let date = activity.reminderDate {
                                HStack {
                                    Label("One-time", systemImage: "bell.fill")
                                    Spacer()
                                    Text(date.formatted(date: .abbreviated, time: .shortened))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        case .recurring:
                            if let days = activity.reminderIntervalDays {
                                HStack {
                                    Label("Recurring", systemImage: "repeat")
                                    Spacer()
                                    Text("Every \(days) days")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)
        .navigationTitle(activity.name)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingCompletionForm) {
            CompletionFormView(activity: activity)
        }
        .sheet(isPresented: $showingEditForm) {
            ActivityFormView(mode: .edit(activity))
        }
        .alert("Delete Completion?", isPresented: .init(
            get: { completionToDelete != nil },
            set: { if !$0 { completionToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                completionToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let record = completionToDelete {
                    withAnimation {
                        modelContext.delete(record)
                    }
                }
                completionToDelete = nil
            }
        } message: {
            Text("This will remove this completion from the history.")
        }
        .sheet(isPresented: $showingReflectionSheet) {
            ReflectionPromptSheet(activity: activity)
        }
        .withAffirmationToast()
    }

    // MARK: - Complete Activity with Affirmation

    private func completeActivity() {
        let wasFirstTime = activity.completions.isEmpty
        let daysSince = activity.daysSinceLastCompleted
        let streakBefore = StreakCalculator.onTimeStreak(for: activity)

        withAnimation {
            activity.markCompleted()
            NotificationManager.shared.rescheduleRecurringReminder(for: activity)
        }

        // Haptic feedback
        HapticFeedback.markDone()

        // Show affirmation toast if enabled
        if showAffirmations {
            let newStreak = StreakCalculator.onTimeStreak(for: activity)
            ToastManager.shared.showCompletion(
                isFirstTime: wasFirstTime,
                streakCount: newStreak,
                daysSinceLastCompletion: daysSince
            )
        }

        // Show reflection prompt if enabled
        if showReflectionPrompt {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showingReflectionSheet = true
            }
        }
    }
}

// MARK: - Completion Record Row
struct CompletionRecordRow: View {
    let record: CompletionRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(record.completedDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)

                if record.wasBackdated {
                    Text("(backdated)")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(4)
                }

                Spacer()

                Text(record.completedDate, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let notes = record.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Category Badge
struct CategoryBadge: View {
    let category: Category

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.systemIcon)
                .font(.caption)
            Text(category.name)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(category.color.opacity(0.2))
        .foregroundStyle(category.color)
        .cornerRadius(8)
    }
}

// MARK: - Flow Layout for Categories
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var positions: [CGPoint] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                self.size.width = max(self.size.width, x)
            }
            self.size.height = y + rowHeight
        }
    }
}

#Preview {
    NavigationStack {
        ActivityDetailView(activity: Activity(name: "Change HVAC Filter"))
    }
    .modelContainer(for: [Activity.self, CompletionRecord.self, Category.self], inMemory: true)
    .preferredColorScheme(.dark)
}
