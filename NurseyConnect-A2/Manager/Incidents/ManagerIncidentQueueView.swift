//
//  ManagerIncidentQueueView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import SwiftData

struct ManagerIncidentQueueView: View {
    @Query(sort: \IncidentReport.incidentDate, order: .reverse) private var reports: [IncidentReport]
    @Binding var selectedReport: IncidentReport?
    @State private var statusFilter: IncidentStatus? = .pendingReview
    @State private var showingNewIncident = false

    private var filtered: [IncidentReport] {
        guard let filter = statusFilter else { return reports }
        return reports.filter { $0.status == filter }
    }

    var body: some View {
        Group {
            if filtered.isEmpty {
                ContentUnavailableView(
                    statusFilter == nil ? "No Incidents" : "No \(statusFilter!.rawValue) Incidents",
                    systemImage: "checkmark.shield",
                    description: Text(statusFilter == nil ? "No incident reports filed." : "No incidents with this status.")
                )
            } else {
                List(filtered, selection: $selectedReport) { report in
                    IncidentRowView(report: report)
                        .listRowBackground(Color.nurseryCard)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Incidents")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Button("All")                    { statusFilter = nil }
                    Button("Pending Review")         { statusFilter = .pendingReview }
                    Button("Reviewed & Approved")    { statusFilter = .reviewedApproved }
                    Button("Parent Notified")        { statusFilter = .parentNotified }
                    Button("Closed")                 { statusFilter = .closed }
                } label: {
                    Label(statusFilter?.rawValue ?? "All", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingNewIncident = true } label: { Label("New", systemImage: "plus") }
                    .keyboardShortcut("n", modifiers: .command)
            }
        }
        .background(Color.nurseryBackground)
        .fullScreenCover(isPresented: $showingNewIncident) { NewIncidentFlow() }
    }
}
