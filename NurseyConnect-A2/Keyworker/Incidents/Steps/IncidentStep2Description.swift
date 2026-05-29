//
//  IncidentStep2Description.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//


import SwiftUI

struct IncidentStep2Description: View {
    @Binding var draft: IncidentReportDraft

    @State private var newWitness = ""

    var body: some View {
        Form {

            // MARK: Incident description
            Section {
                TextEditor(text: $draft.descriptionOfIncident)
                    .frame(minHeight: 100)
                    .accessibilityLabel("Description")
                    .overlay(alignment: .topLeading) {
                        if draft.descriptionOfIncident.isEmpty {
                            Text("Describe what happened, including the sequence of events leading to the incident…")
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                    }
            } header: {
                Text("What happened?")
            } footer: {
                Text("Include where the child was, what they were doing, and exactly how the incident occurred.")
                    .font(.bodySmall)
            }

            // MARK: Injury description
            Section("Injury / Observation") {
                TextEditor(text: $draft.injuryDescription)
                    .frame(minHeight: 80)
                    .overlay(alignment: .topLeading) {
                        if draft.injuryDescription.isEmpty {
                            Text("Describe any visible injuries, marks, or physical observations…")
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                    }
            }

            // MARK: Immediate action
            Section {
                TextEditor(text: $draft.immediateActionTaken)
                    .frame(minHeight: 80)
                    .accessibilityLabel("Immediate action")
                    .overlay(alignment: .topLeading) {
                        if draft.immediateActionTaken.isEmpty {
                            Text("e.g. Applied cold compress, comforted child, called parent…")
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                    }
            } header: {
                Text("Immediate action taken")
            } footer: {
                Text("Required by EYFS — describe first aid or other steps taken immediately after the incident.")
                    .font(.bodySmall)
            }

            // MARK: Witnesses
            Section("Witnesses") {
                if draft.witnessNames.isEmpty {
                    Text("No witnesses added")
                        .foregroundStyle(.secondary)
                        .font(.bodySmall)
                } else {
                    ForEach(draft.witnessNames, id: \.self) { name in
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundStyle(.secondary)
                            Text(name)
                        }
                    }
                    .onDelete { draft.witnessNames.remove(atOffsets: $0) }
                }

                HStack {
                    TextField("Add witness name", text: $newWitness)
                    Button("Add") {
                        let trimmed = newWitness.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        draft.witnessNames.append(trimmed)
                        newWitness = ""
                    }
                    .disabled(newWitness.trimmingCharacters(in: .whitespaces).isEmpty)
                    .tint(Color.nurseryPrimary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        Form {
            IncidentStep2Description(draft: .constant(IncidentReportDraft()))
        }
    }
}
