//
//  ChildRoomCard.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI

struct ChildRoomCard: View {
    let child: Child

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Circle()
                .fill(LinearGradient.nurseryAvatar)
                .frame(width: 44, height: 44)
                .overlay {
                    Text(child.initials)
                        .font(.cardTitle)
                        .foregroundStyle(.white)
                }
            VStack(alignment: .leading, spacing: 3) {
                Text(child.preferredName)
                    .font(.cardTitle)
                Text(child.age)
                    .font(.bodySmall)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if !child.allergies.isEmpty {
                Image(systemName: "allergens")
                    .font(.caption)
                    .foregroundStyle(Color.nurseryAccent)
                    .padding(AppSpacing.xs)
                    .background(Circle().fill(Color.nurseryAccent.opacity(0.15)))
            }
        }
        .padding(.vertical, AppSpacing.xs)
        .contentShape(Rectangle())
        .draggable(child.id.uuidString)
    }
}
