//
//  SettingsView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    @AppStorage("userName") private var userName: String = ""
    @AppStorage(AppPreferenceKey.backgroundTheme) private var backgroundThemeRaw = "pureBlack"
    @AppStorage(AppPreferenceKey.customBackgroundColor) private var customBackgroundHex = "1C1C1E"

    // Home affirmation settings
    @AppStorage(AppPreferenceKey.selectedLanguageTheme) private var selectedLanguageTheme = "default"
    @AppStorage(AppPreferenceKey.showHomeAffirmations) private var showHomeAffirmations = true
    @AppStorage(AppPreferenceKey.showAffirmationEmojis) private var showAffirmationEmojis = false

    @ObservedObject private var cloudKitManager = CloudKitManager.shared
    @ObservedObject private var calendarManager = CalendarManager.shared
    @ObservedObject private var locationReminderManager = LocationReminderManager.shared

    @State private var showingCategoryForm = false
    @State private var categoryToEdit: Category?
    @State private var showingExport = false
    @State private var showingResetAlert = false
    @State private var showingNameEditor = false
    @State private var tempName = ""
    @State private var showingCustomize = false
    @State private var showingAppPromise = false
    @State private var showingRoomTemplates = false

    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex

    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(Color.accentColor)

                        VStack(alignment: .leading) {
                            Text(userName.isEmpty ? "Set Your Name" : userName)
                                .font(.headline)
                            Text("Tap to edit")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        tempName = userName
                        showingNameEditor = true
                    }
                } header: {
                    Text("Profile")
                }

                // Customize Section
                Section {
                    Button {
                        showingCustomize = true
                    } label: {
                        HStack {
                            Label("Customize", systemImage: "paintbrush.fill")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("Customize header style, colors, greeting, and display options.")
                }

                // Categories Section
                Section {
                    ForEach(categories) { category in
                        HStack {
                            Image(systemName: category.systemIcon)
                                .foregroundStyle(category.color)
                                .frame(width: 24)

                            Text(category.name)

                            Spacer()

                            if category.isSystemCategory {
                                Text("System")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            categoryToEdit = category
                        }
                    }
                    .onDelete(perform: deleteCategories)

                    Button {
                        showingCategoryForm = true
                    } label: {
                        Label("Add Category", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text("Categories")
                }

                // Room Templates Section
                Section {
                    Button {
                        showingRoomTemplates = true
                    } label: {
                        HStack {
                            Label("Room Templates", systemImage: "house.fill")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Getting Started")
                } footer: {
                    Text("Quick start with common household activities by room.")
                }

                // Sync Section
                Section {
                    HStack {
                        Image(systemName: cloudKitManager.statusIcon)
                            .foregroundStyle(cloudKitManager.isSignedIn ? .green : .secondary)

                        VStack(alignment: .leading) {
                            Text("iCloud Sync")
                            Text(cloudKitManager.statusDescription)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if cloudKitManager.isCheckingStatus {
                            ProgressView()
                        }
                    }

                    if cloudKitManager.isSignedIn {
                        Text(cloudKitManager.lastSyncDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Sync")
                }

                // Integrations Section
                Section {
                    // Calendar Access
                    HStack {
                        Image(systemName: calendarManager.hasCalendarAccess ? "calendar.badge.checkmark" : "calendar.badge.exclamationmark")
                            .foregroundStyle(calendarManager.hasCalendarAccess ? .green : .orange)

                        VStack(alignment: .leading) {
                            Text("Calendar Access")
                            Text(calendarManager.hasCalendarAccess ? "Enabled" : "Not enabled")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if !calendarManager.hasCalendarAccess {
                            Button("Enable") {
                                Task {
                                    await calendarManager.requestAccess()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    // Location Reminders
                    HStack {
                        Image(systemName: locationReminderManager.hasLocationPermission ? "location.fill" : "location")
                            .foregroundStyle(locationReminderManager.hasLocationPermission ? .green : .secondary)

                        VStack(alignment: .leading) {
                            Text("Location Reminders")
                            Text(locationReminderManager.hasLocationPermission ? "Enabled" : "Not enabled")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if !locationReminderManager.hasLocationPermission {
                            Button("Enable") {
                                locationReminderManager.requestPermissions()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                } header: {
                    Text("Integrations")
                } footer: {
                    Text("Calendar access helps suggest good times. Location reminders notify you when you arrive at specific places.")
                }

                // Data Section
                Section {
                    Button {
                        showingExport = true
                    } label: {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }

                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Data")
                }

                // Privacy Section
                Section {
                    Button {
                        showingAppPromise = true
                    } label: {
                        HStack {
                            Label("Our Promise", systemImage: "heart.fill")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Privacy")
                } footer: {
                    Text("We believe in calm, non-judgmental awareness tracking. Your data stays on your device.")
                }

                // Life Care Section
                Section {
                    NavigationLink {
                        LanguageThemeSettingsView()
                    } label: {
                        HStack {
                            Label("Language Theme", systemImage: "textformat")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(AppLanguageTheme.from(selectedLanguageTheme).displayName)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Toggle(isOn: $showHomeAffirmations) {
                        Label("Home Affirmations", systemImage: "heart.text.square")
                    }

                    if showHomeAffirmations {
                        Toggle(isOn: $showAffirmationEmojis) {
                            Label("Show Emojis", systemImage: "face.smiling")
                        }
                    }

                    NavigationLink {
                        AffirmationSettingsView()
                    } label: {
                        Label("Notification Affirmations", systemImage: "sparkles")
                    }
                } header: {
                    Text("Life Care")
                } footer: {
                    Text("Gentle, supportive messages to help you feel noticed.")
                }

                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("About")
                }
            }
            .scrollContentBackground(.hidden)
            .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCategoryForm) {
                CategoryFormView(category: nil)
            }
            .sheet(item: $categoryToEdit) { category in
                CategoryFormView(category: category)
            }
            .sheet(isPresented: $showingExport) {
                ExportView()
            }
            .alert("What should we call you?", isPresented: $showingNameEditor) {
                TextField("Your name", text: $tempName)
                Button("Save") {
                    userName = tempName.trimmingCharacters(in: .whitespaces)
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Reset All Data?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will delete all activities, completions, and custom categories. This cannot be undone.")
            }
            .sheet(isPresented: $showingCustomize) {
                CustomizeView()
            }
            .fullScreenCover(isPresented: $showingAppPromise) {
                AppPromiseView()
            }
            .sheet(isPresented: $showingRoomTemplates) {
                RoomTemplatesView()
            }
        }
    }

    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            // Don't delete system categories
            if !category.isSystemCategory {
                modelContext.delete(category)
            }
        }
    }

    private func resetAllData() {
        // Delete all activities (completions cascade)
        let activityDescriptor = FetchDescriptor<Activity>()
        if let activities = try? modelContext.fetch(activityDescriptor) {
            for activity in activities {
                modelContext.delete(activity)
            }
        }

        // Delete non-system categories
        let categoryDescriptor = FetchDescriptor<Category>()
        if let allCategories = try? modelContext.fetch(categoryDescriptor) {
            for category in allCategories where !category.isSystemCategory {
                modelContext.delete(category)
            }
        }

        // Reset user defaults
        UserDefaults.standard.removeObject(forKey: "userName")
        userName = ""
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [Activity.self, CompletionRecord.self, Category.self, LocationReminder.self], inMemory: true)
        .preferredColorScheme(.dark)
}
