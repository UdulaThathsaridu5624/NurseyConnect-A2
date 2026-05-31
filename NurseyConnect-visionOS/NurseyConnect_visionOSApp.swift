//
//  NurseyConnect_visionOSApp.swift
//  NurseyConnect-visionOS
//
//  Created by Udula on 2026-05-30.
//

import SwiftUI

@main
struct NurseyConnect_visionOSApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .defaultSize(width: 900, height: 650)

        WindowGroup("Room Detail", id: "roomDetail", for: UUID.self) { $roomID in
            ChildListWindow(roomID: roomID ?? UUID())
                .environment(appModel)
        }
        .defaultSize(width: 560, height: 520)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear  { appModel.immersiveSpaceState = .open }
                .onDisappear { appModel.immersiveSpaceState = .closed }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
