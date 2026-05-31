//
//  RoomDetailView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import SwiftData

struct RoomDetailView: View {
    let room: Room
    @Environment(\.modelContext) private var modelContext

    var activeChildren: [Child] { room.children.filter { $0.isActive } }
    var presentStaff: [StaffMember] { room.staff.filter { $0.isPresent } }
    var absentStaff: [StaffMember] { room.staff.filter { !$0.isPresent } }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {

                // Room header card
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(room.name).font(.system(.title2, design: .rounded, weight: .bold))
                        Text(room.ageGroup.rawValue).font(.bodySmall).foregroundStyle(.secondary)
                        Text(room.ratioString).font(.bodySmall).foregroundStyle(.secondary)
                    }
                    Spacer()
                    RatioBadge(room: room)
                }
                .padding(AppSpacing.md)
                .background(Color(hex: room.colorHex).opacity(0.15))
                .background(Color.nurseryCard)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Staff section
                GroupBox {
                    if room.staff.isEmpty {
                        Text("No staff assigned").font(.bodySmall).foregroundStyle(.secondary)
                    } else {
                        VStack(spacing: AppSpacing.xs) {
                            ForEach(presentStaff) { staff in
                                HStack {
                                    Circle().fill(Color.green).frame(width: 8, height: 8)
                                    Text(staff.fullName).font(.cardTitle)
                                    Spacer()
                                    Text(staff.role.rawValue).font(.bodySmall).foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 2)
                            }
                            ForEach(absentStaff) { staff in
                                HStack {
                                    Circle().fill(Color.secondary.opacity(0.4)).frame(width: 8, height: 8)
                                    Text(staff.fullName).font(.cardTitle).foregroundStyle(.secondary)
                                    Spacer()
                                    Text(staff.role.rawValue).font(.bodySmall).foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                } label: {
                    Label("Staff On Duty (\(presentStaff.count)/\(room.staff.count))", systemImage: "person.2.fill")
                        .font(.sectionHead)
                }

                // Children section — supports drop to reassign
                GroupBox {
                    if activeChildren.isEmpty {
                        Text("No children assigned to this room")
                            .font(.bodySmall).foregroundStyle(.secondary)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(activeChildren) { child in
                                HStack {
                                    ChildRoomCard(child: child)
                                    MoveToRoomButton(child: child, currentRoom: room)
                                }
                                if child.id != activeChildren.last?.id { Divider() }
                            }
                        }
                    }
                } label: {
                    Label("Children (\(activeChildren.count))", systemImage: "figure.child")
                        .font(.sectionHead)
                }
                .dropDestination(for: String.self) { droppedIDs, _ in
                    for idString in droppedIDs {
                        guard let uuid = UUID(uuidString: idString) else { continue }
                        let descriptor = FetchDescriptor<Child>(predicate: #Predicate { $0.id == uuid })
                        if let child = try? modelContext.fetch(descriptor).first {
                            child.room = room
                        }
                    }
                    return true
                }
            }
            .padding(AppSpacing.md)
        }
        .background(Color.nurseryBackground)
        .navigationTitle(room.name)
    }
}

// MARK: - Move to Room Button

private struct MoveToRoomButton: View {
    let child: Child
    let currentRoom: Room
    @Query(sort: \Room.name) private var allRooms: [Room]

    var otherRooms: [Room] { allRooms.filter { $0.id != currentRoom.id } }

    var body: some View {
        Menu {
            ForEach(otherRooms) { room in
                Button {
                    child.room = room
                } label: {
                    Label("Move to \(room.name)", systemImage: "arrow.right.circle")
                }
            }
        } label: {
            Image(systemName: "arrow.right.circle")
                .font(.title3)
                .foregroundStyle(Color.nurseryPrimary)
                .padding(AppSpacing.sm)
        }
        .buttonStyle(.plain)
    }
}
