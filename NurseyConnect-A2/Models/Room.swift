//
//  Room.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import Foundation
import SwiftData

enum AgeGroup: String, CaseIterable, Codable {
    case babies     = "Babies (0–1)"
    case toddlers   = "Toddlers (1–2)"
    case preschool  = "Pre-school (2–4)"
    case reception  = "Reception (4–5)"
}

@Model
final class Room {
    var id: UUID = UUID()
    var name: String
    var ageGroup: AgeGroup
    var capacity: Int
    var colorHex: String = "#4CAF50"

    @Relationship(inverse: \Child.room)
    var children: [Child] = []

    @Relationship(inverse: \StaffMember.assignedRoom)
    var staff: [StaffMember] = []

    init(name: String, ageGroup: AgeGroup, capacity: Int, colorHex: String = "#4CAF50") {
        self.name = name
        self.ageGroup = ageGroup
        self.capacity = capacity
        self.colorHex = colorHex
    }

    var activeChildrenCount: Int {
        children.filter { $0.isActive }.count
    }

    var presentStaffCount: Int {
        staff.filter { $0.isPresent }.count
    }

    // UK EYFS required ratios: 1:3 babies, 1:4 toddlers, 1:8 pre-school/reception
    var ratioRequired: Int {
        switch ageGroup {
        case .babies:                return 3
        case .toddlers:              return 4
        case .preschool, .reception: return 8
        }
    }

    var ratioOK: Bool {
        guard presentStaffCount > 0 else { return activeChildrenCount == 0 }
        return activeChildrenCount <= presentStaffCount * ratioRequired
    }

    var ratioString: String {
        "1:\(ratioRequired) · \(presentStaffCount) staff / \(activeChildrenCount) children"
    }
}

