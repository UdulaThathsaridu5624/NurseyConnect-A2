//
//  ChildListWindow.swift
//  NurseyConnect-visionOS
//
//  Created by Udula on 2026-05-30.
//

import SwiftUI

struct ChildListWindow: View {
    let roomID: UUID
    @Environment(\.dismissWindow) private var dismissWindow

    private var room: VisionRoom? {
        VisionSampleData.rooms.first { $0.id == roomID }
    }

    var body: some View {
        NavigationStack {
            Group {
                if let room = room {
                    let active = room.children.filter { $0.isActive }
                    if active.isEmpty {
                        ContentUnavailableView("No Children", systemImage: "figure.child",
                            description: Text("No active children in this room."))
                    } else {
                        List(active) { child in
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [Color(nurseryHex: "#2E9E66"), Color(nurseryHex: "#269BB5")],
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 48, height: 48)
                                    .overlay {
                                        Text(child.initials)
                                            .font(.system(.headline, design: .rounded, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(child.preferredName)
                                        .font(.system(.headline, design: .rounded, weight: .semibold))
                                    HStack(spacing: 8) {
                                        Text(child.age).font(.subheadline).foregroundStyle(.secondary)
                                        if !child.allergies.isEmpty {
                                            Label(child.allergies.joined(separator: ", "), systemImage: "allergens")
                                                .font(.caption).foregroundStyle(.orange)
                                        }
                                    }
                                }
                                Spacer()
                                Label(child.isPresent ? "Present" : "Not in",
                                      systemImage: child.isPresent ? "checkmark.circle.fill" : "clock")
                                    .font(.caption)
                                    .foregroundStyle(child.isPresent ? .green : .secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .listStyle(.insetGrouped)
                    }
                } else {
                    ContentUnavailableView("Room Not Found", systemImage: "door.left.hand.open")
                }
            }
            .navigationTitle(room?.name ?? "Room Detail")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismissWindow() }
                }
            }
        }
    }
}
