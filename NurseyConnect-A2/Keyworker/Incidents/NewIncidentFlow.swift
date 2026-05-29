//
//  NewIncidentFlow.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//


import SwiftUI
import SwiftData

// MARK: - Draft struct (plain, not @Model)

struct IncidentReportDraft {
    var selectedChild: Child?        = nil
    var category: IncidentCategory   = .bump
    var severity: IncidentSeverity   = .minor
    var incidentDate: Date           = .now
    var incidentTime: Date           = .now
    var location: String             = ""
    var descriptionOfIncident: String = ""
    var injuryDescription: String    = ""
    var immediateActionTaken: String = ""
    var witnessNames: [String]       = []
    var bodyMapMarks: [BodyMapMark]  = []
}

// MARK: - NewIncidentFlow

struct NewIncidentFlow: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \IncidentReport.incidentDate, order: .reverse)
    private var allReports: [IncidentReport]

    @State private var currentStep = 1
    @State private var draft = IncidentReportDraft()

    let totalSteps = 4

    private var stepIsValid: Bool {
        switch currentStep {
        case 1: return draft.selectedChild != nil && !draft.location.trimmingCharacters(in: .whitespaces).isEmpty
        case 2: return !draft.descriptionOfIncident.trimmingCharacters(in: .whitespaces).isEmpty
                     && !draft.immediateActionTaken.trimmingCharacters(in: .whitespaces).isEmpty
        case 3: return true
        case 4: return true
        default: return false
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: Progress bar
                VStack(spacing: AppSpacing.xs) {
                    ProgressView(value: Double(currentStep), total: Double(totalSteps))
                        .tint(Color.nurseryPrimary)
                        .padding(.horizontal, AppSpacing.md)

                    Text("Step \(currentStep) of \(totalSteps)")
                        .font(.bodySmall)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.xs)

                Divider()

                // MARK: Step content
                Group {
                    switch currentStep {
                    case 1:
                        IncidentStep1BasicInfo(draft: $draft)
                    case 2:
                        IncidentStep2Description(draft: $draft)
                    case 3:
                        IncidentStep3BodyMap(draft: $draft)
                    case 4:
                        IncidentStep4Review(draft: draft)
                    default:
                        EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.easeInOut(duration: 0.25), value: currentStep)

                Divider()

                // MARK: Navigation buttons
                HStack {
                    if currentStep > 1 {
                        Button {
                            withAnimation { currentStep -= 1 }
                        } label: {
                            Label("Back", systemImage: "chevron.left")
                        }
                        .buttonStyle(.bordered)
                        .tint(Color.nurseryPrimary)
                    }

                    Spacer()

                    if currentStep < totalSteps {
                        Button {
                            withAnimation { currentStep += 1 }
                        } label: {
                            HStack {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.nurseryPrimary)
                        .disabled(!stepIsValid)
                    } else {
                        Button {
                            submitDraft()
                        } label: {
                            Label("Submit for Review", systemImage: "paperplane.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.nurseryPrimary)
                        .disabled(!stepIsValid)
                    }
                }
                .padding(AppSpacing.md)
            }
            .navigationTitle("New Incident Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationCornerRadius(20)
    }

    // MARK: - Submit

    private func submitDraft() {
        let ref = generateRef(date: draft.incidentDate, existingCount: allReports.count)
        let report = IncidentReport(
            referenceNumber: ref,
            category: draft.category,
            severity: draft.severity,
            status: .pendingReview,
            incidentDate: draft.incidentDate,
            location: draft.location,
            descriptionOfIncident: draft.descriptionOfIncident,
            immediateActionTaken: draft.immediateActionTaken,
            reportedByName: SampleData.keyworkerName,
            child: draft.selectedChild
        )
        report.injuryDescription = draft.injuryDescription
        report.witnessNames      = draft.witnessNames
        report.updateBodyMapMarks(draft.bodyMapMarks)
        modelContext.insert(report)
        dismiss()
    }
}

#Preview {
    NewIncidentFlow()
        .modelContainer(SampleData.previewContainer)
}
