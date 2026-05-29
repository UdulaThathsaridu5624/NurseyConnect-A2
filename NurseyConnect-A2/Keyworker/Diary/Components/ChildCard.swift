//
//  ChildCard.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import SwiftData

struct ChildCard: View {
    let child: Child
    let date: Date
    var index: Int = 0
    @State private var visible = false

    private var entriesForDate: [DiaryEntry] { child.diaryEntries(for: date) }
    private func count(for type: DiaryEntryType) -> Int {
        entriesForDate.filter { $0.entryType == type }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(alignment: .top) {
                Circle().fill(LinearGradient.nurseryAvatar)
                    .frame(width: 48, height: 48)
                    .overlay { Text(child.initials).font(.cardTitle).foregroundStyle(.white) }
                Spacer()
                if !child.allergies.isEmpty {
                    Image(systemName: "allergens").font(.caption).foregroundStyle(Color.nurseryAccent)
                        .padding(AppSpacing.xs)
                        .background(Circle().fill(Color.nurseryAccent.opacity(0.15)))
                }
            }
            Text(child.preferredName).font(.cardTitle).foregroundStyle(.primary).lineLimit(1)
            Text("\(child.age) · \(child.roomName)").font(.bodySmall).foregroundStyle(.secondary).lineLimit(1)
            Divider().padding(.vertical, AppSpacing.xs)
            HStack(spacing: AppSpacing.sm) {
                ForEach(DiaryEntryType.allCases) { type in
                    let n = count(for: type)
                    VStack(spacing: 2) {
                        Image(systemName: type.systemImage).font(.system(size: 12))
                            .foregroundStyle(n > 0 ? type.color : Color.secondary.opacity(0.35))
                        Text(n > 0 ? "\(n)" : "–")
                            .font(.system(size: 10, weight: n > 0 ? .bold : .regular, design: .rounded))
                            .foregroundStyle(n > 0 ? type.color : Color.secondary.opacity(0.35))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(AppSpacing.md)
        .nurseryCard()
        .opacity(visible ? 1 : 0)
        .offset(y: visible ? 0 : 16)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8).delay(Double(index) * 0.06)) {
                visible = true
            }
        }
    }
}
