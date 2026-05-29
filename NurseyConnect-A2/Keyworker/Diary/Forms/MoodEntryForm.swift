//
//  MoodEntryForm.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//
import SwiftUI; import SwiftData

struct MoodEntryForm: View {
    let child: Child
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMood = MoodLevel.happy
    @State private var moodContext  = "On arrival"
    @State private var timestamp    = Date.now
    @State private var notes        = ""
    let contexts = ["On arrival","After nap","During session","At collection","Other"]
    var body: some View {
        NavigationStack {
            Form {
                Section("How is \(child.preferredName) feeling?") {
                    HStack(spacing: 0) {
                        ForEach(MoodLevel.allCases, id: \.self) { mood in
                            VStack(spacing: AppSpacing.xs) {
                                Text(mood.emoji).font(.system(size: 36))
                                    .padding(AppSpacing.xs)
                                    .background(Circle().strokeBorder(selectedMood == mood ? mood.color : Color.clear, lineWidth: 3))
                                    .scaleEffect(selectedMood == mood ? 1.15 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMood)
                                Text(mood.rawValue).font(.system(size: 9, weight: .medium, design: .rounded))
                                    .foregroundStyle(selectedMood == mood ? mood.color : .secondary)
                                    .multilineTextAlignment(.center).lineLimit(2).fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity)
                            .onTapGesture { selectedMood = mood }
                        }
                    }
                    .padding(.vertical, AppSpacing.sm)
                }
                Section("When") {
                    Picker("Context", selection: $moodContext) { ForEach(contexts, id: \.self) { Text($0) } }.pickerStyle(.menu).tint(Color.nurseryPrimary)
                    DatePicker("Time", selection: $timestamp, displayedComponents: .hourAndMinute).tint(Color.nurseryPrimary)
                }
                Section("Observations") {
                    TextEditor(text: $notes).frame(minHeight: 80)
                        .overlay(alignment: .topLeading) { if notes.isEmpty { Text("Describe \(child.preferredName)'s mood and behaviour...").foregroundStyle(.secondary).padding(.top,8).padding(.leading,4).allowsHitTesting(false) } }
                }
            }
            .navigationTitle("Wellbeing Check-In").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.fontWeight(.semibold) }
            }
        }
        .presentationCornerRadius(20)
    }
    private func save() {
        let e = DiaryEntry(entryType: .mood, timestamp: timestamp, recordedByName: SampleData.keyworkerName, child: child)
        e.moodLevel = selectedMood; e.moodContext = moodContext; e.notes = notes
        modelContext.insert(e); dismiss()
    }
}
