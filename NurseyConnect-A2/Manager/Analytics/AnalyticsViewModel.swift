//
//  AnalyticsViewModel.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import Foundation
import Observation

@Observable
class AnalyticsViewModel {
    var diaryEntries: [DiaryEntry] = []
    var incidentReports: [IncidentReport] = []
    var attendanceRecords: [AttendanceRecord] = []

    // MARK: - Mood Trend

    struct MoodDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let childName: String
        let level: Double
    }

    func moodTrend(days: Int = 7) -> [MoodDataPoint] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
        return diaryEntries
            .filter { $0.entryType == .mood && $0.timestamp >= cutoff && $0.moodLevel != nil }
            .map { entry in
                MoodDataPoint(
                    date: Calendar.current.startOfDay(for: entry.timestamp),
                    childName: entry.child?.preferredName ?? "Unknown",
                    level: entry.moodLevel?.numericValue ?? 3
                )
            }
            .sorted { $0.date < $1.date }
    }

    // MARK: - Attendance Trend

    struct AttendanceDayPoint: Identifiable {
        let id = UUID()
        let date: Date
        let count: Int
    }

    func attendanceTrend(days: Int = 30) -> [AttendanceDayPoint] {
        let calendar = Calendar.current
        let cutoff = calendar.date(byAdding: .day, value: -days, to: .now) ?? .now
        let recent = attendanceRecords.filter { $0.date >= cutoff && $0.checkInTime != nil }
        let grouped = Dictionary(grouping: recent) { $0.date }
        return grouped.map { AttendanceDayPoint(date: $0.key, count: $0.value.count) }
            .sorted { $0.date < $1.date }
    }

    // MARK: - Incidents by Category

    struct CategoryPoint: Identifiable {
        let id = UUID()
        let category: String
        let count: Int
    }

    func incidentsByCategory() -> [CategoryPoint] {
        let grouped = Dictionary(grouping: incidentReports) { $0.category.rawValue }
        return grouped.map { CategoryPoint(category: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    // MARK: - Meal Amounts

    struct MealAmountPoint: Identifiable {
        let id = UUID()
        let amount: String
        let count: Int
    }

    func mealAmounts() -> [MealAmountPoint] {
        let mealEntries = diaryEntries.filter { $0.entryType == .meal && $0.mealAmount != nil }
        let grouped = Dictionary(grouping: mealEntries) { $0.mealAmount!.rawValue }
        return MealAmount.allCases.compactMap { amount in
            let count = grouped[amount.rawValue]?.count ?? 0
            return count > 0 ? MealAmountPoint(amount: amount.rawValue, count: count) : nil
        }
    }
}
