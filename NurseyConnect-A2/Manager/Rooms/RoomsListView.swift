//
//  RoomsListView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import SwiftData

struct RoomsListView: View {
    @Query(sort: \Room.name) private var rooms: [Room]
    @Binding var selectedRoom: Room?

    var body: some View {
        Group {
            if rooms.isEmpty {
                ContentUnavailableView("No Rooms", systemImage: "door.left.hand.open",
                    description: Text("No rooms have been configured."))
            } else {
                List(rooms, selection: $selectedRoom) { room in
                    HStack(spacing: AppSpacing.md) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: room.colorHex))
                            .frame(width: 6, height: 44)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(room.name).font(.cardTitle)
                            Text(room.ageGroup.rawValue).font(.bodySmall).foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            Text("\(room.activeChildrenCount) children")
                                .font(.bodySmall).foregroundStyle(.secondary)
                            RatioBadge(room: room)
                        }
                    }
                    .padding(.vertical, AppSpacing.xs)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Rooms")
    }
}
