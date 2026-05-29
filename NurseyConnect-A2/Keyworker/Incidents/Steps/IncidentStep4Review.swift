//
//  IncidentStep4Review.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import SwiftData

struct IncidentStep4Review: View {
    let draft: IncidentReportDraft

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {

                // MARK: Header banner
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.nurseryPrimary)
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Ready to submit")
                            .font(.cardTitle)
                        Text("Please review all details before submitting.")
                            .font(.bodySmall)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(AppSpacing.md)
                .background(Color.nurseryPrimary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // MARK: Incident details
                GroupBox {
                    VStack(spacing: AppSpacing.sm) {
                        reviewRow("Child",    draft.selectedChild?.fullName ?? "—")
                        Divider()
                        reviewRow("Category", draft.category.rawValue)
                        Divider()
                        reviewRow("Severity", draft.severity.rawValue)
                        Divider()
                        reviewRow("Date",     draft.incidentDate.formatted(date: .long, time: .omitted))
                        Divider()
                        reviewRow("Time",     draft.incidentTime.formatted(date: .omitted, time: .shortened))
                        Divider()
                        reviewRow("Location", draft.location.isEmpty ? "—" : draft.location)
                    }
                } label: {
                    Label("Incident Details", systemImage: "doc.text")
                        .font(.sectionHead)
                }

                // MARK: Description
                GroupBox {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text(draft.descriptionOfIncident.isEmpty ? "—" : draft.descriptionOfIncident)
                            .font(.bodySmall)
                            .foregroundStyle(.primary)

                        if !draft.injuryDescription.isEmpty {
                            Divider()
                            Text("Injury / Observation")
                                .font(.sectionHead)
                            Text(draft.injuryDescription)
                                .font(.bodySmall)
                        }

                        Divider()
                        Text("Immediate Action")
                            .font(.sectionHead)
                        Text(draft.immediateActionTaken.isEmpty ? "—" : draft.immediateActionTaken)
                            .font(.bodySmall)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } label: {
                    Label("Description", systemImage: "text.alignleft")
                        .font(.sectionHead)
                }

                // MARK: Witnesses
                if !draft.witnessNames.isEmpty {
                    GroupBox {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            ForEach(draft.witnessNames, id: \.self) { name in
                                HStack(spacing: AppSpacing.sm) {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(.secondary)
                                    Text(name)
                                        .font(.bodySmall)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } label: {
                        Label("Witnesses", systemImage: "person.2")
                            .font(.sectionHead)
                    }
                }

                // MARK: Body map
                GroupBox {
                    if draft.bodyMapMarks.isEmpty {
                        Text("No marks added")
                            .font(.bodySmall)
                            .foregroundStyle(.secondary)
                    } else {
                        BodyMapView(marks: .constant(draft.bodyMapMarks), isEditable: false)
                    }
                } label: {
                    Label("Body Map", systemImage: "figure.stand")
                        .font(.sectionHead)
                }

                // MARK: Legal notice
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "lock.shield.fill")
                        .foregroundStyle(.secondary)
                    Text("This report will be submitted for manager review in accordance with EYFS statutory requirements. Parents will be notified once approved.")
                        .font(.bodySmall)
                        .foregroundStyle(.secondary)
                }
                .padding(AppSpacing.md)
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(AppSpacing.md)
        }
    }

    private func reviewRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.bodySmall)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.bodySmall)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    var draft = IncidentReportDraft()
    draft.descriptionOfIncident  = "Child tripped near the sandpit."
    draft.immediateActionTaken   = "Applied cold compress."
    draft.witnessNames           = ["Rachel Green"]
    draft.location               = "Outdoor play area"
    return NavigationStack {
        IncidentStep4Review(draft: draft)
    }
    .modelContainer(SampleData.previewContainer)
}
