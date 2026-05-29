//
//  SampleData.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import Foundation
import SwiftData

enum SampleData {

    static let keyworkerName = "Sarah Mitchell"

    @MainActor
    static func insertSampleData(into context: ModelContext) {
        let calendar = Calendar.current
        let today = Date.now

        // MARK: - Rooms

        let sunshineRoom = Room(name: "Sunshine Room", ageGroup: .toddlers,  capacity: 12, colorHex: "#FF9800")
        let rainbowRoom  = Room(name: "Rainbow Room",  ageGroup: .babies,    capacity: 6,  colorHex: "#9C27B0")
        let starRoom     = Room(name: "Star Room",     ageGroup: .preschool, capacity: 16, colorHex: "#2196F3")

        // MARK: - Staff

        let sarah   = StaffMember(fullName: "Sarah Mitchell",  role: .keyworker,      assignedRoom: sunshineRoom)
        let rachel  = StaffMember(fullName: "Rachel Green",    role: .practitioner,   assignedRoom: sunshineRoom)
        let james   = StaffMember(fullName: "James Carter",    role: .roomLeader,     assignedRoom: rainbowRoom)
        let priya   = StaffMember(fullName: "Priya Sharma",    role: .keyworker,      assignedRoom: rainbowRoom)
        let lucy    = StaffMember(fullName: "Lucy Thompson",   role: .roomLeader,     assignedRoom: starRoom)
        let manager = StaffMember(fullName: "Mrs T. Williams", role: .settingManager, assignedRoom: nil)

        sarah.isPresent   = true;  sarah.arrivalTime   = calendar.date(bySettingHour: 8, minute: 0,  second: 0, of: today)
        rachel.isPresent  = true;  rachel.arrivalTime  = calendar.date(bySettingHour: 8, minute: 15, second: 0, of: today)
        james.isPresent   = true;  james.arrivalTime   = calendar.date(bySettingHour: 7, minute: 45, second: 0, of: today)
        priya.isPresent   = false
        lucy.isPresent    = true;  lucy.arrivalTime    = calendar.date(bySettingHour: 8, minute: 30, second: 0, of: today)
        manager.isPresent = true;  manager.arrivalTime = calendar.date(bySettingHour: 7, minute: 30, second: 0, of: today)

        // MARK: - Children

        let emma = Child(
            fullName: "Emma Johnson", preferredName: "Emma",
            dateOfBirth: calendar.date(byAdding: .year, value: -3, to: today)!,
            room: sunshineRoom
        )
        emma.allergies    = ["Peanuts"]
        emma.dietaryNotes = "Nut-free diet. Full-fat dairy."
        emma.medicalNotes = "EpiPen required. Protocol on file."

        let oliver = Child(
            fullName: "Oliver Davies", preferredName: "Ollie",
            dateOfBirth: calendar.date(byAdding: DateComponents(year: -2, month: -4), to: today)!,
            room: sunshineRoom
        )
        oliver.dietaryNotes = "Vegetarian."

        let sophia = Child(
            fullName: "Sophia Patel", preferredName: "Sophia",
            dateOfBirth: calendar.date(byAdding: DateComponents(year: -1, month: -8), to: today)!,
            room: rainbowRoom
        )
        sophia.allergies    = ["Dairy", "Eggs"]
        sophia.dietaryNotes = "Dairy-free, egg-free. Full-fat alternatives only."
        sophia.medicalNotes = "Check all labels carefully."

        let noah = Child(
            fullName: "Noah Williams", preferredName: "Noah",
            dateOfBirth: calendar.date(byAdding: DateComponents(year: -4, month: -2), to: today)!,
            room: starRoom
        )
        noah.dietaryNotes = "Halal diet."

        let amelia = Child(
            fullName: "Amelia Chen", preferredName: "Amelia",
            dateOfBirth: calendar.date(byAdding: DateComponents(year: -3, month: -6), to: today)!,
            room: starRoom
        )
        amelia.allergies = ["Gluten"]
        amelia.dietaryNotes = "Gluten-free."

        // MARK: - Attendance (today)

        func makeAttendance(_ child: Child, hour: Int, minute: Int, method: AttendanceMethod = .walkin, checkedInBy: String = keyworkerName) -> AttendanceRecord {
            let record = AttendanceRecord(child: child, date: today, method: method)
            record.checkInTime  = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: today)
            record.checkedInBy  = checkedInBy
            return record
        }

        let emmaAtt   = makeAttendance(emma,   hour: 8, minute: 30)
        let oliverAtt = makeAttendance(oliver, hour: 8, minute: 45)
        let sophiaAtt = makeAttendance(sophia, hour: 9, minute: 0,  method: .van, checkedInBy: "James Carter")
        let noahAtt   = makeAttendance(noah,   hour: 8, minute: 20, checkedInBy: "Lucy Thompson")
        // Amelia not yet checked in today

        // MARK: - Past attendance (last 7 days for analytics)

        for daysBack in 1...6 {
            guard let pastDay = calendar.date(byAdding: .day, value: -daysBack, to: today) else { continue }
            for child in [emma, oliver, sophia, noah, amelia] {
                let rec = AttendanceRecord(child: child, date: pastDay, method: .walkin)
                rec.checkInTime  = calendar.date(bySettingHour: 8,  minute: 30, second: 0, of: pastDay)
                rec.checkOutTime = calendar.date(bySettingHour: 17, minute: 0,  second: 0, of: pastDay)
                rec.checkedInBy  = keyworkerName
                context.insert(rec)
            }
        }

        // MARK: - Diary entries (today)

        func mood(_ child: Child, level: MoodLevel, context ctx: String, hour: Int, minute: Int) -> DiaryEntry {
            let e = DiaryEntry(entryType: .mood, timestamp: calendar.date(bySettingHour: hour, minute: minute, second: 0, of: today)!, recordedByName: keyworkerName, child: child)
            e.moodLevel = level; e.moodContext = ctx; return e
        }

        let emmaArrivalMood  = mood(emma,   level: .happy,     context: "On arrival",  hour: 8,  minute: 30)
        let oliverArrivalMood = mood(oliver, level: .veryHappy, context: "On arrival",  hour: 8,  minute: 45)
        let sophiaArrivalMood = mood(sophia, level: .settled,   context: "On arrival",  hour: 9,  minute: 0)
        let noahMidMood       = mood(noah,   level: .happy,     context: "After lunch", hour: 12, minute: 30)

        let emmaActivity = DiaryEntry(entryType: .activity, timestamp: calendar.date(bySettingHour: 9, minute: 15, second: 0, of: today)!, recordedByName: keyworkerName, child: emma)
        emmaActivity.activityTitle    = "Outdoor Play"
        emmaActivity.activityCategory = "Outdoor Play"
        emmaActivity.activityDescription = "Enjoyed the climbing frame and sandpit with friends."

        let emmaNap = DiaryEntry(entryType: .sleep, timestamp: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: today)!, recordedByName: keyworkerName, child: emma)
        emmaNap.sleepStart    = calendar.date(bySettingHour: 12, minute: 30, second: 0, of: today)
        emmaNap.sleepEnd      = calendar.date(bySettingHour: 13, minute: 45, second: 0, of: today)
        emmaNap.sleepPosition = .back

        let emmaLunch = DiaryEntry(entryType: .meal, timestamp: calendar.date(bySettingHour: 11, minute: 45, second: 0, of: today)!, recordedByName: keyworkerName, child: emma)
        emmaLunch.mealName    = "Lunch"
        emmaLunch.mealAmount  = .most
        emmaLunch.fluidAmountMl = 150
        emmaLunch.fluidType   = "Water"

        let emmaNappy = DiaryEntry(entryType: .nappy, timestamp: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today)!, recordedByName: keyworkerName, child: emma)
        emmaNappy.nappyType    = .wet
        emmaNappy.creamApplied = false

        let oliverSnack = DiaryEntry(entryType: .meal, timestamp: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today)!, recordedByName: keyworkerName, child: oliver)
        oliverSnack.mealName    = "Morning Snack"
        oliverSnack.mealAmount  = .all
        oliverSnack.fluidAmountMl = 120
        oliverSnack.fluidType   = "Milk"

        let oliverStory = DiaryEntry(entryType: .activity, timestamp: calendar.date(bySettingHour: 9, minute: 30, second: 0, of: today)!, recordedByName: keyworkerName, child: oliver)
        oliverStory.activityTitle    = "Story Time"
        oliverStory.activityCategory = "Story Time"
        oliverStory.activityDescription = "Listened attentively to 'The Very Hungry Caterpillar'."

        let sophiaNappy = DiaryEntry(entryType: .nappy, timestamp: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today)!, recordedByName: keyworkerName, child: sophia)
        sophiaNappy.nappyType    = .both
        sophiaNappy.creamApplied = true

        let sophiaNap = DiaryEntry(entryType: .sleep, timestamp: calendar.date(bySettingHour: 11, minute: 0, second: 0, of: today)!, recordedByName: keyworkerName, child: sophia)
        sophiaNap.sleepStart    = calendar.date(bySettingHour: 11, minute: 0,  second: 0, of: today)
        sophiaNap.sleepEnd      = calendar.date(bySettingHour: 12, minute: 15, second: 0, of: today)
        sophiaNap.sleepPosition = .back

        // MARK: - Past mood entries (7 days) for Analytics chart

        let moodSequences: [(Child, [MoodLevel])] = [
            (emma,   [.happy, .veryHappy, .settled, .happy, .veryHappy, .happy, .settled]),
            (oliver, [.veryHappy, .happy, .veryHappy, .settled, .happy, .veryHappy, .happy]),
            (sophia, [.settled, .unsettled, .settled, .happy, .settled, .happy, .settled]),
            (noah,   [.happy, .happy, .veryHappy, .happy, .happy, .settled, .happy]),
            (amelia, [.settled, .happy, .settled, .happy, .veryHappy, .happy, .happy])
        ]

        for (child, levels) in moodSequences {
            for (index, level) in levels.enumerated() {
                guard let pastDay = calendar.date(byAdding: .day, value: -(index + 1), to: today) else { continue }
                let entry = DiaryEntry(
                    entryType: .mood,
                    timestamp: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: pastDay)!,
                    recordedByName: keyworkerName,
                    child: child
                )
                entry.moodLevel   = level
                entry.moodContext = "Morning check"
                context.insert(entry)
            }
        }

        // MARK: - Incident Reports

        let incident1 = IncidentReport(
            referenceNumber: "INC-20260527-001",
            category: .bump, severity: .minor, status: .parentNotified,
            incidentDate: calendar.date(byAdding: .day, value: -2, to: today)!,
            location: "Outdoor play area",
            descriptionOfIncident: "Emma tripped on uneven ground near the sandpit and bumped her knee on the decking.",
            immediateActionTaken: "Applied cold compress for 5 minutes. No swelling observed. Child settled quickly and returned to play.",
            reportedByName: keyworkerName, child: emma
        )
        incident1.injuryDescription       = "Small red mark on left knee. No broken skin."
        incident1.witnessNames            = ["Rachel Green"]
        incident1.reviewedByName          = "Mrs T. Williams"
        incident1.reviewedAt              = calendar.date(byAdding: .hour, value: 1,  to: calendar.date(byAdding: .day, value: -2, to: today)!)
        incident1.parentNotifiedAt        = calendar.date(byAdding: .hour, value: 2,  to: calendar.date(byAdding: .day, value: -2, to: today)!)
        incident1.parentNotificationMethod = "In Person"
        incident1.parentSignatureObtained = true

        let incident2 = IncidentReport(
            referenceNumber: "INC-20260529-001",
            category: .fall, severity: .minor, status: .pendingReview,
            incidentDate: today,
            location: "Sunshine Room",
            descriptionOfIncident: "Oliver climbed onto a low step stool during free play and lost balance, falling onto the carpeted floor.",
            immediateActionTaken: "Child comforted immediately. Head checked — no visible injury. Child was alert and responsive throughout.",
            reportedByName: keyworkerName, child: oliver
        )
        incident2.injuryDescription = "No visible injury. Child cried for approximately 2 minutes then returned to play."

        let incident3 = IncidentReport(
            referenceNumber: "INC-20260528-001",
            category: .allergicReaction, severity: .moderate, status: .reviewedApproved,
            incidentDate: calendar.date(byAdding: .day, value: -1, to: today)!,
            location: "Dining Area",
            descriptionOfIncident: "Sophia showed signs of mild reaction during afternoon snack. Staff identified a potential cross-contamination with dairy product.",
            immediateActionTaken: "Snack removed immediately. Child monitored for 30 minutes. No escalation required. Parents contacted by phone.",
            reportedByName: "James Carter", child: sophia
        )
        incident3.witnessNames   = ["Priya Sharma"]
        incident3.reviewedByName = "Mrs T. Williams"
        incident3.reviewedAt     = calendar.date(byAdding: .hour, value: 2, to: calendar.date(byAdding: .day, value: -1, to: today)!)
        incident3.managerNotes   = "Catering team briefed. Allergen checklist updated."

        // MARK: - Insert all

        for item in [sunshineRoom, rainbowRoom, starRoom] as [any PersistentModel] { context.insert(item) }
        for item in [sarah, rachel, james, priya, lucy, manager] as [any PersistentModel] { context.insert(item) }
        for item in [emma, oliver, sophia, noah, amelia] as [any PersistentModel] { context.insert(item) }
        for item in [emmaAtt, oliverAtt, sophiaAtt, noahAtt] as [any PersistentModel] { context.insert(item) }
        for item in [emmaArrivalMood, oliverArrivalMood, sophiaArrivalMood, noahMidMood,
                     emmaActivity, emmaNap, emmaLunch, emmaNappy,
                     oliverSnack, oliverStory,
                     sophiaNappy, sophiaNap] as [any PersistentModel] { context.insert(item) }
        for item in [incident1, incident2, incident3] as [any PersistentModel] { context.insert(item) }
    }

    // MARK: - Preview Container

    @MainActor
    static var previewContainer: ModelContainer {
        let schema = Schema([Child.self, DiaryEntry.self, IncidentReport.self,
                             Room.self, StaffMember.self, AttendanceRecord.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        insertSampleData(into: container.mainContext)
        return container
    }
}

