//
//  MealEntryForm.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI; import SwiftData

struct MealEntryForm: View {
    let child: Child
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var mealName      = "Lunch"
    @State private var mealAmount    = MealAmount.most
    @State private var fluidAmountMl = 150
    @State private var fluidType     = "Water"
    @State private var timestamp     = Date.now
    @State private var notes         = ""
    let mealNames  = ["Breakfast","Morning Snack","Lunch","Afternoon Snack","Tea"]
    let fluidTypes = ["Water","Milk","Diluted Juice","Other"]
    var body: some View {
        NavigationStack {
            Form {
                Section("Meal") {
                    Picker("Meal", selection: $mealName) { ForEach(mealNames, id: \.self) { Text($0) } }.pickerStyle(.menu).tint(Color.nurseryPrimary)
                    DatePicker("Time", selection: $timestamp, displayedComponents: .hourAndMinute).tint(Color.nurseryPrimary)
                }
                Section("How much did \(child.preferredName) eat?") {
                    HStack(spacing: AppSpacing.sm) { ForEach(MealAmount.allCases, id: \.self) { amount in Button(amount.rawValue) { mealAmount = amount }.buttonStyle(AmountButtonStyle(isSelected: mealAmount == amount)) } }
                        .frame(maxWidth: .infinity).padding(.vertical, AppSpacing.xs)
                }
                Section("Fluid Intake") {
                    Picker("Type", selection: $fluidType) { ForEach(fluidTypes, id: \.self) { Text($0) } }.pickerStyle(.segmented)
                    Stepper("\(fluidAmountMl) ml", value: $fluidAmountMl, in: 0...500, step: 10)
                }
                if !child.allergies.isEmpty {
                    Section { HStack(spacing: AppSpacing.sm) { Image(systemName: "allergens").foregroundStyle(Color.nurseryAccent); Text("Allergy alert: \(child.allergies.joined(separator: ", "))").font(.bodySmall).foregroundStyle(Color.nurseryAccent) } }
                }
                Section("Notes") {
                    TextEditor(text: $notes).frame(minHeight: 60)
                        .overlay(alignment: .topLeading) { if notes.isEmpty { Text("Any observations...").foregroundStyle(.secondary).padding(.top,8).padding(.leading,4).allowsHitTesting(false) } }
                }
            }
            .navigationTitle("Log Meal").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.fontWeight(.semibold) }
            }
        }
        .presentationCornerRadius(20)
        .interactiveDismissDisabled()
    }
    private func save() {
        let e = DiaryEntry(entryType: .meal, timestamp: timestamp, recordedByName: SampleData.keyworkerName, child: child)
        e.mealName = mealName; e.mealAmount = mealAmount; e.fluidAmountMl = fluidAmountMl; e.fluidType = fluidType; e.notes = notes
        modelContext.insert(e); dismiss()
    }
}
