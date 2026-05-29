//
//  ManagerRootView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import SwiftData

enum ManagerSection: String, CaseIterable, Identifiable {
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
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSection: ManagerSection? = .dashboard
    @State private var selectedRoom: Room?
    @State private var selectedReport: IncidentReport?

    var body: some View {
        NavigationSplitView {
            ManagerSidebarView(
                selection: $selectedSection,
                onExit: { dismiss() }
            )
            .navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 280)
        } content: {
            contentView
                .navigationSplitViewColumnWidth(min: 300, ideal: 380, max: 460)
        } detail: {
            detailView
        }
        .navigationSplitViewStyle(.balanced)
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedSection {
        case .dashboard:
            ManagerDashboardView()
        case .rooms:
            RoomsListView(selectedRoom: $selectedRoom)
        case .attendance:
            AttendanceView()
        case .analytics:
            AnalyticsView()
        case .incidents:
            ManagerIncidentQueueView(selectedReport: $selectedReport)
        case .reports:
            ReportGeneratorView()
        case .none:
            ContentUnavailableView("Select a section", systemImage: "sidebar.left")
        }
    }

    @ViewBuilder
    private var detailView: some View {
        if let room = selectedRoom, selectedSection == .rooms {
            RoomDetailView(room: room)
        } else if let report = selectedReport, selectedSection == .incidents {
            IncidentDetailView(report: report)
        } else {
            ContentUnavailableView(
                "Nothing Selected",
                systemImage: "sidebar.right",
                description: Text("Select an item from the list.")
            )
        }
    }
}

#Preview {
    ManagerRootView()
        .modelContainer(SampleData.previewContainer)
}
