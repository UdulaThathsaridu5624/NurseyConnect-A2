//
//  AttendanceTrendChart.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import Charts

struct AttendanceTrendChart: View {
    let data: [AnalyticsViewModel.AttendanceDayPoint]

    var body: some View {
        if data.isEmpty {
            ContentUnavailableView("No Attendance Data", systemImage: "person.badge.clock",
                description: Text("Attendance records will appear here."))
                .frame(height: 160)
        } else {
            Chart(data) { point in
                BarMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Present", point.count)
                )
                .foregroundStyle(Color.nurseryPrimary.gradient)
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date, format: .dateTime.month(.abbreviated).day())
                                .font(.caption2)
                        }
                    }
                    AxisGridLine()
                }
            }
            .chartYAxis {
                AxisMarks { AxisValueLabel(); AxisGridLine() }
            }
            .frame(height: 180)
        }
    }
}
