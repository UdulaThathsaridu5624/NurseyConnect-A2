//
//  DashboardStatCard.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI

struct DashboardStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var subtitle: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Spacer()
            }
            Text(value)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.sectionHead)
                .foregroundStyle(.primary)
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.bodySmall)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(AppSpacing.md)
        .nurseryCard()
    }
}

#Preview {
    HStack {
        DashboardStatCard(title: "Children Present", value: "12", icon: "person.3.fill", color: .nurseryPrimary, subtitle: "of 18 enrolled")
        DashboardStatCard(title: "Ratio Alerts", value: "1", icon: "exclamationmark.triangle.fill", color: .red)
    }
    .padding()
}
