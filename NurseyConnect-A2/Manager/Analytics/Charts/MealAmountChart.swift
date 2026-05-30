//
//  MealAmountChart.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import Charts

struct MealAmountChart: View {
    let data: [AnalyticsViewModel.MealAmountPoint]

    private func color(for amount: String) -> Color {
        switch amount {
        case "All":     return .green
        case "Most":    return Color(red: 0.5, green: 0.8, blue: 0.3)
        case "Half":    return .yellow
        case "Little":  return .orange
        case "None":    return .red
        case "Refused": return .purple
        default:        return .gray
        }
    }

    var body: some View {
        if data.isEmpty {
            ContentUnavailableView("No Meal Data", systemImage: "fork.knife",
                description: Text("Meal entries will appear here."))
                .frame(height: 120)
        } else {
            Chart(data) { item in
                SectorMark(
                    angle: .value("Count", item.count),
                    innerRadius: .ratio(0.55),
                    angularInset: 2
                )
                .foregroundStyle(color(for: item.amount))
                .annotation(position: .overlay) {
                    Text(item.amount)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .chartLegend(position: .bottom, alignment: .center, spacing: 8)
            .frame(height: 180)
        }
    }
}
