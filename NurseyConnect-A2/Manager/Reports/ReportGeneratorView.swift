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

    @State private var selectedType:     ReportType     = .incident
    @State private var selectedIncident: IncidentReport?
    @State private var selectedChild:    Child?
    @State private var selectedRoom:     Room?
    @State private var reportDate:       Date           = .now
    @State private var generatedPDF:     Data?
    @State private var showPreview              = false

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
                        Picker("Incident", selection: $selectedIncident) {
                            Text("Choose…").tag(Optional<IncidentReport>.none)
                            ForEach(reports) { r in
                                Text("\(r.referenceNumber) · \(r.child?.preferredName ?? "—")").tag(Optional(r))
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                }

            case .diary:
                Section("Select Child & Date") {
                    Picker("Child", selection: $selectedChild) {
                        Text("Choose…").tag(Optional<Child>.none)
                        ForEach(children.filter { $0.isActive }) { c in Text(c.preferredName).tag(Optional(c)) }
                    }
                    .pickerStyle(.navigationLink)
                    DatePicker("Date", selection: $reportDate, displayedComponents: .date)
                        .tint(Color.nurseryPrimary)
                }

            case .attendance:
                Section("Select Room & Month") {
                    Picker("Room", selection: $selectedRoom) {
                        Text("Choose…").tag(Optional<Room>.none)
                        ForEach(rooms) { r in Text(r.name).tag(Optional(r)) }
                    }
                    .pickerStyle(.navigationLink)
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
