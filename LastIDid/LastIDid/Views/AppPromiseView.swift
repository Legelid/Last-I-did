//
//  AppPromiseView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import SwiftUI

/// Onboarding screen that presents the app's promise to users
struct AppPromiseView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppPreferenceKey.hasSeenAppPromise) private var hasSeenAppPromise = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Logo/Icon area
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [SoftColors.softGreen, SoftColors.softTeal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
            }

            // Title
            VStack(spacing: 8) {
                Text(SoftLanguage.AppPromise.title)
                    .font(.title)
                    .fontWeight(.bold)

                Text(SoftLanguage.AppPromise.tagline)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Promises
            VStack(alignment: .leading, spacing: 20) {
                ForEach(SoftLanguage.AppPromise.promises, id: \.self) { promise in
                    PromiseRow(text: promise)
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)

            Spacer()

            // Continue button
            Button {
                HapticFeedback.success()
                hasSeenAppPromise = true
                dismiss()
            } label: {
                Text("Let's Begin")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .background(
            LinearGradient(
                colors: [Color(white: 0.08), Color(white: 0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

// MARK: - Promise Row

struct PromiseRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "heart.fill")
                .font(.system(size: 14))
                .foregroundStyle(SoftColors.softGreen)
                .frame(width: 24, height: 24)
                .background(SoftColors.softGreen.opacity(0.2))
                .clipShape(Circle())

            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}

// MARK: - App Promise Sheet Modifier

struct AppPromiseSheetModifier: ViewModifier {
    @AppStorage(AppPreferenceKey.hasSeenAppPromise) private var hasSeenAppPromise = false
    @State private var showPromise = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                if !hasSeenAppPromise {
                    showPromise = true
                }
            }
            .fullScreenCover(isPresented: $showPromise) {
                AppPromiseView()
            }
    }
}

extension View {
    func withAppPromise() -> some View {
        modifier(AppPromiseSheetModifier())
    }
}

// MARK: - Preview

#Preview {
    AppPromiseView()
        .preferredColorScheme(.dark)
}
