//
//  DiaryEntry.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - Supporting Enums

enum DiaryEntryType: String, CaseIterable, Codable, Identifiable {
    case activity = "Activity"
    case sleep    = "Sleep"
    case meal     = "Meal"
    case nappy    = "Nappy"
    case mood     = "Wellbeing"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .activity: return "figure.play"
        case .sleep:    return "moon.zzz.fill"
        case .meal:     return "fork.knife"
        case .nappy:    return "drop.fill"
        case .mood:     return "face.smiling.fill"
        }
    }

    var color: Color {
        switch self {
        case .activity: return .blue
        case .sleep:    return .indigo
        case .meal:     return .orange
        case .nappy:    return .teal
        case .mood:     return .pink
        }
    }
}

enum MealAmount: String, CaseIterable, Codable {
    case all      = "All"
    case most     = "Most"
    case half     = "Half"
    case little   = "Little"
    case none     = "None"
    case refused  = "Refused"
}

enum NappyType: String, CaseIterable, Codable {
    case wet    = "Wet"
    case dirty  = "Dirty"
    case both   = "Both"
    case dry    = "Dry"

    var emoji: String {
        switch self {
        case .wet:   return "💧"
        case .dirty: return "💩"
        case .both:  return "💧💩"
        case .dry:   return "✅"
        }
    }
}

enum MoodLevel: String, CaseIterable, Codable {
    case veryHappy  = "Very Happy"
    case happy      = "Happy"
    case settled    = "Settled"
    case unsettled  = "Unsettled"
    case upset      = "Upset"

    var emoji: String {
        switch self {
        case .veryHappy:  return "😄"
        case .happy:      return "🙂"
        case .settled:    return "😐"
        case .unsettled:  return "😟"
        case .upset:      return "😢"
        }
    }

    var color: Color {
        switch self {
        case .veryHappy:  return .green
        case .happy:      return Color(red: 0.6, green: 0.8, blue: 0.4)
        case .settled:    return .yellow
        case .unsettled:  return .orange
        case .upset:      return .red
        }
    }

    var numericValue: Double {
        switch self {
        case .veryHappy:  return 5
        case .happy:      return 4
        case .settled:    return 3
        case .unsettled:  return 2
        case .upset:      return 1
        }
    }
}

enum SleepPosition: String, CaseIterable, Codable {
    case back  = "On Back"
    case side  = "On Side"
    case other = "Other"
}

// MARK: - DiaryEntry Model

@Model
final class DiaryEntry {
    var id: UUID = UUID()
    var entryType: DiaryEntryType
    var timestamp: Date = Date.now
    var recordedByName: String
    var notes: String = ""

    var child: Child?

    // Activity fields
    var activityTitle: String?
    var activityCategory: String?
    var activityDescription: String?

    // Sleep fields
    var sleepStart: Date?
    var sleepEnd: Date?
    var sleepPosition: SleepPosition?

    // Meal fields
    var mealName: String?
    var mealAmount: MealAmount?
    var fluidAmountMl: Int?
    var fluidType: String?

    // Nappy fields
    var nappyType: NappyType?
    var creamApplied: Bool = false

    // Mood fields
    var moodLevel: MoodLevel?
    var moodContext: String?

    init(entryType: DiaryEntryType,
         timestamp: Date = .now,
         recordedByName: String,
         child: Child? = nil) {
        self.entryType = entryType
        self.timestamp = timestamp
        self.recordedByName = recordedByName
        self.child = child
    }

    // MARK: - Display Helpers

    var headline: String {
        switch entryType {
        case .activity:
            return activityTitle ?? activityCategory ?? "Activity"
        case .sleep:
            if let start = sleepStart, let end = sleepEnd {
                let mins = max(0, Int(end.timeIntervalSince(start) / 60))
                let h = mins / 60
                let m = mins % 60
                let duration = h > 0 ? (m > 0 ? "\(h) hr \(m) min" : "\(h) hr") : "\(m) min"
                return "Nap — \(duration)"
            }
            return sleepStart != nil ? "Sleep (ongoing)" : "Sleep"
        case .meal:
            let name = mealName ?? "Meal"
            if let amount = mealAmount {
                return "\(name) — \(amount.rawValue)"
            }
            return name
        case .nappy:
            if let type = nappyType {
                return "\(type.emoji) \(type.rawValue)"
            }
            return "Nappy check"
        case .mood:
            if let mood = moodLevel {
                return "\(mood.emoji) \(mood.rawValue)"
            }
            return "Wellbeing check"
        }
    }

    var subtitle: String {
        switch entryType {
        case .activity:
            if let cat = activityCategory, let title = activityTitle, cat != title {
                return cat
            }
            return activityDescription.map { $0.isEmpty ? "" : $0 } ?? ""
        case .sleep:
            return sleepPosition?.rawValue ?? ""
        case .meal:
            if let ml = fluidAmountMl, let type = fluidType, ml > 0 {
                return "\(type) — \(ml) ml"
            }
            return ""
        case .nappy:
            return creamApplied ? "Cream applied" : ""
        case .mood:
            return moodContext ?? ""
        }
    }

    var sleepDurationMinutes: Int {
        guard let start = sleepStart, let end = sleepEnd else { return 0 }
        return max(0, Int(end.timeIntervalSince(start) / 60))
    }
}

