//
//  IncidentDetailView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

//  IncidentDetailView.swift — NurseyConnect-A2
import SwiftUI; import SwiftData

struct IncidentDetailView: View {
    @Bindable var report: IncidentReport
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                // Status header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(report.referenceNumber).font(.cardTitle)
                        Text(report.incidentDate, style: .date).font(.bodySmall).foregroundStyle(.secondary)
                        Text("Reported by \(report.reportedByName)").font(.bodySmall).foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                        StatusBadge(status: report.status)
                        Text(report.severity.rawValue).font(.bodySmall.bold()).foregroundStyle(report.severity.color)
                    }
                }
                .padding(AppSpacing.md).background(Color.nurseryCard)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)

                // Details
                GroupBox { VStack(spacing: AppSpacing.sm) {
                    detailRow("Child",    report.child?.fullName ?? "—"); Divider()
                    detailRow("Category", report.category.rawValue);      Divider()
                    detailRow("Location", report.location);               Divider()
                    detailRow("Time",     report.incidentDate.formatted(date: .omitted, time: .shortened))
                }} label: { Label("Incident Details", systemImage: "doc.text").font(.sectionHead) }

                // Description
                GroupBox {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text(report.descriptionOfIncident).font(.bodySmall)
                        if !report.injuryDescription.isEmpty {
                            Divider(); Text("Injury / Observation").font(.sectionHead); Text(report.injuryDescription).font(.bodySmall)
                        }
                        Divider(); Text("Immediate Action Taken").font(.sectionHead); Text(report.immediateActionTaken).font(.bodySmall)
                        if !report.witnessNames.isEmpty {
                            Divider(); Text("Witnesses").font(.sectionHead)
                            ForEach(report.witnessNames, id: \.self) { Label($0, systemImage: "person.fill").font(.bodySmall) }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } label: { Label("Description", systemImage: "text.alignleft").font(.sectionHead) }

                // Body map
                GroupBox {
                    if report.bodyMapMarks.isEmpty {
                        Text("No body map marks recorded").font(.bodySmall).foregroundStyle(.secondary)
                    } else {
                        BodyMapView(marks: .constant(report.bodyMapMarks), isEditable: false)
                    }
                } label: { Label("Body Map", systemImage: "figure.stand").font(.sectionHead) }

                // Manager review
                GroupBox {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        if let reviewer = report.reviewedByName, let reviewedAt = report.reviewedAt {
                            detailRow("Reviewed by", reviewer); Divider()
                            detailRow("Reviewed at", reviewedAt.formatted(date: .abbreviated, time: .shortened))
                            if let notes = report.managerNotes, !notes.isEmpty { Divider(); Text("Manager Notes").font(.sectionHead); Text(notes).font(.bodySmall) }
                        } else if report.status == .pendingReview {
                            HStack(spacing: AppSpacing.sm) { ProgressView(); Text("Awaiting manager review").font(.bodySmall).foregroundStyle(.secondary) }
                            TextField("Add manager notes (optional)", text: Binding(get: { report.managerNotes ?? "" }, set: { report.managerNotes = $0.isEmpty ? nil : $0 }), axis: .vertical)
                                .font(.bodySmall).lineLimit(3...6)
                        } else { Text("Not yet reviewed").font(.bodySmall).foregroundStyle(.secondary) }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } label: { Label("Manager Review", systemImage: "checkmark.seal").font(.sectionHead) }

                // Parent notification
                GroupBox {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Toggle(isOn: Binding(
                            get: { report.parentNotifiedAt != nil },
                            set: { if $0 { report.parentNotifiedAt = .now } else { report.parentNotifiedAt = nil } }
                        )) { Label("Parent / Carer Notified", systemImage: "bell.fill") }.tint(Color.nurseryPrimary)
                        if report.parentNotifiedAt != nil {
                            Divider()
                            Picker("Method", selection: Binding(get: { report.parentNotificationMethod ?? "In Person" }, set: { report.parentNotificationMethod = $0 })) {
                                ForEach(["In Person","Phone Call","Written Note"], id: \.self) { Text($0) }
                            }.pickerStyle(.segmented)
                            Toggle(isOn: $report.parentSignatureObtained) { Text("Signature / Acknowledgement Obtained").font(.bodySmall) }.tint(Color.nurseryPrimary)
                            if let t = report.parentNotifiedAt { Text("Notified: \(t.formatted(date: .abbreviated, time: .shortened))").font(.bodySmall).foregroundStyle(.secondary) }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } label: { Label("Parent Notification", systemImage: "person.2.fill").font(.sectionHead) }
            }
            .padding(AppSpacing.md)
        }
        .background(Color.nurseryBackground)
        .navigationTitle("Incident Report").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let next = report.nextStatuses.first {
                    Button {
                        withAnimation(.easeIn(duration: 0.2)) { advanceTo(next) }
                    } label: {
                        Label("Mark: \(next.rawValue)", systemImage: statusIcon(for: next))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.nurseryPrimary)
                }
            }
        }
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack { Text(label).font(.bodySmall).foregroundStyle(.secondary); Spacer(); Text(value).font(.bodySmall).fontWeight(.medium).multilineTextAlignment(.trailing) }
    }
    private func advanceTo(_ status: IncidentStatus) {
        report.status = status
        if status == .reviewedApproved { report.reviewedAt = .now; report.reviewedByName = "Manager" }
    }
    private func statusIcon(for status: IncidentStatus) -> String {
        switch status {
        case .pendingReview: return "clock"; case .reviewedApproved: return "checkmark.seal"
        case .parentNotified: return "bell"; case .closed: return "archivebox"; default: return "circle"
        }
    }
}
