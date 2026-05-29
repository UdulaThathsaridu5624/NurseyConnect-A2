//
//  IncidentRowView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

//  IncidentRowView.swift — NurseyConnect-A2
import SwiftUI; import SwiftData

struct IncidentRowView: View {
    let report: IncidentReport
    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16, weight: .semibold)).foregroundStyle(report.severity.color)
                .frame(width: 36, height: 36).background(report.severity.color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(report.referenceNumber).font(.cardTitle).foregroundStyle(.primary)
                Text(report.category.rawValue + (report.child != nil ? " · \(report.child!.preferredName)" : ""))
                    .font(.bodySmall).foregroundStyle(.secondary).lineLimit(1)
                Text(report.incidentDate, style: .date).font(.bodySmall).foregroundStyle(.secondary)
            }
            Spacer()
            StatusBadge(status: report.status)
        }
        .padding(.vertical, AppSpacing.xs)
    }
}
