//
//  CustomizeView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/21/26.
//

import SwiftUI
import PhotosUI

struct CustomizeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex

    // Header Settings
    @AppStorage(AppPreferenceKey.headerStyle) private var headerStyleRaw = "gradient"
    @AppStorage(AppPreferenceKey.gradientStyle) private var gradientStyleRaw = "edgeFade"
    @AppStorage(AppPreferenceKey.photoCycleFrequency) private var photoCycleFrequencyRaw = "daily"
    @AppStorage(AppPreferenceKey.customPhotoData) private var customPhotoData: Data?

    // Accent & Status Colors
    @AppStorage(AppPreferenceKey.accentColorName) private var accentColorName = "system"
    @AppStorage(AppPreferenceKey.agingColorIntensity) private var agingColorIntensityRaw = "standard"

    // Greeting Settings
    @AppStorage(AppPreferenceKey.greetingStyle) private var greetingStyleRaw = "timeOfDay"
    @AppStorage(AppPreferenceKey.greetingTextSize) private var greetingTextSizeRaw = "medium"
    @AppStorage(AppPreferenceKey.greetingAlignment) private var greetingAlignmentRaw = "leading"

    // Weather Settings
    @AppStorage("showWeather") private var showWeather = true
    @AppStorage("useCelsius") private var useCelsius = false

    // Activity Display
    @AppStorage(AppPreferenceKey.activitySortOrder) private var activitySortOrderRaw = "oldestFirst"
    @AppStorage(AppPreferenceKey.calendarStripEnabled) private var calendarStripEnabled = true
    @AppStorage("calendarDisplayMode") private var calendarDisplayModeRaw = "staticWeek"

    // Metrics
    @AppStorage("showMaintenanceScore") private var showMaintenanceScore = true
    @AppStorage("showStreaks") private var showStreaks = true

    // Soft Accountability
    @AppStorage(AppPreferenceKey.useSoftColors) private var useSoftColors = true
    @AppStorage(AppPreferenceKey.useSoftLanguage) private var useSoftLanguage = true
    @AppStorage(AppPreferenceKey.showAffirmations) private var showAffirmations = true
    @AppStorage(AppPreferenceKey.showReflectionPrompt) private var showReflectionPrompt = false

    // Background Theme
    @AppStorage(AppPreferenceKey.backgroundTheme) private var backgroundThemeRaw = "pureBlack"
    @AppStorage(AppPreferenceKey.customBackgroundColor) private var customBackgroundHex = "1C1C1E"

    // Photo Picker
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var customColor: Color = .gray

    private var headerStyle: HeaderStyle {
        HeaderStyle.from(headerStyleRaw)
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Header Section
                Section {
                    // Header Style Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Header Style")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(HeaderStyle.allCases) { style in
                                Button {
                                    headerStyleRaw = style.rawValue
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: style.systemImage)
                                            .font(.title3)
                                            .foregroundStyle(headerStyleRaw == style.rawValue ? .white : .secondary)

                                        Text(style.displayName)
                                            .font(.subheadline)
                                            .foregroundStyle(headerStyleRaw == style.rawValue ? .white : .primary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(headerStyleRaw == style.rawValue ? Color.accentColor : Color.secondary.opacity(0.2))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.vertical, 4)

                    // Gradient Style Picker (conditional)
                    if headerStyle == .gradient {
                        Picker("Gradient Style", selection: $gradientStyleRaw) {
                            ForEach(GradientStyle.allCases) { style in
                                Text(style.displayName).tag(style.rawValue)
                            }
                        }
                    }

                    // Custom Photo Picker (conditional)
                    if headerStyle == .customPhotoSingle {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            HStack {
                                Text("Select Photo")
                                Spacer()
                                if customPhotoData != nil {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                        .onChange(of: selectedPhotoItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    customPhotoData = data
                                }
                            }
                        }

                        if customPhotoData != nil {
                            Button(role: .destructive) {
                                customPhotoData = nil
                                selectedPhotoItem = nil
                            } label: {
                                Text("Remove Photo")
                            }
                        }
                    }

                    // Photo Collection & Cycle Frequency (conditional)
                    if headerStyle == .customPhotoCollection {
                        NavigationLink {
                            PhotoCollectionPickerView()
                        } label: {
                            Text("Select Album")
                        }

                        Picker("Cycle Frequency", selection: $photoCycleFrequencyRaw) {
                            ForEach(PhotoCycleFrequency.allCases) { freq in
                                Text(freq.displayName).tag(freq.rawValue)
                            }
                        }
                    }
                } header: {
                    Text("Header")
                }

                // MARK: - Colors Section
                Section {
                    Picker("Accent Color", selection: $accentColorName) {
                        ForEach(AccentColorOption.allCases) { option in
                            HStack {
                                Circle()
                                    .fill(option.color)
                                    .frame(width: 16, height: 16)
                                Text(option.displayName)
                            }
                            .tag(option.rawValue)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status Colors")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Picker("Status Colors", selection: $agingColorIntensityRaw) {
                            Text("Subtle").tag("subtle")
                            Text("Standard").tag("standard")
                            Text("High").tag("highContrast")
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Colors")
                }

                // MARK: - Greeting Section
                Section {
                    Picker("Style", selection: $greetingStyleRaw) {
                        Text("Off").tag("off")
                        Text("Time of Day").tag("timeOfDay")
                        Text("Simple").tag("simple")
                        Text("Motivational").tag("motivational")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Size")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Picker("Size", selection: $greetingTextSizeRaw) {
                            Text("S").tag("small")
                            Text("M").tag("medium")
                            Text("L").tag("large")
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Position")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Picker("Position", selection: $greetingAlignmentRaw) {
                            Text("Left").tag("leading")
                            Text("Center").tag("center")
                            Text("Right").tag("trailing")
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Greeting")
                }

                // MARK: - Weather Section
                Section {
                    Toggle("Show Weather", isOn: $showWeather)

                    if showWeather {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Temperature Unit")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Picker("Temperature Unit", selection: $useCelsius) {
                                Text("°F").tag(false)
                                Text("°C").tag(true)
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Weather")
                } footer: {
                    Text("Weather is displayed in the header alongside your greeting.")
                }

                // MARK: - Activity Display Section
                Section {
                    Picker("Sort Order", selection: $activitySortOrderRaw) {
                        Text("Oldest First").tag("oldestFirst")
                        Text("Newest First").tag("newestFirst")
                        Text("Alphabetical").tag("alphabetical")
                        Text("By Category").tag("byCategory")
                    }

                    Toggle("Calendar Strip", isOn: $calendarStripEnabled)

                    if calendarStripEnabled {
                        Picker("Calendar Mode", selection: $calendarDisplayModeRaw) {
                            ForEach(CalendarDisplayMode.allCases) { mode in
                                Text(mode.displayName).tag(mode.rawValue)
                            }
                        }
                    }
                } header: {
                    Text("Activity Display")
                } footer: {
                    if calendarStripEnabled {
                        Text("Static Week shows all 7 days with today highlighted. Centered Scrolling keeps today in the center.")
                    }
                }

                // MARK: - Metrics Section
                Section {
                    Toggle("Show Maintenance Score", isOn: $showMaintenanceScore)
                    Toggle("Show Streaks", isOn: $showStreaks)
                } header: {
                    Text("Metrics")
                }

                // MARK: - Accountability Style Section
                Section {
                    Toggle("Soft Colors", isOn: $useSoftColors)
                    Toggle("Gentle Language", isOn: $useSoftLanguage)
                    Toggle("Show Affirmations", isOn: $showAffirmations)
                    Toggle("Reflection Prompts", isOn: $showReflectionPrompt)
                } header: {
                    Text("Accountability Style")
                } footer: {
                    Text("Soft colors replace red with warm orange. Gentle language uses supportive phrasing. Affirmations celebrate your completions. Reflection prompts invite optional notes.")
                }

                // MARK: - Background Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(BackgroundTheme.allCases) { bgTheme in
                                Button {
                                    backgroundThemeRaw = bgTheme.rawValue
                                    if bgTheme == .custom {
                                        customColor = Color(hex: customBackgroundHex) ?? .gray
                                    }
                                } label: {
                                    VStack(spacing: 4) {
                                        if bgTheme == .custom {
                                            ZStack {
                                                Circle()
                                                    .fill(
                                                        AngularGradient(
                                                            colors: [.red, .yellow, .green, .cyan, .blue, .purple, .red],
                                                            center: .center
                                                        )
                                                    )
                                                    .frame(width: 36, height: 36)
                                                Circle()
                                                    .fill(Color(hex: customBackgroundHex) ?? .gray)
                                                    .frame(width: 24, height: 24)
                                            }
                                        } else {
                                            Circle()
                                                .fill(Color(hex: bgTheme.primaryHex) ?? .black)
                                                .frame(width: 36, height: 36)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                                )
                                        }
                                        Text(bgTheme.displayName)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(backgroundThemeRaw == bgTheme.rawValue ? Color.accentColor.opacity(0.2) : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(backgroundThemeRaw == bgTheme.rawValue ? Color.accentColor : Color.clear, lineWidth: 2)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        if backgroundThemeRaw == "custom" {
                            ColorPicker("Custom Color", selection: $customColor, supportsOpacity: false)
                                .onChange(of: customColor) { _, newValue in
                                    customBackgroundHex = newValue.toHex()
                                }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Background")
                }
            }
            .scrollContentBackground(.hidden)
            .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)
            .navigationTitle("Customize")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                customColor = Color(hex: customBackgroundHex) ?? .gray
            }
        }
    }
}

// MARK: - Photo Collection Picker View (Placeholder)

struct PhotoCollectionPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppPreferenceKey.photoCollectionIdentifier) private var photoCollectionIdentifier: String?

    var body: some View {
        List {
            Text("Photo collection picker coming soon")
                .foregroundStyle(.secondary)

            Section {
                Text("This feature requires access to your Photo Library to select an album for cycling header images.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Select Album")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CustomizeView()
        .preferredColorScheme(.dark)
}
