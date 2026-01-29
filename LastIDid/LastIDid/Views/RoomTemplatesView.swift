//
//  RoomTemplatesView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import SwiftUI
import SwiftData

struct RoomTemplatesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex

    @State private var selectedRoom: RoomTemplate?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Browse common household activities organized by room. Select a room to preview activities.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Section("Available Rooms") {
                    ForEach(RoomTemplateData.allRooms) { template in
                        Button {
                            selectedRoom = template
                        } label: {
                            RoomTemplateRow(template: template)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(ThemeColors(theme: theme, customHex: customHex).primaryColor)
            .navigationTitle("Room Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedRoom) { room in
                RoomTemplateDetailView(template: room)
            }
        }
    }
}

struct RoomTemplateRow: View {
    let template: RoomTemplate

    var body: some View {
        HStack(spacing: 16) {
            Text(template.emoji)
                .font(.system(size: 40))

            VStack(alignment: .leading, spacing: 4) {
                Text(template.roomName)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("\(template.activities.count) activities")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(template.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    RoomTemplatesView()
        .modelContainer(for: [Activity.self, Category.self], inMemory: true)
        .preferredColorScheme(.dark)
}
