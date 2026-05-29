//
//  IncidentCategoryChart.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import Charts

struct IncidentCategoryChart: View {
    let data: [AnalyticsViewModel.CategoryPoint]

    var body: some View {
        if data.isEmpty {
            ContentUnavailableView("No Incidents", systemImage: "checkmark.shield",
                description: Text("No incidents have been filed."))
                .frame(height: 120)
        } else {
            Chart(data) { item in
                BarMark(
                    x: .value("Count",    item.count),
                    y: .value("Category", item.category)
                )
                .foregroundStyle(Color.nurseryAccent.gradient)
                .cornerRadius(4)
                .annotation(position: .trailing) {
                    Text("\(item.count)")
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { AxisValueLabel(); AxisGridLine() }
            }
            .frame(height: max(CGFloat(data.count) * 36, 80))
        }
    }
}
