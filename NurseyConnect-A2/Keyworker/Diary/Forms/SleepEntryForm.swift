//
//  SleepEntryForm.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI; import SwiftData

struct SleepEntryForm: View {
    let child: Child
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var sleepStart    = Date.now
    @State private var sleepEnd      = Date.now.addingTimeInterval(3600)
    @State private var sleepPosition = SleepPosition.back
    @State private var notes         = ""
    private var durationMinutes: Int { max(0, Int(sleepEnd.timeIntervalSince(sleepStart) / 60)) }
    private var durationLabel: String {
        if durationMinutes <= 0 { return "—" }
        let h = durationMinutes / 60; let m = durationMinutes % 60
        if h == 0 { return "\(m) min" }; if m == 0 { return "\(h) hr" }; return "\(h) hr \(m) min"
    }
    var body: some View {
        NavigationStack {
            Form {
                Section("Sleep Times") {
                    DatePicker("Start", selection: $sleepStart, displayedComponents: .hourAndMinute).tint(Color.nurseryPrimary)
                    DatePicker("End",   selection: $sleepEnd,   displayedComponents: .hourAndMinute).tint(Color.nurseryPrimary)
                }
                Section { HStack { Text("Duration").foregroundStyle(.secondary); Spacer(); Text(durationLabel).font(.cardTitle).foregroundStyle(durationMinutes > 0 ? Color.nurseryPrimary : .red) } }
                Section("Sleep Position") { Picker("Position", selection: $sleepPosition) { ForEach(SleepPosition.allCases, id: \.self) { Text($0.rawValue) } }.pickerStyle(.segmented) }
                Section("Notes") {
                    TextEditor(text: $notes).frame(minHeight: 60)
                        .overlay(alignment: .topLeading) { if notes.isEmpty { Text("Any observations during sleep...").foregroundStyle(.secondary).padding(.top,8).padding(.leading,4).allowsHitTesting(false) } }
                }
            }
            .navigationTitle("Log Sleep").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.disabled(sleepEnd <= sleepStart).fontWeight(.semibold) }
            }
        }
        .presentationCornerRadius(20)
    }
    private func save() {
        let e = DiaryEntry(entryType: .sleep, timestamp: sleepStart, recordedByName: SampleData.keyworkerName, child: child)
        e.sleepStart = sleepStart; e.sleepEnd = sleepEnd; e.sleepPosition = sleepPosition; e.notes = notes
        modelContext.insert(e); dismiss()
    }
}
