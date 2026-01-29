# Last I Did

An iOS activity tracking app that emphasizes gentle awareness and supportive reflection over productivity pressure.

## Overview

Last I Did helps users track their daily activities with a focus on positive reinforcement and self-compassion. The app features rotating affirmations, gentle context messages, and personalized themes designed to encourage awareness without judgment.

## Features

### Core Functionality
- **Activity Tracking**: Log activities with timestamps and optional notes
- **Gentle Reminders**: Location-based and calendar-integrated prompts
- **Completion Records**: Track activity history and patterns
- **Category Organization**: Organize activities by customizable categories

### Home Screen
- **Rotating Affirmations**: Supportive messages that encourage self-compassion
- **Gentle Context Messages**: Personalized, non-judgmental activity insights
- **Theme Variants**:
  - **Default**: Clean, minimalist interface
  - **Gamer**: Gaming-inspired visual design
  - **Tabletop**: D&D and tabletop RPG themed aesthetics

### Design Philosophy
The app is built around the principle that tracking should support awareness and well-being, not create pressure or guilt. Every feature is designed to be encouraging rather than demanding.

## Technical Stack

- **Language**: Swift
- **Framework**: SwiftUI
- **Platform**: iOS
- **Architecture**: Modern iOS development patterns with services and models

## Project Structure

```
LastIDid/
├── Models/              # Data models
│   ├── Activity.swift
│   ├── ActivityTemplate.swift
│   ├── CompletionRecord.swift
│   ├── Category.swift
│   └── AgingState.swift
├── Services/            # Business logic and managers
│   ├── CalendarManager.swift
│   ├── NotificationManager.swift
│   ├── LocationReminderManager.swift
│   └── CloudKitManager.swift
├── Intents/            # App intents and Siri integration
└── LastIDIdApp.swift   # Main app entry point
```

## Key Components

### Activity Management
- Templates for recurring activities
- Completion tracking with timestamps
- Category-based organization
- Aging state tracking for activity awareness

### Notifications & Reminders
- Calendar-based reminders
- Location-based triggers
- Haptic feedback for engagement
- Notification management system

### Personalization
- Multiple theme options
- Customizable affirmations
- User preferences and settings
- Language theme support (soft language by default)

## Development

This project is actively being developed with a focus on:
- User-centered design
- Accessibility
- Performance optimization
- Privacy-first approach

## About

Created by Andrew Collins as part of a transition from IT specialist to iOS developer. The app reflects a commitment to thoughtful, empathetic software design that prioritizes user well-being.

## License

This project is currently private and not licensed for public use.

---

*Note: This is an active development project. Features and structure may change as the app evolves.*
