//
//  AttendanceView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import SwiftData

struct AttendanceView: View {
    @Query(sort: \Child.fullName) private var children: [Child]
    @Query private var allAttendance: [AttendanceRecord]
    @Environment(\.modelContext) private var modelContext

    @State private var selectedDate: Date = .now
    @State private var selectedRoom: Room? = nil
    @Query(sort: \Room.name) private var rooms: [Room]

    private var today: Date { Calendar.current.startOfDay(for: selectedDate) }

    private var activeChildren: [Child] {
        let all = children.filter { $0.isActive }
        if let room = selectedRoom { return all.filter { $0.room?.id == room.id } }
        return all
    }

    private func record(for child: Child) -> AttendanceRecord? {
        allAttendance.first { $0.child?.id == child.id && $0.date == today }
    }

    private var presentCount: Int {
        activeChildren.filter { record(for: $0)?.isPresent == true }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            // Controls bar — two rows to avoid cramping
            VStack(spacing: AppSpacing.sm) {
                HStack {
                    Label("Date", systemImage: "calendar")
                        .font(.bodySmall)
                        .foregroundStyle(.secondary)
                    Spacer()
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .tint(Color.nurseryPrimary)
                }
                HStack {
                    Label("Room", systemImage: "door.left.hand.open")
                        .font(.bodySmall)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Picker("", selection: $selectedRoom) {
                        Text("All Rooms").tag(Optional<Room>.none)
                        ForEach(rooms) { room in Text(room.name).tag(Optional(room)) }
                    }
                    .pickerStyle(.menu)
                    .tint(Color.nurseryPrimary)
                }
                HStack {
                    Text("\(presentCount) of \(activeChildren.count) present")
                        .font(.sectionHead)
                        .foregroundStyle(Color.nurseryPrimary)
                    Spacer()
                }
            }
            .padding(AppSpacing.md)
            .background(Color.nurseryCard)

            Divider()

            if activeChildren.isEmpty {
                ContentUnavailableView("No Children", systemImage: "person.slash",
                    description: Text("No active children found."))
            } else {
                List {
                    ForEach(activeChildren) { child in
                        AttendanceRowView(
                            child: child,
                            record: record(for: child),
                            onCheckIn: { checkIn(child: child) },
                            onCheckOut: { checkOut(child: child) }
                        )
                        .listRowBackground(Color.nurseryCard)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .background(Color.nurseryBackground)
        .navigationTitle("Attendance")
    }

    private func checkIn(child: Child) {
        let rec = AttendanceRecord(child: child, date: selectedDate)
        rec.checkInTime  = .now
        rec.checkedInBy  = "Mrs T. Williams"
        modelContext.insert(rec)
    }

    private func checkOut(child: Child) {
        guard let rec = record(for: child) else { return }
        rec.checkOutTime = .now
        rec.checkedOutBy = "Mrs T. Williams"
    }
}

#Preview {
    NavigationStack { AttendanceView() }
        .modelContainer(SampleData.previewContainer)
}
