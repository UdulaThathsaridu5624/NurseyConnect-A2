//
//  ManagerRootView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import SwiftData

enum ManagerSection: String, CaseIterable, Identifiable, Hashable {
    case dashboard  = "Dashboard"
    case rooms      = "Rooms"
    case attendance = "Attendance"
    case analytics  = "Analytics"
    case incidents  = "Incidents"
    case reports    = "Reports"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .dashboard:  return "square.grid.2x2.fill"
        case .rooms:      return "door.left.hand.open"
        case .attendance: return "person.badge.clock.fill"
        case .analytics:  return "chart.bar.fill"
        case .incidents:  return "exclamationmark.triangle.fill"
        case .reports:    return "doc.text.fill"
        }
    }
}

struct ManagerRootView: View {
    @State private var selectedSection: ManagerSection? = .dashboard

    var body: some View {
        NavigationSplitView {
            ManagerSidebarView(selection: $selectedSection)
                .navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 280)
        } detail: {
            NavigationStack {
                detailContent
            }
        }
        .navigationSplitViewStyle(.balanced)
    }

    @ViewBuilder
    private var detailContent: some View {
        switch selectedSection {
        case .dashboard:
            ManagerDashboardView(onNavigate: { selectedSection = $0 })
        case .rooms:
            RoomsWithDetailView()
        case .attendance:
            AttendanceView()
        case .analytics:
            AnalyticsView()
        case .incidents:
            IncidentsWithDetailView()
        case .reports:
            ReportGeneratorView()
        case .none:
            ContentUnavailableView("Select a section", systemImage: "sidebar.left")
        }
    }
}

// Rooms: list + push detail via NavigationLink
private struct RoomsWithDetailView: View {
    @Query(sort: \Room.name) private var rooms: [Room]

    var body: some View {
        List(rooms) { room in
            NavigationLink(destination: RoomDetailView(room: room)) {
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
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Rooms")
    }
}

// Incidents: Manager reviews & approves (per case study §4.2.2 — does NOT create).
// Filter via chips; tap a row to review/countersign.
private struct IncidentsWithDetailView: View {
    @Query(sort: \IncidentReport.incidentDate, order: .reverse) private var reports: [IncidentReport]
    @State private var statusFilter: IncidentStatus? = nil

    private var filtered: [IncidentReport] {
        guard let f = statusFilter else { return reports }
        return reports.filter { $0.status == f }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    filterChip(title: "All", active: statusFilter == nil) { statusFilter = nil }
                    ForEach(IncidentStatus.allCases, id: \.self) { s in
                        filterChip(title: s.rawValue, active: statusFilter == s) { statusFilter = s }
                    }
                }
                .padding(AppSpacing.md)
            }
            .background(Color.nurseryCard)

            Divider()

            if filtered.isEmpty {
                ContentUnavailableView(
                    statusFilter == nil ? "No Incidents" : "No \(statusFilter!.rawValue) Incidents",
                    systemImage: "checkmark.shield"
                )
            } else {
                List(filtered) { report in
                    NavigationLink(destination: IncidentDetailView(report: report)) {
                        IncidentRowView(report: report)
                    }
                    .listRowBackground(Color.nurseryCard)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Incidents")
        .background(Color.nurseryBackground)
    }

    private func filterChip(title: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(.subheadline, design: .rounded, weight: active ? .bold : .regular))
                .foregroundStyle(active ? .white : .primary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(Capsule().fill(active ? Color.nurseryPrimary : Color.secondary.opacity(0.15)))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ManagerRootView()
        .modelContainer(SampleData.previewContainer)
}
