//
//  IncidentStep1BasicInfo.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import SwiftData

struct IncidentStep1BasicInfo: View {
    @Binding var draft: IncidentReportDraft

    @Query(sort: \Child.fullName)
    private var children: [Child]

    var body: some View {
        Form {
            // MARK: Child
            Section("Child") {
                if children.isEmpty {
                    Text("No children assigned")
                        .foregroundStyle(.secondary)
                } else {
                    Picker("Select child", selection: $draft.selectedChild) {
                        Text("Select a child…").tag(Optional<Child>.none)
                        ForEach(children.filter { $0.isActive }) { child in
                            HStack {
                                Text(child.preferredName)
                                Text("·")
                                Text(child.roomName)
                                    .foregroundStyle(.secondary)
                            }
                            .tag(Optional(child))
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .tint(Color.nurseryPrimary)
                }
            }

            // MARK: Incident type
            Section("Incident Type") {
                Picker("Category", selection: $draft.category) {
                    ForEach(IncidentCategory.allCases, id: \.self) { cat in
                        Label(cat.rawValue, systemImage: cat.systemImage).tag(cat)
                    }
                }
                .pickerStyle(.navigationLink)

                Picker("Severity", selection: $draft.severity) {
                    ForEach(IncidentSeverity.allCases, id: \.self) { sev in
                        HStack {
                            Circle()
                                .fill(sev.color)
                                .frame(width: 10, height: 10)
                            Text(sev.rawValue)
                        }
                        .tag(sev)
                    }
                }
                .pickerStyle(.segmented)
            }

            // MARK: Date & time
            Section("When") {
                DatePicker("Date", selection: $draft.incidentDate,
                           displayedComponents: .date)
                    .tint(Color.nurseryPrimary)

                DatePicker("Time", selection: $draft.incidentTime,
                           displayedComponents: .hourAndMinute)
                    .tint(Color.nurseryPrimary)
            }

            // MARK: Location
            Section("Location") {
                TextField("e.g. Outdoor play area, Sunshine Room…",
                          text: $draft.location)
                    .accessibilityLabel("Location")
            }
        }
    }
}

#Preview {
    NavigationStack {
        Form {
            IncidentStep1BasicInfo(draft: .constant(IncidentReportDraft()))
        }
    }
    .modelContainer(SampleData.previewContainer)
}
