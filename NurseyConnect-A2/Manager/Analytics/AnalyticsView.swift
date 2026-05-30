//
//  AnalyticsView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @Query private var entries: [DiaryEntry]
    @Query private var reports: [IncidentReport]
    @Query private var attendance: [AttendanceRecord]

    private var vm: AnalyticsViewModel {
        let v = AnalyticsViewModel()
        v.diaryEntries      = entries
        v.incidentReports   = reports
        v.attendanceRecords = attendance
        return v
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                GroupBox {
                    MoodTrendChart(data: vm.moodTrend())
                } label: {
                    Label("Wellbeing Trends — Last 7 Days", systemImage: "face.smiling.fill")
                        .font(.sectionHead)
                }

                GroupBox {
                    AttendanceTrendChart(data: vm.attendanceTrend())
                } label: {
                    Label("Attendance — Last 30 Days", systemImage: "person.badge.clock.fill")
                        .font(.sectionHead)
                }

                GroupBox {
                    IncidentCategoryChart(data: vm.incidentsByCategory())
                } label: {
                    Label("Incidents by Category", systemImage: "exclamationmark.triangle.fill")
                        .font(.sectionHead)
                }

                GroupBox {
                    MealAmountChart(data: vm.mealAmounts())
                } label: {
                    Label("Meal Consumption", systemImage: "fork.knife")
                        .font(.sectionHead)
                }
            }
            .padding(AppSpacing.md)
        }
        .background(Color.nurseryBackground)
        .navigationTitle("Analytics")
    }
}

#Preview {
    NavigationStack { AnalyticsView() }
        .modelContainer(SampleData.previewContainer)
}
