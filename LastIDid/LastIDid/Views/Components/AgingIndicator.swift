//
//  AgingIndicator.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import SwiftUI

struct AgingIndicator: View {
    @Environment(\.agingColorIntensity) private var colorIntensity
    let state: AgingState
    var size: Size = .medium
    var useSoftColors: Bool = false

    enum Size {
        case small
        case medium
        case large

        var iconSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 24
            }
        }

        var frameSize: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 28
            case .large: return 40
            }
        }
    }

    private var effectiveColor: Color {
        if useSoftColors {
            return state.softColor
        }
        return state.color(intensity: colorIntensity)
    }

    private var effectiveIcon: String {
        useSoftColors ? state.softIcon : state.icon
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(effectiveColor.opacity(0.2))
                .frame(width: size.frameSize, height: size.frameSize)

            Image(systemName: effectiveIcon)
                .font(.system(size: size.iconSize, weight: .semibold))
                .foregroundStyle(effectiveColor)
        }
    }
}

// MARK: - Animated Aging Indicator
struct AnimatedAgingIndicator: View {
    let state: AgingState
    var size: AgingIndicator.Size = .medium

    @State private var isPulsing = false

    var body: some View {
        AgingIndicator(state: state, size: size)
            .scaleEffect(isPulsing && state == .stale ? 1.1 : 1.0)
            .animation(
                state == .stale ?
                    .easeInOut(duration: 1.0).repeatForever(autoreverses: true) :
                    .default,
                value: isPulsing
            )
            .onAppear {
                if state == .stale {
                    isPulsing = true
                }
            }
    }
}

// MARK: - Days Since Badge
struct DaysSinceBadge: View {
    @Environment(\.agingColorIntensity) private var colorIntensity
    let days: Int

    private var displayText: String {
        if days == Int.max {
            return "New"
        } else if days == 0 {
            return "Today"
        } else if days == 1 {
            return "1 day"
        } else {
            return "\(days) days"
        }
    }

    private var state: AgingState {
        AgingState.from(daysSince: days)
    }

    private var effectiveColor: Color {
        state.color(intensity: colorIntensity)
    }

    var body: some View {
        Text(displayText)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(effectiveColor.opacity(0.2))
            .foregroundStyle(effectiveColor)
            .cornerRadius(8)
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            ForEach(AgingState.allCases, id: \.self) { state in
                VStack {
                    AgingIndicator(state: state, size: .small)
                    AgingIndicator(state: state, size: .medium)
                    AgingIndicator(state: state, size: .large)
                    Text(state.label)
                        .font(.caption)
                }
            }
        }

        Divider()

        HStack(spacing: 12) {
            DaysSinceBadge(days: 0)
            DaysSinceBadge(days: 1)
            DaysSinceBadge(days: 7)
            DaysSinceBadge(days: 15)
            DaysSinceBadge(days: 45)
            DaysSinceBadge(days: Int.max)
        }
    }
    .padding()
    .preferredColorScheme(.dark)
}
