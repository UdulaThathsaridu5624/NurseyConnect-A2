//
//  ImmersiveView.swift
//  NurseyConnect-visionOS
//
//  Created by Udula on 2026-05-30.
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel
    private let rooms = VisionSampleData.rooms
    @State private var showIncidentDetail = false

    // Tight row — all 3 panels close and comfortable, slight arc facing user
    private func panelPosition(index: Int) -> SIMD3<Float> {
        let x: [Float] = [-1.0, 0.0, 1.0]
        let z: [Float] = [-1.6, -1.8, -1.6]
        return SIMD3<Float>(x[safe: index] ?? 0, 1.4, z[safe: index] ?? -1.8)
    }

    private func panelRotation(index: Int) -> simd_quatf {
        let angles: [Float] = [-0.2, 0.0, 0.2]
        return simd_quatf(angle: angles[safe: index] ?? 0, axis: [0, 1, 0])
    }

    var body: some View {
        RealityView { content, attachments in
            let anchor = AnchorEntity(world: .zero)
            content.add(anchor)

            // Room panels — tight comfortable row
            for (index, room) in rooms.enumerated() {
                guard let panel = attachments.entity(for: room.id) else { continue }
                panel.position = panelPosition(index: index)
                panel.orientation = panelRotation(index: index)
                anchor.addChild(panel)
            }

            // Incident card — centred above the panels
            if let card = attachments.entity(for: "incidentCard") {
                card.position = SIMD3<Float>(0, 2.1, -1.8)
                anchor.addChild(card)
            }

        } attachments: {
            // Room panels
            ForEach(rooms) { room in
                Attachment(id: room.id) {
                    RoomPanelView(room: room)
                }
            }

            // Incident card — always visible, fully interactive SwiftUI
            Attachment(id: "incidentCard") {
                IncidentAlertCard(
                    isExpanded: $showIncidentDetail,
                    onToggle: { withAnimation { showIncidentDetail.toggle() } }
                )
            }
        }
    }
}

// MARK: - Incident Alert Card

private struct IncidentAlertCard: View {
    @Binding var isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header — always visible, tap to expand
            Button(action: onToggle) {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title3).foregroundStyle(.white)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("1 Pending Incident")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                        Text(isExpanded ? "Tap to collapse" : "Tap to review")
                            .font(.caption2).foregroundStyle(.white.opacity(0.8))
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption).foregroundStyle(.white.opacity(0.8))
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(.red.opacity(0.85), in: Capsule())
            }
            .buttonStyle(.plain)
            .hoverEffect()

            // Expanded detail
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    detailRow("Reference", "INC-20260529-001")
                    detailRow("Child",     "Oliver Davies")
                    detailRow("Type",      "Fall — Minor")
                    detailRow("Location",  "Sunshine Room")
                    detailRow("Reported",  "Sarah Mitchell")
                    detailRow("Status",    "⏳ Pending Review")

                    Text("Immediate action taken: Child comforted. No visible injury. Alert and responsive.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .frame(width: 320)
                .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 16))
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                .padding(.top, 8)
            }
        }
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption).foregroundStyle(.secondary)
                .frame(width: 75, alignment: .leading)
            Text(value)
                .font(.caption.bold())
        }
    }
}

// MARK: - Safe array subscript helper

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView().environment(AppModel())
}
