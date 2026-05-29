//
//  EntryTypePicker.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI

struct EntryTypePicker: View {
    @Binding var selectedType: DiaryEntryType?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(DiaryEntryType.allCases) { type in
                    Button {
                        selectedType = type
                        dismiss()
                    } label: {
                        HStack(spacing: AppSpacing.md) {
                            Image(systemName: type.systemImage)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(type.color)
                                .frame(width: 40, height: 40)
                                .background(type.color.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            Text(type.rawValue).font(.cardTitle).foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right").font(.bodySmall).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, AppSpacing.xs)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Add Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
        .presentationDetents([.medium])
        .presentationCornerRadius(20)
    }
}
