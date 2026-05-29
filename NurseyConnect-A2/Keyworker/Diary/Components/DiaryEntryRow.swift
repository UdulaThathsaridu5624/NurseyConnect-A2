//
//  DiaryEntryRow.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI

struct DiaryEntryRow: View {
    let entry: DiaryEntry

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.md) {
            Image(systemName: entry.entryType.systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(entry.entryType.color)
                .frame(width: 36, height: 36)
                .background(entry.entryType.color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.headline).font(.cardTitle).foregroundStyle(.primary)
                if !entry.subtitle.isEmpty {
                    Text(entry.subtitle).font(.bodySmall).foregroundStyle(entry.entryType.color.opacity(0.8)).lineLimit(1)
                }
                HStack(spacing: AppSpacing.xs) {
                    Text(entry.timestamp, style: .time).font(.bodySmall).foregroundStyle(.secondary)
                    if !entry.notes.isEmpty {
                        Text("·").foregroundStyle(.secondary)
                        Text(entry.notes).font(.bodySmall).foregroundStyle(.secondary).lineLimit(1)
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, AppSpacing.xs)
    }
}
