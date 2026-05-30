//
//  AttendanceRowView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI

struct AttendanceRowView: View {
    let child: Child
    let record: AttendanceRecord?
    let onCheckIn: () -> Void
    let onCheckOut: () -> Void

    private var statusColor: Color {
        guard let rec = record else { return .secondary }
        return rec.isPresent ? .green : .gray
    }

    private var statusLabel: String {
        guard let rec = record else { return "Not arrived" }
        if rec.isPresent, let t = rec.checkInTime {
            return "In since \(t.formatted(date: .omitted, time: .shortened))"
        }
        if let out = rec.checkOutTime, let inn = rec.checkInTime {
            return "Left · \(inn.formatted(date: .omitted, time: .shortened))–\(out.formatted(date: .omitted, time: .shortened))"
        }
        return "Not arrived"
    }

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Circle()
                .fill(LinearGradient.nurseryAvatar)
                .frame(width: 44, height: 44)
                .overlay { Text(child.initials).font(.cardTitle).foregroundStyle(.white) }

            VStack(alignment: .leading, spacing: 3) {
                Text(child.preferredName).font(.cardTitle)
                HStack(spacing: AppSpacing.xs) {
                    Circle().fill(statusColor).frame(width: 7, height: 7)
                    Text(statusLabel).font(.bodySmall).foregroundStyle(.secondary)
                }
            }

            Spacer()

            if record == nil {
                Button("Check In", action: onCheckIn)
                    .buttonStyle(.borderedProminent)
                    .tint(Color.nurseryPrimary)
                    .controlSize(.small)
            } else if record?.isPresent == true {
                Button("Check Out", action: onCheckOut)
                    .buttonStyle(.bordered)
                    .tint(Color.nurseryAccent)
                    .controlSize(.small)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }
}
