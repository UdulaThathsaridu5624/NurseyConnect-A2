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

    var body: some View {
        RealityView { content in
            // Anchor the experience to the real floor
            let anchor = AnchorEntity(.plane(.horizontal,
                                             classification: .floor,
                                             minimumBounds: [0.5, 0.5]))
            content.add(anchor)
        }
        .overlay(alignment: .center) {
            roomArc
        }
    }

    @ViewBuilder
    private var roomArc: some View {
        let count  = rooms.count
        let spread = 40.0  // total arc degrees
        let step   = count > 1 ? spread / Double(count - 1) : 0
        let start  = -(spread / 2.0)

        ZStack {
            ForEach(Array(rooms.enumerated()), id: \.element.id) { index, room in
                let angle = (start + Double(index) * step) * .pi / 180
                RoomPanelView(room: room)
                    .rotation3DEffect(.degrees(-(start + Double(index) * step)),
                                      axis: (x: 0, y: 1, z: 0))
                    .offset(x: CGFloat(sin(angle) * 700),
                            z: CGFloat(-cos(angle) * 700) - 100)
            }
        }
        .offset(y: -60)
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView().environment(AppModel())
}
