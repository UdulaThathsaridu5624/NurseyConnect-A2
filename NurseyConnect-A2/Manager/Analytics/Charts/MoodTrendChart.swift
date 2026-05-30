//
//  MoodTrendChart.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import Charts

struct MoodTrendChart: View {
    let data: [AnalyticsViewModel.MoodDataPoint]

    private func moodLabel(_ value: Int) -> String {
        switch value {
        case 1: return "Upset"
        case 2: return "Unsettled"
        case 3: return "Settled"
        case 4: return "Happy"
        case 5: return "Very Happy"
        default: return ""
        }
    }

    var body: some View {
        if data.isEmpty {
            ContentUnavailableView("No Mood Data", systemImage: "face.smiling",
                description: Text("Mood entries from the last 7 days will appear here."))
                .frame(height: 180)
        } else {
            Chart(data) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Mood", point.level)
                )
                .foregroundStyle(by: .value("Child", point.childName))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Mood", point.level)
                )
                .foregroundStyle(by: .value("Child", point.childName))
                .symbolSize(40)
            }
            .chartYScale(domain: 1...5)
            .chartYAxis {
                AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                    AxisValueLabel {
                        Text(moodLabel(value.as(Int.self) ?? 0))
                            .font(.system(size: 9, design: .rounded))
                    }
                    AxisGridLine()
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    AxisGridLine()
                }
            }
            .chartLegend(position: .bottom, alignment: .leading)
            .frame(height: 200)
        }
    }
}
