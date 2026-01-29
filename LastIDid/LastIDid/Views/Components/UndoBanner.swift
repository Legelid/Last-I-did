//
//  UndoBanner.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import SwiftUI

/// A banner that appears after completing an activity, allowing undo
struct UndoBanner: View {
    let activityName: String
    let onUndo: () -> Void
    let onDismiss: () -> Void

    @State private var timeRemaining: TimeInterval = 5.0
    @State private var timer: Timer?

    var body: some View {
        HStack(spacing: 12) {
            // Checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(SoftColors.softGreen)

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text("Completed!")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(activityName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Undo button
            Button {
                HapticFeedback.undo()
                timer?.invalidate()
                onUndo()
            } label: {
                Text(SoftLanguage.Actions.undo)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.accentColor)
            }

            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    .frame(width: 24, height: 24)

                Circle()
                    .trim(from: 0, to: timeRemaining / 5.0)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 24, height: 24)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: timeRemaining)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.15))
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation {
                timeRemaining -= 0.1
            }

            if timeRemaining <= 0 {
                timer?.invalidate()
                onDismiss()
            }
        }
    }
}

// MARK: - Undo Banner Manager

class UndoBannerManager: ObservableObject {
    static let shared = UndoBannerManager()

    @Published var isShowing = false
    @Published var activityName = ""

    private var undoAction: (() -> Void)?
    private var dismissTask: Task<Void, Never>?

    private init() {}

    func show(activityName: String, undoAction: @escaping () -> Void) {
        self.activityName = activityName
        self.undoAction = undoAction

        withAnimation(.spring(response: 0.3)) {
            isShowing = true
        }
    }

    func undo() {
        undoAction?()
        dismiss()
    }

    func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            isShowing = false
        }
        undoAction = nil
    }
}

// MARK: - Undo Banner Overlay Modifier

struct UndoBannerOverlayModifier: ViewModifier {
    @StateObject private var manager = UndoBannerManager.shared

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content

            if manager.isShowing {
                UndoBanner(
                    activityName: manager.activityName,
                    onUndo: { manager.undo() },
                    onDismiss: { manager.dismiss() }
                )
                .padding(.horizontal)
                .padding(.bottom, 100)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

extension View {
    func withUndoBanner() -> some View {
        modifier(UndoBannerOverlayModifier())
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack {
            Spacer()

            UndoBanner(
                activityName: "Water plants",
                onUndo: { print("Undo tapped") },
                onDismiss: { print("Dismissed") }
            )
            .padding()
        }
    }
}
