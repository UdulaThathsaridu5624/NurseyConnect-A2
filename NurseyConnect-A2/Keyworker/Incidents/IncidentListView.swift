//
//  IncidentListView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

//  IncidentListView.swift — NurseyConnect-A2
import SwiftUI; import SwiftData

struct IncidentListView: View {
    @Query(sort: \IncidentReport.incidentDate, order: .reverse) private var reports: [IncidentReport]
    @State private var statusFilter: IncidentStatus? = nil
    @State private var showingNewIncident = false
    @State private var selectedReport: IncidentReport?

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
                    description: Text(statusFilter == nil ? "No incident reports have been filed." : "No incidents with this status.")
                )
            } else {
                List(filtered) { report in
                    IncidentRowView(report: report)
                        .listRowBackground(Color.nurseryCard)
                        .onTapGesture { selectedReport = report }
                }
                .listStyle(.insetGrouped).scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Incidents").navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Button("All") { statusFilter = nil }; Divider()
                    ForEach(IncidentStatus.allCases, id: \.self) { s in Button(s.rawValue) { statusFilter = s } }
                } label: { Label(statusFilter?.rawValue ?? "All", systemImage: "line.3.horizontal.decrease.circle") }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingNewIncident = true } label: { Label("New Incident", systemImage: "plus") }
                    .keyboardShortcut("n", modifiers: .command)
            }
        }
        .background(Color.nurseryBackground)
        .fullScreenCover(isPresented: $showingNewIncident) { NewIncidentFlow() }
        .navigationDestination(item: $selectedReport) { IncidentDetailView(report: $0) }
    }
}

#Preview {
    NavigationStack { IncidentListView() }.modelContainer(SampleData.previewContainer)
}
