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
            VStack(spacing: 0) {
                if let room = room {
                    // Room header
                    HStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(room.color).frame(width: 5, height: 44)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(room.name)
                                .font(.system(.title3, design: .rounded, weight: .bold))
                            Text(room.ageGroup)
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            Text(room.ratioString).font(.caption).foregroundStyle(.secondary)
                            Image(systemName: room.ratioOK ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundStyle(room.ratioOK ? .green : .red)
                        }
                    }
                    .padding(.horizontal, 20).padding(.vertical, 14)
                    .background(.thinMaterial)

                    Divider()

                    let active = room.children.filter { $0.isActive }
                    if active.isEmpty {
                        Spacer()
                        ContentUnavailableView("No Children", systemImage: "figure.child")
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(active) { child in
                                    HStack(spacing: 16) {
                                        Circle()
                                            .fill(LinearGradient(
                                                colors: [Color(nurseryHex: "#2E9E66"), Color(nurseryHex: "#269BB5")],
                                                startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 52, height: 52)
                                            .overlay {
                                                Text(child.initials)
                                                    .font(.system(.headline, design: .rounded, weight: .bold))
                                                    .foregroundStyle(.white)
                                            }

                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(child.preferredName)
                                                .font(.system(.headline, design: .rounded, weight: .semibold))
                                            Text("Age: \(child.age)")
                                                .font(.subheadline).foregroundStyle(.secondary)
                                            if !child.allergies.isEmpty {
                                                Label(child.allergies.joined(separator: ", "),
                                                      systemImage: "allergens")
                                                    .font(.caption).foregroundStyle(.orange)
                                            }
                                        }

                                        Spacer()

                                        VStack(spacing: 4) {
                                            Image(systemName: child.isPresent ? "checkmark.circle.fill" : "xmark.circle")
                                                .font(.title2)
                                                .foregroundStyle(child.isPresent ? .green : .secondary)
                                            Text(child.isPresent ? "Present" : "Absent")
                                                .font(.caption2)
                                                .foregroundStyle(child.isPresent ? .green : .secondary)
                                        }
                                    }
                                    .padding(16)
                                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                                }
                            }
                            .padding(16)
                        }
                    }
                } else {
                    ContentUnavailableView("Room Not Found", systemImage: "door.left.hand.open")
                }
            }
            .navigationTitle(room?.name ?? "Room Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismissWindow() }
                }
            }
        }
    }
}
