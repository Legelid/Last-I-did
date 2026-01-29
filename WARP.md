# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

LastIDid is a SwiftUI app using SwiftData for persistence. It targets both iOS and macOS (multiplatform).

## Build Commands

```bash
# Build for macOS
xcodebuild -project LastIDid/LastIDid.xcodeproj -scheme LastIDid -destination 'platform=macOS' build

# Build for iOS Simulator
xcodebuild -project LastIDid/LastIDid.xcodeproj -scheme LastIDid -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## Testing

Unit tests use Swift Testing framework (`import Testing`), UI tests use XCTest.

```bash
# Run all tests (macOS)
xcodebuild -project LastIDid/LastIDid.xcodeproj -scheme LastIDid -destination 'platform=macOS' test

# Run all tests (iOS Simulator)
xcodebuild -project LastIDid/LastIDid.xcodeproj -scheme LastIDid -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a specific test
xcodebuild -project LastIDid/LastIDid.xcodeproj -scheme LastIDid -destination 'platform=macOS' test -only-testing:LastIDidTests/LastIDidTests/example
```

## Architecture

- **App Entry**: `LastIDidApp.swift` - Configures SwiftData `ModelContainer` and injects it into the view hierarchy
- **Data Model**: `Item.swift` - SwiftData `@Model` class with a `timestamp` property
- **Views**: `ContentView.swift` - Main view using `NavigationSplitView` with `@Query` for data fetching and `@Environment(\.modelContext)` for mutations

Data flows through SwiftData's environment-based injection: the `ModelContainer` is set at the app level, and views access the `modelContext` to insert/delete items.
