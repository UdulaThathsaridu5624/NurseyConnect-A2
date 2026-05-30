//
//  VisionModels.swift
//  NurseyConnect-visionOS
//
//  Created by Udula on 2026-05-30.
//

import SwiftUI

// MARK: - Lightweight models (no SwiftData — all in-memory for visionOS prototype)

struct VisionRoom: Identifiable {
    let id: UUID
    let name: String
    let ageGroup: String
    let colorHex: String
    let children: [VisionChild]
    let presentStaffCount: Int
    let ratioRequired: Int

    var activeChildrenCount: Int { children.filter { $0.isActive }.count }

    var ratioOK: Bool {
        guard presentStaffCount > 0 else { return activeChildrenCount == 0 }
        return activeChildrenCount <= presentStaffCount * ratioRequired
    }

    var ratioString: String {
        "1:\(ratioRequired) · \(presentStaffCount) staff / \(activeChildrenCount) children"
    }

    var color: Color { Color(nurseryHex: colorHex) }
}

struct VisionChild: Identifiable {
    let id: UUID
    let fullName: String
    let preferredName: String
    let age: String
    let allergies: [String]
    let isActive: Bool
    let isPresent: Bool

    var initials: String {
        fullName.split(separator: " ").prefix(2)
            .compactMap { $0.first.map(String.init) }.joined()
    }
}

// MARK: - Sample Data

enum VisionSampleData {
    static let rooms: [VisionRoom] = [
        VisionRoom(id: UUID(), name: "Sunshine Room", ageGroup: "Toddlers (1–2)",
                   colorHex: "#FF9800",
                   children: [
                       VisionChild(id: UUID(), fullName: "Emma Johnson",  preferredName: "Emma",  age: "3y",    allergies: ["Peanuts"],       isActive: true, isPresent: true),
                       VisionChild(id: UUID(), fullName: "Oliver Davies", preferredName: "Ollie", age: "2y 4m", allergies: [],                isActive: true, isPresent: true),
                   ],
                   presentStaffCount: 2, ratioRequired: 4),

        VisionRoom(id: UUID(), name: "Rainbow Room", ageGroup: "Babies (0–1)",
                   colorHex: "#9C27B0",
                   children: [
                       VisionChild(id: UUID(), fullName: "Sophia Patel", preferredName: "Sophia", age: "1y 8m", allergies: ["Dairy", "Eggs"], isActive: true, isPresent: true),
                   ],
                   presentStaffCount: 1, ratioRequired: 3),

        VisionRoom(id: UUID(), name: "Star Room", ageGroup: "Pre-school (2–4)",
                   colorHex: "#2196F3",
                   children: [
                       VisionChild(id: UUID(), fullName: "Noah Williams", preferredName: "Noah",   age: "4y 2m", allergies: [],         isActive: true, isPresent: true),
                       VisionChild(id: UUID(), fullName: "Amelia Chen",   preferredName: "Amelia", age: "3y 6m", allergies: ["Gluten"], isActive: true, isPresent: false),
                   ],
                   presentStaffCount: 1, ratioRequired: 8),
    ]

    static var presentCount: Int { rooms.flatMap { $0.children }.filter { $0.isPresent }.count }
    static var ratioAlerts: Int  { rooms.filter { !$0.ratioOK }.count }
}

// MARK: - Colour helper

extension Color {
    init(nurseryHex hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        self.init(red:   Double((int >> 16) & 0xFF) / 255,
                  green: Double((int >> 8)  & 0xFF) / 255,
                  blue:  Double(int & 0xFF) / 255)
    }
}
