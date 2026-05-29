//
//  PDFReportGenerator.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import PDFKit
import UIKit

final class PDFReportGenerator {

    static let pageSize = CGSize(width: 595, height: 842) // A4

    // MARK: - Incident Report PDF

    static func generateIncidentPDF(report: IncidentReport) -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        return renderer.pdfData { ctx in
            ctx.beginPage()
            var y: CGFloat = 40

            drawHeader(y: &y, title: "INCIDENT REPORT — \(report.referenceNumber)")
            drawSectionTitle("Incident Details", y: &y)
            drawRow("Reference:",  report.referenceNumber,     y: &y)
            drawRow("Child:",      report.child?.fullName ?? "—", y: &y)
            drawRow("Date:",       formatDate(report.incidentDate), y: &y)
            drawRow("Time:",       formatTime(report.incidentDate), y: &y)
            drawRow("Category:",   report.category.rawValue,   y: &y)
            drawRow("Severity:",   report.severity.rawValue,   y: &y)
            drawRow("Location:",   report.location,            y: &y)
            drawRow("Status:",     report.status.rawValue,     y: &y)
            drawRow("Reported by:", report.reportedByName,     y: &y)

            drawSectionTitle("Description of Incident", y: &y)
            drawParagraph(report.descriptionOfIncident, y: &y)

            if !report.injuryDescription.isEmpty {
                drawSectionTitle("Injury / Observation", y: &y)
                drawParagraph(report.injuryDescription, y: &y)
            }

            drawSectionTitle("Immediate Action Taken", y: &y)
            drawParagraph(report.immediateActionTaken, y: &y)

            if !report.witnessNames.isEmpty {
                drawSectionTitle("Witnesses", y: &y)
                report.witnessNames.forEach { drawParagraph("• \($0)", y: &y) }
            }

            drawSectionTitle("Manager Review", y: &y)
            drawRow("Reviewed by:", report.reviewedByName ?? "—", y: &y)
            if let notes = report.managerNotes { drawParagraph(notes, y: &y) }

            drawSectionTitle("Parent Notification", y: &y)
            drawRow("Notified at:", report.parentNotifiedAt.map { formatDate($0) } ?? "—", y: &y)
            drawRow("Method:",      report.parentNotificationMethod ?? "—", y: &y)
            drawRow("Acknowledged:", report.parentSignatureObtained ? "Yes" : "No", y: &y)

            drawFooter(note: "Generated in accordance with RIDDOR 2013 & EYFS statutory requirements. Little Stars Nursery & Daycare.")
        }
    }

    // MARK: - Daily Diary PDF

    static func generateDailyDiaryPDF(child: Child, date: Date) -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        return renderer.pdfData { ctx in
            ctx.beginPage()
            var y: CGFloat = 40

            drawHeader(y: &y, title: "DAILY DIARY — \(child.fullName)")
            drawRow("Date:",      formatDate(date),         y: &y)
            drawRow("Room:",      child.roomName,           y: &y)
            drawRow("Age:",       child.age,                y: &y)
            if !child.allergies.isEmpty {
                drawRow("Allergies:", child.allergies.joined(separator: ", "), y: &y)
            }

            let entries = child.diaryEntries(for: date)
            if entries.isEmpty {
                drawSectionTitle("No entries recorded for this date.", y: &y)
            } else {
                for type in DiaryEntryType.allCases {
                    let typeEntries = entries.filter { $0.entryType == type }
                    guard !typeEntries.isEmpty else { continue }
                    drawSectionTitle(type.rawValue, y: &y)
                    for entry in typeEntries {
                        drawRow(formatTime(entry.timestamp) + ":", entry.headline, y: &y)
                        if !entry.subtitle.isEmpty { drawParagraph("  \(entry.subtitle)", y: &y) }
                        if !entry.notes.isEmpty    { drawParagraph("  Note: \(entry.notes)", y: &y) }
                    }
                }
            }

            drawFooter(note: "NurseyConnect Daily Diary — Little Stars Nursery & Daycare")
        }
    }

    // MARK: - Attendance Report PDF

    static func generateAttendancePDF(room: Room, month: Date) -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        return renderer.pdfData { ctx in
            ctx.beginPage()
            var y: CGFloat = 40

            let monthStr = month.formatted(.dateTime.month(.wide).year())
            drawHeader(y: &y, title: "ATTENDANCE REPORT — \(room.name)")
            drawRow("Month:", monthStr, y: &y)
            drawRow("Room:",  room.name, y: &y)
            drawRow("Age Group:", room.ageGroup.rawValue, y: &y)
            drawRow("Capacity:", "\(room.capacity)", y: &y)

            drawSectionTitle("Children Enrolled", y: &y)
            for child in room.children.filter({ $0.isActive }) {
                let calendar = Calendar.current
                let records = child.attendanceRecords.filter {
                    calendar.isDate($0.date, equalTo: month, toGranularity: .month)
                }
                let days = records.filter { $0.checkInTime != nil }.count
                drawRow(child.fullName + ":", "\(days) day\(days == 1 ? "" : "s") attended", y: &y)
            }

            drawFooter(note: "NurseyConnect Attendance Report — Little Stars Nursery & Daycare")
        }
    }

    // MARK: - Drawing Helpers

    private static func drawHeader(y: inout CGFloat, title: String) {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: UIColor(red: 0.18, green: 0.60, blue: 0.40, alpha: 1)
        ]
        let headerStr = NSAttributedString(string: "Little Stars Nursery & Daycare", attributes: attrs)
        headerStr.draw(at: CGPoint(x: 40, y: y)); y += 26

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: UIColor.darkGray
        ]
        NSAttributedString(string: title, attributes: titleAttrs).draw(at: CGPoint(x: 40, y: y)); y += 20

        let line = UIBezierPath()
        line.move(to: CGPoint(x: 40, y: y)); line.addLine(to: CGPoint(x: 555, y: y))
        UIColor.lightGray.setStroke(); line.lineWidth = 0.5; line.stroke(); y += 14
    }

    private static func drawSectionTitle(_ title: String, y: inout CGFloat) {
        y += 6
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: UIColor(red: 0.18, green: 0.60, blue: 0.40, alpha: 1)
        ]
        NSAttributedString(string: title.uppercased(), attributes: attrs).draw(at: CGPoint(x: 40, y: y)); y += 16
    }

    private static func drawRow(_ label: String, _ value: String, y: inout CGFloat) {
        let labelAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10, weight: .medium), .foregroundColor: UIColor.gray]
        let valueAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor.black]
        NSAttributedString(string: label, attributes: labelAttrs).draw(at: CGPoint(x: 40,  y: y))
        NSAttributedString(string: value, attributes: valueAttrs).draw(at: CGPoint(x: 160, y: y))
        y += 16
    }

    private static func drawParagraph(_ text: String, y: inout CGFloat) {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor.darkGray]
        let rect = CGRect(x: 40, y: y, width: 515, height: 200)
        let str  = NSAttributedString(string: text, attributes: attrs)
        str.draw(with: rect, options: .usesLineFragmentOrigin, context: nil)
        let lines = max(1, Int(text.count / 85) + 1)
        y += CGFloat(lines) * 14 + 4
    }

    private static func drawFooter(note: String) {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 8), .foregroundColor: UIColor.lightGray]
        NSAttributedString(string: note, attributes: attrs).draw(at: CGPoint(x: 40, y: 810))
    }

    private static func formatDate(_ date: Date) -> String {
        date.formatted(date: .long, time: .omitted)
    }

    private static func formatTime(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}
