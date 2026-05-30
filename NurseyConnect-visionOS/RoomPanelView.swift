//
//  RoomPanelView.swift
//  NurseyConnect-visionOS
//
//  Created by Udula on 2026-05-30.
//

import SwiftUI

struct RoomPanelView: View {
    let room: VisionRoom
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            // Coloured header
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(room.name)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                    Text(room.ageGroup)
                        .font(.caption).foregroundStyle(.white.opacity(0.85))
                }
                Spacer()
                Image(systemName: room.ratioOK ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .font(.title2).foregroundStyle(.white)
            }
            .padding(16)
            .background(room.color.opacity(0.85))

            // Stats row
            HStack(spacing: 0) {
                panelStat(icon: "figure.child",  value: "\(room.activeChildrenCount)", label: "Children")
                Divider().frame(height: 50)
                panelStat(icon: "person.2.fill", value: "\(room.presentStaffCount)",   label: "Staff")
                Divider().frame(height: 50)
                VStack(spacing: 4) {
                    Image(systemName: room.ratioOK ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(room.ratioOK ? .green : .red)
                    Text(room.ratioOK ? "OK" : "Alert")
                        .font(.caption2)
                        .foregroundStyle(room.ratioOK ? .green : .red)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 12)
            }
            .padding(.horizontal, 8)

            Divider()

            Text(room.ratioString)
                .font(.caption).foregroundStyle(.secondary)
                .padding(.vertical, 8)

            Divider()

            Button {
                openWindow(id: "roomDetail", value: room.id)
            } label: {
                Label("View Children", systemImage: "person.3")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(room.color)
            .padding([.horizontal, .bottom], 12)
        }
        .frame(width: 280)
        .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 20))
        .hoverEffect(.highlight)
        .shadow(color: room.color.opacity(0.3), radius: 20, x: 0, y: 10)
    }

    private func panelStat(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.title2).foregroundStyle(.secondary)
            Text(value).font(.system(.title, design: .rounded, weight: .bold))
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 12)
    }
}
