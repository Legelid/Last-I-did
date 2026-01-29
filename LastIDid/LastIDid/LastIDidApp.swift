//
//  LastIDidApp.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import SwiftUI
import SwiftData

@main
struct LastIDidApp: App {
    @AppStorage(AppPreferenceKey.accentColorName) private var accentColorName = "system"
    @AppStorage(AppPreferenceKey.agingColorIntensity) private var agingColorIntensity = "standard"
    @AppStorage(AppPreferenceKey.backgroundTheme) private var backgroundThemeRaw = "pureBlack"
    @AppStorage(AppPreferenceKey.customBackgroundColor) private var customBackgroundHex = "1C1C1E"
    @AppStorage(AppPreferenceKey.useSoftColors) private var useSoftColors = true

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Activity.self,
            CompletionRecord.self,
            Category.self,
            LocationReminder.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        NotificationManager.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .tint(AccentColorOption.from(accentColorName).color)
                .environment(\.agingColorIntensity, AgingColorIntensity.from(agingColorIntensity))
                .environment(\.backgroundTheme, BackgroundTheme.from(backgroundThemeRaw))
                .environment(\.customBackgroundHex, customBackgroundHex)
                .environment(\.useSoftColors, useSoftColors)
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Content View with First Launch Handling
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedFirstLaunch") private var hasCompletedFirstLaunch = false
    @AppStorage(AppPreferenceKey.hasSeenOnboarding) private var hasSeenOnboarding = false

    // Preferences to set on first launch
    @AppStorage(AppPreferenceKey.backgroundTheme) private var backgroundTheme = "pureBlack"
    @AppStorage(AppPreferenceKey.headerStyle) private var headerStyle = "gradient"

    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView()
            } else {
                MainTabView()
                    .withAppPromise()
            }
        }
        .onAppear {
            setupFirstLaunchIfNeeded()
            setupLocationReminders()
        }
    }

    private func setupLocationReminders() {
        let manager = LocationReminderManager.shared
        manager.setModelContext(modelContext)

        // Refresh geofences on app launch
        if manager.hasLocationPermission {
            manager.refreshGeofences()
        }
    }

    private func setupFirstLaunchIfNeeded() {
        guard !hasCompletedFirstLaunch else { return }

        // Set default preferences
        backgroundTheme = "darkBlue"
        headerStyle = "remotePhoto"

        // Seed system categories
        for (index, categoryData) in Category.systemCategories.enumerated() {
            let category = Category(
                name: categoryData.name,
                systemIcon: categoryData.icon,
                colorHex: categoryData.colorHex,
                sortOrder: index,
                isSystemCategory: true
            )
            modelContext.insert(category)
        }

        // Create welcome activity
        let welcomeActivity = Activity(
            name: "Welcome to Last I Did!",
            notes: "Tap the + button below to create your first activity. Track things like watering plants, changing filters, or any recurring task you want to remember."
        )
        welcomeActivity.emoji = "👋"
        modelContext.insert(welcomeActivity)

        hasCompletedFirstLaunch = true
    }
}
