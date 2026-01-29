//
//  ReminderStatusBadge.swift
//  LastIDid
//
//  Created by Claude on 1/21/26.
//

import SwiftUI

struct ReminderStatusBadge: View {
    let status: ReminderStatus
    var cooldownRemaining: String?

    var color: Color {
        switch status {
        case .monitoring: return .green
        case .cooldown: return .orange
        case .tooFar: return .yellow
        case .paused: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption2)

            if status == .cooldown, let remaining = cooldownRemaining {
                Text(remaining)
                    .font(.caption2)
            } else {
                Text(status.label)
                    .font(.caption2)
            }
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 16) {
        ReminderStatusBadge(status: .monitoring)
        ReminderStatusBadge(status: .cooldown, cooldownRemaining: "18h")
        ReminderStatusBadge(status: .tooFar)
        ReminderStatusBadge(status: .paused)
    }
    .padding()
    .preferredColorScheme(.dark)
}
