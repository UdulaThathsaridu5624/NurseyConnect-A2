//
//  AttendanceRecord.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import Foundation
import SwiftData

enum AttendanceMethod: String, CaseIterable, Codable {
    case walkin = "Walk-in"
    case van    = "Van"
    case other  = "Other"
}

@Model
final class AttendanceRecord {
    var id: UUID = UUID()
    var date: Date
    var checkInTime: Date?
    var checkOutTime: Date?
    var checkedInBy: String = ""
    var checkedOutBy: String = ""
    var method: AttendanceMethod = AttendanceMethod.walkin
    var notes: String = ""

    var child: Child?

    init(child: Child, date: Date, method: AttendanceMethod = .walkin) {
        self.child = child
        self.date = Calendar.current.startOfDay(for: date)
        self.method = method
    }

    var isPresent: Bool {
        checkInTime != nil && checkOutTime == nil
    }

    var duration: TimeInterval? {
        guard let inTime = checkInTime, let outTime = checkOutTime else { return nil }
        return outTime.timeIntervalSince(inTime)
    }

    var durationFormatted: String {
        guard let d = duration else { return "—" }
        let hours = Int(d) / 3600
        let minutes = (Int(d) % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
}

