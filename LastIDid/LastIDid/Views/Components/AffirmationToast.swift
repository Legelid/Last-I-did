//
//  AffirmationToast.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import SwiftUI

// MARK: - Toast Manager

/// Singleton manager for showing affirmation toasts
class ToastManager: ObservableObject {
    static let shared = ToastManager()

    @Published var isShowing = false
    @Published var message = ""
    @Published var icon: String = "checkmark.circle.fill"

    private var dismissTask: Task<Void, Never>?

    private init() {}

    /// Show an affirmation toast with auto-dismiss
    func show(_ message: String, icon: String = "checkmark.circle.fill", duration: TimeInterval = 2.5) {
        // Cancel any pending dismiss
        dismissTask?.cancel()

        // Update state on main thread
        DispatchQueue.main.async {
            self.message = message
            self.icon = icon

            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                self.isShowing = true
            }

            // Haptic feedback
            HapticFeedback.toast()
        }

        // Schedule auto-dismiss
        dismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))

            guard !Task.isCancelled else { return }

            withAnimation(.easeOut(duration: 0.2)) {
                self.isShowing = false
            }
        }
    }

    /// Show a completion affirmation with smart message selection
    func showCompletion(
        isFirstTime: Bool = false,
        streakCount: Int = 0,
        daysSinceLastCompletion: Int = 0
    ) {
        let message = MicroAffirmations.select(
            isFirstTime: isFirstTime,
            streakCount: streakCount,
            daysSinceLastCompletion: daysSinceLastCompletion
        )

        let icon: String
        if isFirstTime {
            icon = "star.fill"
        } else if streakCount >= 5 {
            icon = "flame.fill"
        } else {
            icon = "checkmark.circle.fill"
        }

        show(message, icon: icon)
    }

    /// Dismiss the toast immediately
    func dismiss() {
        dismissTask?.cancel()
        withAnimation(.easeOut(duration: 0.2)) {
            isShowing = false
        }
    }
}

// MARK: - Affirmation Toast View

struct AffirmationToast: View {
    @ObservedObject var toastManager: ToastManager

    var body: some View {
        if toastManager.isShowing {
            HStack(spacing: 12) {
                Image(systemName: toastManager.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(iconColor)

                Text(toastManager.message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(Color(white: 0.15))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .transition(.asymmetric(
                insertion: .scale(scale: 0.8).combined(with: .opacity).combined(with: .offset(y: -20)),
                removal: .opacity.combined(with: .offset(y: -10))
            ))
            .onTapGesture {
                toastManager.dismiss()
            }
        }
    }

    private var iconColor: Color {
        switch toastManager.icon {
        case "star.fill":
            return .yellow
        case "flame.fill":
            return .orange
        case "checkmark.circle.fill":
            return SoftColors.softGreen
        default:
            return .white
        }
    }
}

// MARK: - Toast Overlay Modifier

struct ToastOverlayModifier: ViewModifier {
    @StateObject private var toastManager = ToastManager.shared

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content

            AffirmationToast(toastManager: toastManager)
                .padding(.top, 60)
        }
    }
}

extension View {
    /// Adds an affirmation toast overlay to the view
    func withAffirmationToast() -> some View {
        modifier(ToastOverlayModifier())
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 20) {
            Button("Show Completion") {
                ToastManager.shared.showCompletion()
            }

            Button("Show First Time") {
                ToastManager.shared.showCompletion(isFirstTime: true)
            }

            Button("Show Streak") {
                ToastManager.shared.showCompletion(streakCount: 5)
            }

            Button("Custom Message") {
                ToastManager.shared.show("Custom toast message!", icon: "heart.fill")
            }
        }
        .buttonStyle(.borderedProminent)
    }
    .withAffirmationToast()
}
