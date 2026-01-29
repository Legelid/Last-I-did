//
//  ActivityListView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import SwiftUI
import SwiftData

struct ActivityListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex
    @Query(filter: #Predicate<Activity> { !$0.isArchived })
    private var activities: [Activity]
    @AppStorage(AppPreferenceKey.activitySortOrder) private var sortOrderRaw = "oldestFirst"
    @AppStorage(AppPreferenceKey.calendarStripEnabled) private var showCalendarStrip = true
    @AppStorage(AppPreferenceKey.showAffirmations) private var showAffirmations = true
    @AppStorage(AppPreferenceKey.showReflectionPrompt) private var showReflectionPrompt = false

    // Home affirmation settings
    @AppStorage(AppPreferenceKey.selectedLanguageTheme) private var languageThemeRaw = "default"
    @AppStorage(AppPreferenceKey.showHomeAffirmations) private var showHomeAffirmations = true
    @AppStorage(AppPreferenceKey.showAffirmationEmojis) private var showAffirmationEmojis = false

    @State private var showingAddSheet = false
    @State private var activityToEdit: Activity?
    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @State private var selectedDate: Date? = nil  // nil = "All"
    @State private var showingTemplates = false
    @State private var showingSearch = false
    @State private var activityForReflection: Activity?

    // Home screen affirmation state
    @State private var currentAffirmation: String = ""
    @State private var currentEmoji: String? = nil
    @State private var currentContextSentence: String = ""
    @State private var surfacedActivities: [Activity] = []
    @AppStorage("userName") private var userName: String = ""

    private var languageTheme: AppLanguageTheme {
        AppLanguageTheme.from(languageThemeRaw)
    }

    private var sortOrder: ActivitySortOrder {
        ActivitySortOrder.from(sortOrderRaw)
    }

    // Sort activities based on user preference
    private var sortedActivities: [Activity] {
        let filtered: [Activity]
        if searchText.isEmpty {
            filtered = activities
        } else {
            filtered = activities.filter { activity in
                activity.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Filter by category if selected
        let categoryFiltered: [Activity]
        if let category = selectedCategory {
            categoryFiltered = filtered.filter { $0.categories.contains(where: { $0.id == category.id }) }
        } else {
            categoryFiltered = filtered
        }

        // Filter by date if selected
        let dateFiltered: [Activity]
        if let date = selectedDate {
            dateFiltered = categoryFiltered.filter { activity in
                // Check if completed on this date
                let hasCompletion = activity.completions.contains { completion in
                    Calendar.current.isDate(completion.completedDate, inSameDayAs: date)
                }
                return hasCompletion
            }
        } else {
            dateFiltered = categoryFiltered
        }

        // Sort based on preference
        switch sortOrder {
        case .oldestFirst:
            return dateFiltered.sorted { a, b in
                let dateA = a.lastCompletedDate ?? .distantPast
                let dateB = b.lastCompletedDate ?? .distantPast
                return dateA < dateB
            }
        case .newestFirst:
            return dateFiltered.sorted { a, b in
                let dateA = a.lastCompletedDate ?? .distantPast
                let dateB = b.lastCompletedDate ?? .distantPast
                return dateA > dateB
            }
        case .alphabetical:
            return dateFiltered.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .byCategory:
            return dateFiltered.sorted { a, b in
                let categoryA = a.categories.first?.name ?? ""
                let categoryB = b.categories.first?.name ?? ""
                if categoryA != categoryB {
                    return categoryA.localizedCaseInsensitiveCompare(categoryB) == .orderedAscending
                }
                return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
            }
        }
    }

    /// Get activities that aren't surfaced, maintaining the user's sort order
    private var remainingActivities: [Activity] {
        let surfacedIDs = Set(surfacedActivities.map { $0.id })
        return sortedActivities.filter { !surfacedIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    // Nature photo header
                    NatureHeaderView()

                    // Home affirmation (replaces contextual banner)
                    if showHomeAffirmations && !currentAffirmation.isEmpty {
                        HomeAffirmationView(
                            affirmation: currentAffirmation,
                            emoji: showAffirmationEmojis ? currentEmoji : nil,
                            theme: languageTheme
                        )
                        .padding(.top, 8)
                    }

                    List {
                        if sortedActivities.isEmpty {
                            SoftEmptyState.noActivities {
                                showingAddSheet = true
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        } else {
                            // Surfaced activities section (if any exist)
                            if !surfacedActivities.isEmpty {
                                Section {
                                    ForEach(surfacedActivities) { activity in
                                        activityRow(for: activity)
                                    }
                                } header: {
                                    GentleContextView(sentence: currentContextSentence)
                                        .textCase(nil)
                                        .padding(.bottom, 4)
                                }
                            }

                            // Remaining activities section
                            Section {
                                ForEach(remainingActivities) { activity in
                                    activityRow(for: activity)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)
                    .contentMargins(.horizontal, 16, for: .scrollContent)
                }

                // Animated search bar overlay
                if showingSearch {
                    SearchOverlayView(searchText: $searchText, isPresented: $showingSearch)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Activity.self) { activity in
                ActivityDetailView(activity: activity)
            }
            .sheet(isPresented: $showingAddSheet) {
                ActivityFormView(mode: .add)
            }
            .sheet(item: $activityToEdit) { activity in
                ActivityFormView(mode: .edit(activity))
            }
            .sheet(isPresented: $showingTemplates) {
                TemplateListView()
            }
            .sheet(item: $activityForReflection) { activity in
                ReflectionPromptSheet(activity: activity)
            }
            .withAffirmationToast()
            .onAppear {
                refreshHomeScreen()
                // Record app open for affirmation notification logic
                AffirmationNotificationManager.shared.recordAppOpen()
            }
        }
    }

    // MARK: - Activity Row Builder

    @ViewBuilder
    private func activityRow(for activity: Activity) -> some View {
        NavigationLink(value: activity) {
            ActivityRowView(activity: activity)
        }
        .listRowBackground(
            RoundedRectangle(cornerRadius: 20)
                .fill(ThemeColors(theme: theme, customHex: customHex).secondaryColor)
                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
        )
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24))
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                withAnimation {
                    NotificationManager.shared.cancelReminder(for: activity)
                    modelContext.delete(activity)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }

            Button {
                activityToEdit = activity
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.orange)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                completeActivity(activity)
            } label: {
                Label("Done", systemImage: "checkmark.circle.fill")
            }
            .tint(SoftColors.softGreen)
        }
    }

    // MARK: - Refresh Home Screen

    private func refreshHomeScreen() {
        // Generate affirmation and emoji for this session
        currentAffirmation = HomeAffirmations.random(for: languageTheme)
        currentEmoji = HomeAffirmations.randomEmoji(for: languageTheme)

        // Generate context sentence
        currentContextSentence = GentleContextSentences.random(for: languageTheme)

        // Calculate surfaced activities (stable for this session)
        surfacedActivities = ActivitySurfacing.getSurfacedActivities(Array(activities))
    }

    // MARK: - Complete Activity with Affirmation

    private func completeActivity(_ activity: Activity) {
        let wasFirstTime = activity.completions.isEmpty
        let daysSince = activity.daysSinceLastCompleted
        let streakBefore = StreakCalculator.onTimeStreak(for: activity)

        withAnimation {
            activity.markCompleted()
            NotificationManager.shared.rescheduleRecurringReminder(for: activity)
        }

        // Haptic feedback
        HapticFeedback.completion()

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
                activityForReflection = activity
            }
        }
    }
}

// MARK: - Search Overlay View

struct SearchOverlayView: View {
    @Binding var searchText: String
    @Binding var isPresented: Bool
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search activities...", text: $searchText)
                    .textFieldStyle(.plain)
                    .focused($isFocused)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }

                Button("Cancel") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        searchText = ""
                        isPresented = false
                    }
                }
                .foregroundStyle(Color.accentColor)
            }
            .padding(12)
            .background(.ultraThinMaterial)
        }
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    ActivityListView()
        .modelContainer(for: [Activity.self, CompletionRecord.self, Category.self], inMemory: true)
        .preferredColorScheme(.dark)
}
