//
//  StaffMember.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import Foundation
import SwiftData

enum StaffRole: String, CaseIterable, Codable {
    case settingManager  = "Setting Manager"
    case roomLeader      = "Room Leader"
    case keyworker       = "Keyworker"
    case practitioner    = "Practitioner"
    case apprentice      = "Apprentice"
}

@Model
final class StaffMember {
    var id: UUID = UUID()
    var fullName: String
    var role: StaffRole
    var isPresent: Bool = false
    var arrivalTime: Date?

    var assignedRoom: Room?

    init(fullName: String, role: StaffRole, assignedRoom: Room? = nil) {
        self.fullName = fullName
        self.role = role
        self.assignedRoom = assignedRoom
    }
}

