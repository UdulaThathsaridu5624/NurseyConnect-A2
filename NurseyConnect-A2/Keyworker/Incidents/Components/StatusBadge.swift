//
//  StatusBadge.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

//  StatusBadge.swift — NurseyConnect-A2
import SwiftUI

struct StatusBadge: View {
    let status: IncidentStatus
    var body: some View {
        Text(status.rawValue)
            .font(.system(.caption, design: .rounded, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(Capsule().fill(status.color))
    }
}
