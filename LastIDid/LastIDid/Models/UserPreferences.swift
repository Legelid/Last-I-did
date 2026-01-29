import SwiftUI
import UIKit

// MARK: - Preference Keys

enum AppPreferenceKey {
    static let accentColorName = "accentColorName"
    static let greetingTextSize = "greetingTextSize"
    static let greetingStyle = "greetingStyle"
    static let greetingAlignment = "greetingAlignment"
    static let activitySortOrder = "activitySortOrder"
    static let agingColorIntensity = "agingColorIntensity"
    static let backgroundTheme = "backgroundTheme"
    static let customBackgroundColor = "customBackgroundColor"

    // Header Style
    static let headerStyle = "headerStyle"
    static let gradientStyle = "gradientStyle"
    static let customPhotoData = "customPhotoData"
    static let photoCollectionIdentifier = "photoCollectionIdentifier"
    static let photoCycleFrequency = "photoCycleFrequency"
    static let currentPhotoIndex = "currentPhotoIndex"
    static let lastPhotoChangeDate = "lastPhotoChangeDate"

    // Calendar Strip
    static let calendarStripEnabled = "calendarStripEnabled"
    static let calendarStripStyle = "calendarStripStyle"

    // Soft Accountability Features
    static let useSoftColors = "useSoftColors"
    static let useSoftLanguage = "useSoftLanguage"
    static let showAffirmations = "showAffirmations"
    static let showReflectionPrompt = "showReflectionPrompt"
    static let hasSeenAppPromise = "hasSeenAppPromise"

    // Life Care / Affirmation Features
    static let hasSeenOnboarding = "hasSeenOnboarding"
    static let affirmationNotificationsEnabled = "affirmationNotificationsEnabled"
    static let affirmationHour = "affirmationHour"
    static let affirmationMinute = "affirmationMinute"
    static let lastContextualMoment = "lastContextualMoment"
    static let lastAppOpen = "lastAppOpen"

    // Home Screen Affirmations & Language Theme
    static let selectedLanguageTheme = "selectedLanguageTheme"
    static let showHomeAffirmations = "showHomeAffirmations"
    static let showAffirmationEmojis = "showAffirmationEmojis"
}

// MARK: - Accent Color Option

enum AccentColorOption: String, CaseIterable, Identifiable {
    case system
    case coral
    case teal
    case indigo
    case mint
    case pink
    case amber

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .coral: return "Coral"
        case .teal: return "Teal"
        case .indigo: return "Indigo"
        case .mint: return "Mint"
        case .pink: return "Pink"
        case .amber: return "Amber"
        }
    }

    var color: Color {
        switch self {
        case .system: return .blue
        case .coral: return Color(hex: "FF7060") ?? .orange
        case .teal: return Color(hex: "00B0AD") ?? .teal
        case .indigo: return Color(hex: "5957D6") ?? .indigo
        case .mint: return Color(hex: "00C795") ?? .mint
        case .pink: return Color(hex: "FF73AD") ?? .pink
        case .amber: return Color(hex: "FFC000") ?? .yellow
        }
    }

    static func from(_ rawValue: String) -> AccentColorOption {
        AccentColorOption(rawValue: rawValue) ?? .system
    }
}

// MARK: - Greeting Text Size

enum GreetingTextSize: String, CaseIterable, Identifiable {
    case small
    case medium
    case large

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .small: return "S"
        case .medium: return "M"
        case .large: return "L"
        }
    }

    var greetingFont: Font {
        switch self {
        case .small: return .caption
        case .medium: return .subheadline
        case .large: return .headline
        }
    }

    var nameFont: Font {
        switch self {
        case .small: return .title3
        case .medium: return .title
        case .large: return .largeTitle
        }
    }

    static func from(_ rawValue: String) -> GreetingTextSize {
        GreetingTextSize(rawValue: rawValue) ?? .medium
    }
}

// MARK: - Greeting Style

enum GreetingStyle: String, CaseIterable, Identifiable {
    case off
    case timeOfDay
    case simple
    case motivational

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .off: return "Off"
        case .timeOfDay: return "Time of Day"
        case .simple: return "Simple"
        case .motivational: return "Motivational"
        }
    }

    func greeting(for name: String) -> String? {
        switch self {
        case .off:
            return nil
        case .timeOfDay:
            let hour = Calendar.current.component(.hour, from: Date())
            if hour < 12 {
                return "Good morning"
            } else if hour < 17 {
                return "Good afternoon"
            } else {
                return "Good evening"
            }
        case .simple:
            return "Hello"
        case .motivational:
            let phrases = [
                "Let's do this",
                "You've got this",
                "Stay on track",
                "Keep going",
                "Make it happen"
            ]
            // Use day of year for consistent daily phrase
            let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
            return phrases[dayOfYear % phrases.count]
        }
    }

    static func from(_ rawValue: String) -> GreetingStyle {
        GreetingStyle(rawValue: rawValue) ?? .timeOfDay
    }
}

// MARK: - Greeting Alignment

enum GreetingAlignment: String, CaseIterable, Identifiable {
    case leading
    case center
    case trailing

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .leading: return "Left"
        case .center: return "Center"
        case .trailing: return "Right"
        }
    }

    static func from(_ rawValue: String) -> GreetingAlignment {
        GreetingAlignment(rawValue: rawValue) ?? .leading
    }
}

// MARK: - Activity Sort Order

enum ActivitySortOrder: String, CaseIterable, Identifiable {
    case oldestFirst
    case newestFirst
    case alphabetical
    case byCategory

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .oldestFirst: return "Oldest First"
        case .newestFirst: return "Newest First"
        case .alphabetical: return "Alphabetical"
        case .byCategory: return "By Category"
        }
    }

    static func from(_ rawValue: String) -> ActivitySortOrder {
        ActivitySortOrder(rawValue: rawValue) ?? .oldestFirst
    }
}

// MARK: - Aging Color Intensity

enum AgingColorIntensity: String, CaseIterable, Identifiable {
    case subtle
    case standard
    case highContrast

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .subtle: return "Subtle"
        case .standard: return "Standard"
        case .highContrast: return "High"
        }
    }

    static func from(_ rawValue: String) -> AgingColorIntensity {
        AgingColorIntensity(rawValue: rawValue) ?? .standard
    }
}

// MARK: - Environment Key for Aging Intensity

private struct AgingColorIntensityKey: EnvironmentKey {
    static let defaultValue: AgingColorIntensity = .standard
}

extension EnvironmentValues {
    var agingColorIntensity: AgingColorIntensity {
        get { self[AgingColorIntensityKey.self] }
        set { self[AgingColorIntensityKey.self] = newValue }
    }
}

// MARK: - Background Theme

enum BackgroundTheme: String, CaseIterable, Identifiable {
    case pureBlack
    case darkGray
    case charcoal
    case darkBlue
    case darkGreen
    case darkPurple
    case darkBrown
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pureBlack: return "Pure Black"
        case .darkGray: return "Dark Gray"
        case .charcoal: return "Charcoal"
        case .darkBlue: return "Dark Blue"
        case .darkGreen: return "Dark Green"
        case .darkPurple: return "Dark Purple"
        case .darkBrown: return "Dark Brown"
        case .custom: return "Custom"
        }
    }

    var primaryHex: String {
        switch self {
        case .pureBlack: return "000000"
        case .darkGray: return "1C1C1E"
        case .charcoal: return "2C2C2E"
        case .darkBlue: return "0D1B2A"
        case .darkGreen: return "0D1F0D"
        case .darkPurple: return "1A0D1F"
        case .darkBrown: return "1F1410"
        case .custom: return "1C1C1E"
        }
    }

    var secondaryHex: String {
        switch self {
        case .pureBlack: return "1C1C1E"
        case .darkGray: return "2C2C2E"
        case .charcoal: return "3A3A3C"
        case .darkBlue: return "1B2838"
        case .darkGreen: return "1B2F1B"
        case .darkPurple: return "2A1B2F"
        case .darkBrown: return "2F2018"
        case .custom: return "2C2C2E"
        }
    }

    static func from(_ rawValue: String) -> BackgroundTheme {
        BackgroundTheme(rawValue: rawValue) ?? .pureBlack
    }
}

// MARK: - Environment Key for Background Theme

private struct BackgroundThemeKey: EnvironmentKey {
    static let defaultValue: BackgroundTheme = .pureBlack
}

private struct CustomBackgroundHexKey: EnvironmentKey {
    static let defaultValue: String = "1C1C1E"
}

extension EnvironmentValues {
    var backgroundTheme: BackgroundTheme {
        get { self[BackgroundThemeKey.self] }
        set { self[BackgroundThemeKey.self] = newValue }
    }

    var customBackgroundHex: String {
        get { self[CustomBackgroundHexKey.self] }
        set { self[CustomBackgroundHexKey.self] = newValue }
    }
}

// MARK: - Color Extension for Lightening

extension Color {
    func lightened(by amount: Double = 0.15) -> Color {
        guard let components = UIColor(self).cgColor.components else { return self }
        let r = min(1.0, (components[0] + amount))
        let g = min(1.0, (components.count > 1 ? components[1] : components[0]) + amount)
        let b = min(1.0, (components.count > 2 ? components[2] : components[0]) + amount)
        return Color(red: r, green: g, blue: b)
    }
}

// MARK: - Theme Colors Helper

struct ThemeColors {
    let theme: BackgroundTheme
    let customHex: String

    var primaryColor: Color {
        if theme == .custom {
            return Color(hex: customHex) ?? Color(hex: "1C1C1E")!
        }
        return Color(hex: theme.primaryHex)!
    }

    var secondaryColor: Color {
        if theme == .custom {
            return (Color(hex: customHex) ?? Color(hex: "1C1C1E")!).lightened()
        }
        return Color(hex: theme.secondaryHex)!
    }
}

// MARK: - Header Style

enum HeaderStyle: String, CaseIterable, Identifiable {
    case remotePhoto = "remotePhoto"
    case gradient = "gradient"
    case customPhotoSingle = "customPhotoSingle"
    case customPhotoCollection = "customPhotoCollection"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .remotePhoto: return "Remote Photo"
        case .gradient: return "Gradient"
        case .customPhotoSingle: return "Custom Photo"
        case .customPhotoCollection: return "Photo Collection"
        }
    }

    var systemImage: String {
        switch self {
        case .remotePhoto: return "photo.on.rectangle"
        case .gradient: return "rectangle.fill"
        case .customPhotoSingle: return "photo"
        case .customPhotoCollection: return "photo.stack"
        }
    }

    static func from(_ rawValue: String) -> HeaderStyle {
        HeaderStyle(rawValue: rawValue) ?? .gradient
    }
}

// MARK: - Gradient Style

enum GradientStyle: String, CaseIterable, Identifiable {
    case edgeFade = "edgeFade"
    case linearVertical = "linearVertical"
    case linearDiagonal = "linearDiagonal"
    case radialCenter = "radialCenter"
    case angular = "angular"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .edgeFade: return "Edge Fade"
        case .linearVertical: return "Linear (Vertical)"
        case .linearDiagonal: return "Linear (Diagonal)"
        case .radialCenter: return "Radial (Center)"
        case .angular: return "Angular"
        }
    }

    static func from(_ rawValue: String) -> GradientStyle {
        GradientStyle(rawValue: rawValue) ?? .edgeFade
    }
}

// MARK: - Calendar Strip Style

enum CalendarStripStyle: String, CaseIterable, Identifiable {
    case weekView = "weekView"
    case centeredDay = "centeredDay"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weekView: return "Week View"
        case .centeredDay: return "Centered Day"
        }
    }

    static func from(_ rawValue: String) -> CalendarStripStyle {
        CalendarStripStyle(rawValue: rawValue) ?? .centeredDay
    }
}

// MARK: - Photo Cycle Frequency

enum PhotoCycleFrequency: String, CaseIterable, Identifiable {
    case hourly
    case daily
    case weekly

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }

    var intervalSeconds: TimeInterval {
        switch self {
        case .hourly: return 3600
        case .daily: return 86400
        case .weekly: return 604800
        }
    }

    static func from(_ rawValue: String) -> PhotoCycleFrequency {
        PhotoCycleFrequency(rawValue: rawValue) ?? .daily
    }
}

