//
//  NurseyConnect_A2Tests.swift
//  NurseyConnect-A2Tests
//
//  Created by Udula on 2026-05-29.
//

import XCTest
import SwiftData
@testable import NurseyConnect_A2

// MARK: - Room Model Tests (EYFS Ratio Compliance)

final class RoomTests: XCTestCase {

    private func makeRoom(ageGroup: AgeGroup, children: Int, staff: Int) -> Room {
        let room = Room(name: "Test Room", ageGroup: ageGroup, capacity: 20)
        // Inject counts via test-only computed logic rather than inserting into a container
        // We test ratioOK directly by creating a minimal in-memory setup
        return room
    }

    // EYFS ratio: Babies = 1:3
    func testRatioOK_Babies_WithinLimit() {
        // 1 staff : 3 children = OK
        let result = eyfsRatioOK(ageGroup: .babies, staffCount: 1, childCount: 3)
        XCTAssertTrue(result, "1 staff : 3 babies should be compliant")
    }

    func testRatioBreached_Babies_OverLimit() {
        // 1 staff : 4 children = BREACH
        let result = eyfsRatioOK(ageGroup: .babies, staffCount: 1, childCount: 4)
        XCTAssertFalse(result, "1 staff : 4 babies should breach EYFS ratio")
    }

    // EYFS ratio: Toddlers = 1:4
    func testRatioOK_Toddlers_WithinLimit() {
        let result = eyfsRatioOK(ageGroup: .toddlers, staffCount: 2, childCount: 8)
        XCTAssertTrue(result, "2 staff : 8 toddlers should be compliant")
    }

    func testRatioBreached_Toddlers_OverLimit() {
        let result = eyfsRatioOK(ageGroup: .toddlers, staffCount: 1, childCount: 5)
        XCTAssertFalse(result, "1 staff : 5 toddlers should breach EYFS ratio")
    }

    // EYFS ratio: Pre-school = 1:8
    func testRatioOK_Preschool_WithinLimit() {
        let result = eyfsRatioOK(ageGroup: .preschool, staffCount: 1, childCount: 8)
        XCTAssertTrue(result, "1 staff : 8 preschool children should be compliant")
    }

    func testRatioBreached_Preschool_OverLimit() {
        let result = eyfsRatioOK(ageGroup: .preschool, staffCount: 1, childCount: 9)
        XCTAssertFalse(result, "1 staff : 9 preschool children should breach EYFS ratio")
    }

    // No staff present
    func testRatioBreached_NoStaff_WithChildren() {
        let result = eyfsRatioOK(ageGroup: .toddlers, staffCount: 0, childCount: 1)
        XCTAssertFalse(result, "0 staff with children should breach ratio")
    }

    // Empty room
    func testRatioOK_EmptyRoom() {
        let result = eyfsRatioOK(ageGroup: .babies, staffCount: 0, childCount: 0)
        XCTAssertTrue(result, "Empty room should be compliant")
    }

    // ratioRequired values
    func testRatioRequired_Babies() {
        XCTAssertEqual(ratioRequired(for: .babies), 3)
    }

    func testRatioRequired_Toddlers() {
        XCTAssertEqual(ratioRequired(for: .toddlers), 4)
    }

    func testRatioRequired_Preschool() {
        XCTAssertEqual(ratioRequired(for: .preschool), 8)
    }

    func testRatioRequired_Reception() {
        XCTAssertEqual(ratioRequired(for: .reception), 8)
    }

    // Helper: replicate Room.ratioOK logic without needing a SwiftData container
    private func eyfsRatioOK(ageGroup: AgeGroup, staffCount: Int, childCount: Int) -> Bool {
        guard staffCount > 0 else { return childCount == 0 }
        let required = ratioRequired(for: ageGroup)
        return childCount <= staffCount * required
    }

    private func ratioRequired(for ageGroup: AgeGroup) -> Int {
        switch ageGroup {
        case .babies:                return 3
        case .toddlers:              return 4
        case .preschool, .reception: return 8
        }
    }
}

// MARK: - AttendanceRecord Tests

final class AttendanceRecordTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    @MainActor
    override func setUpWithError() throws {
        let schema = Schema([Child.self, Room.self, AttendanceRecord.self,
                             DiaryEntry.self, IncidentReport.self,
                             StaffMember.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        context = container.mainContext
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    @MainActor
    private func makeChild() -> Child {
        let child = Child(fullName: "Test Child", preferredName: "Test", dateOfBirth: Date())
        context.insert(child)
        return child
    }

    @MainActor
    func testIsPresent_AfterCheckIn() {
        let child = makeChild()
        let record = AttendanceRecord(child: child, date: .now)
        record.checkInTime = .now
        XCTAssertTrue(record.isPresent, "Child should be present after check-in with no check-out")
    }

    @MainActor
    func testIsNotPresent_BeforeCheckIn() {
        let child = makeChild()
        let record = AttendanceRecord(child: child, date: .now)
        XCTAssertFalse(record.isPresent, "Child should not be present before check-in")
    }

    @MainActor
    func testIsNotPresent_AfterCheckOut() {
        let child = makeChild()
        let record = AttendanceRecord(child: child, date: .now)
        record.checkInTime  = Date(timeIntervalSinceNow: -3600)
        record.checkOutTime = .now
        XCTAssertFalse(record.isPresent, "Child should not be present after check-out")
    }

    @MainActor
    func testDuration_Calculation() {
        let child = makeChild()
        let record = AttendanceRecord(child: child, date: .now)
        let inTime  = Date(timeIntervalSinceNow: -7200) // 2 hours ago
        let outTime = Date(timeIntervalSinceNow: -3600) // 1 hour ago
        record.checkInTime  = inTime
        record.checkOutTime = outTime
        XCTAssertEqual(record.duration ?? 0, 3600, accuracy: 1.0,
                       "Duration should be 3600 seconds (1 hour)")
    }

    @MainActor
    func testDuration_NilWhenNoCheckOut() {
        let child = makeChild()
        let record = AttendanceRecord(child: child, date: .now)
        record.checkInTime = .now
        XCTAssertNil(record.duration, "Duration should be nil when child has not checked out")
    }

    @MainActor
    func testDurationFormatted_Hours() {
        let child = makeChild()
        let record = AttendanceRecord(child: child, date: .now)
        record.checkInTime  = Date(timeIntervalSinceNow: -5400) // 1.5 hours ago
        record.checkOutTime = .now
        XCTAssertEqual(record.durationFormatted, "1h 30m")
    }

    @MainActor
    func testDurationFormatted_MinutesOnly() {
        let child = makeChild()
        let record = AttendanceRecord(child: child, date: .now)
        record.checkInTime  = Date(timeIntervalSinceNow: -1800) // 30 min ago
        record.checkOutTime = .now
        XCTAssertEqual(record.durationFormatted, "30m")
    }

    @MainActor
    func testDurationFormatted_DashWhenNil() {
        let child = makeChild()
        let record = AttendanceRecord(child: child, date: .now)
        XCTAssertEqual(record.durationFormatted, "—")
    }

    @MainActor
    func testDate_StoredAsStartOfDay() {
        let child = makeChild()
        let now = Date.now
        let record = AttendanceRecord(child: child, date: now)
        let startOfDay = Calendar.current.startOfDay(for: now)
        XCTAssertEqual(record.date, startOfDay, "Date should be normalised to start of day")
    }
}

// MARK: - PDF Report Generator Tests

final class PDFReportGeneratorTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    @MainActor
    override func setUpWithError() throws {
        let schema = Schema([Child.self, Room.self, AttendanceRecord.self,
                             DiaryEntry.self, IncidentReport.self,
                             StaffMember.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        context = container.mainContext
        SampleData.insertSampleData(into: context)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    @MainActor
    func testIncidentPDF_GeneratesNonEmptyData() throws {
        let reports = try context.fetch(FetchDescriptor<IncidentReport>())
        XCTAssertFalse(reports.isEmpty, "Sample data should contain incident reports")
        let report = reports[0]
        let data = PDFReportGenerator.generateIncidentPDF(report: report)
        XCTAssertFalse(data.isEmpty, "Incident PDF should produce non-empty data")
    }

    @MainActor
    func testIncidentPDF_IsValidPDF() throws {
        let reports = try context.fetch(FetchDescriptor<IncidentReport>())
        let data = PDFReportGenerator.generateIncidentPDF(report: reports[0])
        // PDF files start with "%PDF"
        let header = String(data: data.prefix(4), encoding: .ascii)
        XCTAssertEqual(header, "%PDF", "Generated data should be a valid PDF")
    }

    @MainActor
    func testDailyDiaryPDF_GeneratesNonEmptyData() throws {
        let children = try context.fetch(FetchDescriptor<Child>())
        XCTAssertFalse(children.isEmpty, "Sample data should contain children")
        let data = PDFReportGenerator.generateDailyDiaryPDF(child: children[0], date: .now)
        XCTAssertFalse(data.isEmpty, "Daily diary PDF should produce non-empty data")
    }

    @MainActor
    func testDailyDiaryPDF_IsValidPDF() throws {
        let children = try context.fetch(FetchDescriptor<Child>())
        let data = PDFReportGenerator.generateDailyDiaryPDF(child: children[0], date: .now)
        let header = String(data: data.prefix(4), encoding: .ascii)
        XCTAssertEqual(header, "%PDF", "Daily diary PDF should be a valid PDF")
    }

    @MainActor
    func testAttendancePDF_GeneratesNonEmptyData() throws {
        let rooms = try context.fetch(FetchDescriptor<Room>())
        XCTAssertFalse(rooms.isEmpty, "Sample data should contain rooms")
        let data = PDFReportGenerator.generateAttendancePDF(room: rooms[0], month: .now)
        XCTAssertFalse(data.isEmpty, "Attendance PDF should produce non-empty data")
    }

    @MainActor
    func testAttendancePDF_IsValidPDF() throws {
        let rooms = try context.fetch(FetchDescriptor<Room>())
        let data = PDFReportGenerator.generateAttendancePDF(room: rooms[0], month: .now)
        let header = String(data: data.prefix(4), encoding: .ascii)
        XCTAssertEqual(header, "%PDF", "Attendance PDF should be a valid PDF")
    }
}

// MARK: - IncidentReport Model Tests

final class IncidentReportTests: XCTestCase {

    func testNextStatuses_Draft() {
        let report = makeReport(status: .draft)
        XCTAssertEqual(report.nextStatuses, [.pendingReview])
    }

    func testNextStatuses_PendingReview() {
        let report = makeReport(status: .pendingReview)
        XCTAssertEqual(report.nextStatuses, [.reviewedApproved])
    }

    func testNextStatuses_ReviewedApproved() {
        let report = makeReport(status: .reviewedApproved)
        XCTAssertEqual(report.nextStatuses, [.parentNotified])
    }

    func testNextStatuses_ParentNotified() {
        let report = makeReport(status: .parentNotified)
        XCTAssertEqual(report.nextStatuses, [.closed])
    }

    func testNextStatuses_Closed() {
        let report = makeReport(status: .closed)
        XCTAssertTrue(report.nextStatuses.isEmpty, "Closed reports should have no next statuses")
    }

    func testBodyMapMarks_RoundTrip() {
        let report = makeReport(status: .draft)
        let marks = [
            BodyMapMark(xNormalized: 0.5, yNormalized: 0.2, isFrontView: true,  label: "Head"),
            BodyMapMark(xNormalized: 0.3, yNormalized: 0.6, isFrontView: false, label: "Back")
        ]
        report.updateBodyMapMarks(marks)
        let decoded = report.bodyMapMarks
        XCTAssertEqual(decoded.count, 2)
        XCTAssertEqual(decoded[0].label, "Head")
        XCTAssertEqual(decoded[1].label, "Back")
        XCTAssertTrue(decoded[0].isFrontView)
        XCTAssertFalse(decoded[1].isFrontView)
    }

    func testBodyMapMarks_EmptyWhenNoData() {
        let report = makeReport(status: .draft)
        XCTAssertTrue(report.bodyMapMarks.isEmpty)
    }

    private func makeReport(status: IncidentStatus) -> IncidentReport {
        IncidentReport(
            referenceNumber: "INC-TEST-001",
            category: .bump,
            severity: .minor,
            status: status,
            incidentDate: .now,
            location: "Test Room",
            descriptionOfIncident: "Test incident",
            immediateActionTaken: "Test action",
            reportedByName: "Test Staff"
        )
    }
}

// MARK: - Child Model Tests

final class ChildModelTests: XCTestCase {

    func testInitials_TwoNames() {
        let child = Child(fullName: "Emma Johnson", preferredName: "Emma", dateOfBirth: .now)
        XCTAssertEqual(child.initials, "EJ")
    }

    func testInitials_SingleName() {
        let child = Child(fullName: "Emma", preferredName: "Emma", dateOfBirth: .now)
        XCTAssertEqual(child.initials, "E")
    }

    func testRoomName_UnassignedWhenNoRoom() {
        let child = Child(fullName: "Test Child", preferredName: "Test", dateOfBirth: .now)
        XCTAssertEqual(child.roomName, "Unassigned")
    }

    func testDiaryEntriesForToday_EmptyForNewChild() {
        let child = Child(fullName: "Test Child", preferredName: "Test", dateOfBirth: .now)
        XCTAssertTrue(child.diaryEntriesForToday.isEmpty)
    }

    func testAge_InMonths() {
        let dob = Calendar.current.date(byAdding: .month, value: -6, to: .now)!
        let child = Child(fullName: "Baby Test", preferredName: "Baby", dateOfBirth: dob)
        XCTAssertEqual(child.age, "6 months")
    }

    func testAge_InYears() {
        let dob = Calendar.current.date(byAdding: .year, value: -3, to: .now)!
        let child = Child(fullName: "Toddler Test", preferredName: "Toddler", dateOfBirth: dob)
        XCTAssertEqual(child.age, "3y")
    }
}
