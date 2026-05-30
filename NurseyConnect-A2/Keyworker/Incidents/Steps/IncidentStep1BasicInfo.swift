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

    private var activeChildren: [Child] { children.filter { $0.isActive } }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {

                // Child
                sectionCard("Child") {
                    if children.isEmpty {
                        Text("No children assigned").foregroundStyle(.secondary).padding(AppSpacing.sm)
                    } else {
                        ForEach(activeChildren) { child in
                            selectRow("\(child.preferredName) · \(child.roomName)",
                                      selected: draft.selectedChild?.id == child.id) {
                                draft.selectedChild = child
                            }
                            if child.id != activeChildren.last?.id { Divider().padding(.leading, AppSpacing.md) }
                        }
                    }
                }

                // Category
                sectionCard("Incident Category") {
                    ForEach(IncidentCategory.allCases, id: \.self) { cat in
                        selectRowLabel(cat.rawValue, icon: cat.systemImage,
                                       selected: draft.category == cat) {
                            draft.category = cat
                        }
                        if cat != IncidentCategory.allCases.last { Divider().padding(.leading, AppSpacing.md) }
                    }
                }

                // Severity
                sectionCard("Severity") {
                    Picker("Severity", selection: $draft.severity) {
                        ForEach(IncidentSeverity.allCases, id: \.self) { sev in
                            Text(sev.rawValue).tag(sev)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(AppSpacing.md)
                }

                // Date & time
                sectionCard("When") {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Date").foregroundStyle(.secondary)
                            Spacer()
                            DatePicker("", selection: $draft.incidentDate, displayedComponents: .date)
                                .labelsHidden().tint(Color.nurseryPrimary)
                        }
                        .padding(AppSpacing.md)
                        Divider().padding(.leading, AppSpacing.md)
                        HStack {
                            Text("Time").foregroundStyle(.secondary)
                            Spacer()
                            DatePicker("", selection: $draft.incidentTime, displayedComponents: .hourAndMinute)
                                .labelsHidden().tint(Color.nurseryPrimary)
                        }
                        .padding(AppSpacing.md)
                    }
                }

                // Location
                sectionCard("Location") {
                    TextField("e.g. Outdoor play area, Sunshine Room…", text: $draft.location)
                        .padding(AppSpacing.md)
                }
            }
            .padding(AppSpacing.md)
        }
    }

    private func sectionCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.sectionHead)
                .foregroundStyle(.secondary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.xs)
            VStack(spacing: 0) { content() }
                .background(Color.nurseryCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func selectRow(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title).foregroundStyle(.primary)
                Spacer()
                if selected {
                    Image(systemName: "checkmark").foregroundStyle(Color.nurseryPrimary).fontWeight(.semibold)
                }
            }
            .padding(AppSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func selectRowLabel(_ title: String, icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: icon).foregroundStyle(.primary)
                Spacer()
                if selected {
                    Image(systemName: "checkmark").foregroundStyle(Color.nurseryPrimary).fontWeight(.semibold)
                }
            }
            .padding(AppSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
