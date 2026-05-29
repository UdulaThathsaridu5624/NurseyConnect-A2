//
//  ManagerDashboardView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import SwiftData

struct ManagerDashboardView: View {
    @Query private var children: [Child]
    @Query private var rooms: [Room]
    @Query private var reports: [IncidentReport]
    @Query private var attendance: [AttendanceRecord]
    @Query private var entries: [DiaryEntry]

    let columns = [GridItem(.adaptive(minimum: 200), spacing: AppSpacing.md)]

    private var today: Date { Calendar.current.startOfDay(for: .now) }

    private var presentCount: Int {
        attendance.filter { $0.date == today && $0.isPresent }.count
    }

    private var pendingIncidents: Int {
        reports.filter { $0.status == .pendingReview }.count
    }

    private var ratioAlerts: Int {
        rooms.filter { !$0.ratioOK }.count
    }

    private var mealsToday: Int {
        entries.filter {
            $0.entryType == .meal &&
            Calendar.current.isDateInToday($0.timestamp)
        }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {

                // Stat cards grid
                LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                    DashboardStatCard(
                        title: "Children Present",
                        value: "\(presentCount)",
                        icon: "person.3.fill",
                        color: .nurseryPrimary,
                        subtitle: "of \(children.filter { $0.isActive }.count) enrolled"
                    )
                    DashboardStatCard(
                        title: "Ratio Alerts",
                        value: "\(ratioAlerts)",
                        icon: "exclamationmark.triangle.fill",
                        color: ratioAlerts > 0 ? .red : .green,
                        subtitle: ratioAlerts > 0 ? "Action required" : "All rooms compliant"
                    )
                    DashboardStatCard(
                        title: "Pending Incidents",
                        value: "\(pendingIncidents)",
                        icon: "bell.badge.fill",
                        color: pendingIncidents > 0 ? .nurseryAccent : .green,
                        subtitle: pendingIncidents > 0 ? "Awaiting review" : "All reviewed"
                    )
                    DashboardStatCard(
                        title: "Meals Logged",
                        value: "\(mealsToday)",
                        icon: "fork.knife",
                        color: .orange,
                        subtitle: "Today"
                    )
                }

                // Room ratio overview
                if !rooms.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Room Status")
                            .font(.sectionHead)
                            .padding(.horizontal, AppSpacing.xs)

                        VStack(spacing: AppSpacing.sm) {
                            ForEach(rooms) { room in
                                HStack {
                                    Circle()
                                        .fill(Color(hex: room.colorHex))
                                        .frame(width: 10, height: 10)
                                    Text(room.name)
                                        .font(.cardTitle)
                                    Spacer()
                                    Text(room.ratioString)
                                        .font(.bodySmall)
                                        .foregroundStyle(.secondary)
                                    RatioBadge(room: room)
                                }
                                .padding(AppSpacing.md)
                                .background(Color.nurseryCard)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
            }
            .padding(AppSpacing.md)
        }
        .background(Color.nurseryBackground)
        .navigationTitle("Dashboard")
    }
}

#Preview {
    NavigationStack { ManagerDashboardView() }
        .modelContainer(SampleData.previewContainer)
}
