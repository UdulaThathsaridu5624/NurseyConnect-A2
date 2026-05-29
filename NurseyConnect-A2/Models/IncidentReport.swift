//
//  IncidentReport.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Supporting Enums

enum IncidentCategory: String, CaseIterable, Codable {
    case bump             = "Bump / Bruise"
    case cut              = "Cut / Graze"
    case fall             = "Fall"
    case allergicReaction = "Allergic Reaction"
    case safeguarding     = "Safeguarding Concern"
    case nearMiss         = "Near Miss"
    case medical          = "Medical Incident"

    var systemImage: String {
        switch self {
        case .bump:             return "figure.fall"
        case .cut:              return "bandage"
        case .fall:             return "arrow.down.circle"
        case .allergicReaction: return "allergens"
        case .safeguarding:     return "shield.lefthalf.filled"
        case .nearMiss:         return "exclamationmark.triangle"
        case .medical:          return "cross.case"
        }
    }
}

enum IncidentSeverity: String, CaseIterable, Codable {
    case minor    = "Minor"
    case moderate = "Moderate"
    case serious  = "Serious"

    var color: Color {
        switch self {
        case .minor:    return .green
        case .moderate: return .orange
        case .serious:  return .red
        }
    }
}

enum IncidentStatus: String, CaseIterable, Codable {
    case draft            = "Draft"
    case pendingReview    = "Pending Review"
    case reviewedApproved = "Reviewed & Approved"
    case parentNotified   = "Parent Notified"
    case closed           = "Closed"

    var color: Color {
        switch self {
        case .draft:            return Color(hex: "#9E9E9E")
        case .pendingReview:    return Color(hex: "#F59E0B")
        case .reviewedApproved: return Color(hex: "#10B981")
        case .parentNotified:   return Color(hex: "#3B82F6")
        case .closed:           return Color(hex: "#6B7280")
        }
    }
}

// MARK: - BodyMapMark

struct BodyMapMark: Codable, Identifiable {
    var id: UUID = UUID()
    var xNormalized: Double
    var yNormalized: Double
    var isFrontView: Bool
    var label: String
}

// MARK: - IncidentReport Model

@Model
final class IncidentReport {
    var id: UUID = UUID()
    var referenceNumber: String
    var category: IncidentCategory
    var severity: IncidentSeverity
    var status: IncidentStatus = IncidentStatus.draft
    var incidentDate: Date
    var location: String
    var descriptionOfIncident: String
    var injuryDescription: String = ""
    var immediateActionTaken: String
    var witnessNames: [String] = []
    var bodyMapMarksData: Data?
    var reportedByName: String
    var reportedByRole: String = "Early Years Practitioner"
    var reviewedByName: String?
    var reviewedAt: Date?
    var managerNotes: String?
    var parentNotifiedAt: Date?
    var parentNotificationMethod: String?
    var parentSignatureObtained: Bool = false

    var child: Child?

    init(referenceNumber: String,
         category: IncidentCategory,
         severity: IncidentSeverity,
         status: IncidentStatus = .pendingReview,
         incidentDate: Date,
         location: String,
         descriptionOfIncident: String,
         immediateActionTaken: String,
         reportedByName: String,
         child: Child? = nil) {
        self.referenceNumber = referenceNumber
        self.category = category
        self.severity = severity
        self.status = status
        self.incidentDate = incidentDate
        self.location = location
        self.descriptionOfIncident = descriptionOfIncident
        self.immediateActionTaken = immediateActionTaken
        self.reportedByName = reportedByName
        self.child = child
    }

    // MARK: - Body Map Marks

    var bodyMapMarks: [BodyMapMark] {
        guard let data = bodyMapMarksData else { return [] }
        return (try? JSONDecoder().decode([BodyMapMark].self, from: data)) ?? []
    }

    func updateBodyMapMarks(_ marks: [BodyMapMark]) {
        bodyMapMarksData = try? JSONEncoder().encode(marks)
    }

    // MARK: - Status Workflow

    var nextStatuses: [IncidentStatus] {
        switch status {
        case .draft:            return [.pendingReview]
        case .pendingReview:    return [.reviewedApproved]
        case .reviewedApproved: return [.parentNotified]
        case .parentNotified:   return [.closed]
        case .closed:           return []
        }
    }
}

// MARK: - Color hex helper

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

