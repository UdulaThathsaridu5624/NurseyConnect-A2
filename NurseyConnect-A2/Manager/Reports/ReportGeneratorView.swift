//
//  ReportGeneratorView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import SwiftData

enum ReportType: String, CaseIterable, Identifiable {
    case incident   = "Incident Report"
    case diary      = "Daily Diary Summary"
    case attendance = "Attendance Report"
    var id: String { rawValue }
}

struct ReportGeneratorView: View {
    @Query(sort: \IncidentReport.incidentDate, order: .reverse) private var reports: [IncidentReport]
    @Query(sort: \Child.fullName)  private var children: [Child]
    @Query(sort: \Room.name)       private var rooms: [Room]

    @State private var selectedType:       ReportType = .incident
    @State private var selectedIncidentID: UUID?
    @State private var selectedChildID:    UUID?
    @State private var selectedRoomID:     UUID?
    @State private var reportDate:         Date = .now
    @State private var generatedPDF:       Data?
    @State private var showPreview         = false

    private var selectedIncident: IncidentReport? { reports.first { $0.id == selectedIncidentID } }
    private var selectedChild:    Child?           { children.first { $0.id == selectedChildID } }
    private var selectedRoom:     Room?            { rooms.first   { $0.id == selectedRoomID } }

    private var canGenerate: Bool {
        switch selectedType {
        case .incident:   return selectedIncident != nil
        case .diary:      return selectedChild != nil
        case .attendance: return selectedRoom != nil
        }
    }

    var body: some View {
        Form {
            Section("Report Type") {
                Picker("Type", selection: $selectedType) {
                    ForEach(ReportType.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
            }

            switch selectedType {
            case .incident:
                Section("Select Incident") {
                    if reports.isEmpty {
                        Text("No incident reports available").foregroundStyle(.secondary)
                    } else {
                        ForEach(reports) { r in
                            selectableRow(
                                title: "\(r.referenceNumber) · \(r.child?.preferredName ?? "—")",
                                isSelected: selectedIncidentID == r.id
                            ) { selectedIncidentID = r.id }
                        }
                    }
                }

            case .diary:
                Section("Select Child") {
                    ForEach(children.filter { $0.isActive }) { c in
                        selectableRow(title: c.preferredName, isSelected: selectedChildID == c.id) {
                            selectedChildID = c.id
                        }
                    }
                }
                Section("Date") {
                    DatePicker("Date", selection: $reportDate, displayedComponents: .date)
                        .tint(Color.nurseryPrimary)
                }

            case .attendance:
                Section("Select Room") {
                    ForEach(rooms) { r in
                        selectableRow(title: r.name, isSelected: selectedRoomID == r.id) {
                            selectedRoomID = r.id
                        }
                    }
                }
                Section("Month") {
                    DatePicker("Month", selection: $reportDate, displayedComponents: .date)
                        .tint(Color.nurseryPrimary)
                }
            }

            Section {
                Button {
                    generatedPDF = generatePDF()
                    showPreview  = generatedPDF != nil
                } label: {
                    Label("Generate PDF", systemImage: "doc.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.nurseryPrimary)
                .disabled(!canGenerate)
            }
        }
        .navigationTitle("Report Generator")
        .background(Color.nurseryBackground)
        .sheet(isPresented: $showPreview) {
            if let data = generatedPDF {
                PDFPreviewSheet(pdfData: data, reportTitle: selectedType.rawValue)
            }
        }
        .keyboardShortcut("p", modifiers: .command)
    }

    private func selectableRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title).foregroundStyle(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.nurseryPrimary)
                        .fontWeight(.semibold)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func generatePDF() -> Data? {
        switch selectedType {
        case .incident:
            guard let r = selectedIncident else { return nil }
            return PDFReportGenerator.generateIncidentPDF(report: r)
        case .diary:
            guard let c = selectedChild else { return nil }
            return PDFReportGenerator.generateDailyDiaryPDF(child: c, date: reportDate)
        case .attendance:
            guard let r = selectedRoom else { return nil }
            return PDFReportGenerator.generateAttendancePDF(room: r, month: reportDate)
        }
    }
}

#Preview {
    NavigationStack { ReportGeneratorView() }
        .modelContainer(SampleData.previewContainer)
}
