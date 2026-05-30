//
//  RatioBadge.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI

struct RatioBadge: View {
    let room: Room

    var body: some View {
        Text(room.ratioOK ? "OK" : "ALERT")
            .font(.system(.caption, design: .rounded, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(Capsule().fill(room.ratioOK ? Color.green : Color.red))
    }
}
