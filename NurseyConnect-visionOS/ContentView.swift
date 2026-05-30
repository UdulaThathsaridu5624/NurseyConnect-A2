//
//  ContentView.swift
//  NurseyConnect-visionOS
//
//  Created by Udula on 2026-05-30.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openWindow)  private var openWindow

    private let rooms = VisionSampleData.rooms
    private let nurseryGreen = Color(nurseryHex: "#2E9E66")

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Header
                HStack(spacing: 14) {
                    Image(systemName: "building.2.crop.circle.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(nurseryGreen)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("NurseyConnect")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                        Text("Setting Manager · Spatial Dashboard")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    ToggleImmersiveSpaceButton()
                }
                .padding(.horizontal, 20).padding(.vertical, 14)

                Divider()

                // Stats bar
                HStack(spacing: 0) {
                    statTile("Present",      "\(VisionSampleData.presentCount)", "person.3.fill",               nurseryGreen)
                    Divider().frame(height: 56)
                    statTile("Rooms",        "\(rooms.count)",                   "door.left.hand.open",          .blue)
                    Divider().frame(height: 56)
                    statTile("Ratio Alerts", "\(VisionSampleData.ratioAlerts)",  "exclamationmark.triangle.fill", VisionSampleData.ratioAlerts > 0 ? .red : .green)
                    Divider().frame(height: 56)
                    statTile("Incidents",    "1",                               "bell.badge.fill",               .orange)
                }
                .padding(.vertical, 8).background(.thinMaterial)

                Divider()

                // Room list
                List(rooms) { room in
                    Button { openWindow(id: "roomDetail", value: room.id) } label: {
                        HStack(spacing: 16) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(room.color).frame(width: 6, height: 50)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(room.name)
                                    .font(.system(.headline, design: .rounded, weight: .semibold))
                                Text(room.ageGroup).font(.subheadline).foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(room.activeChildrenCount) children · \(room.presentStaffCount) staff")
                                    .font(.subheadline).foregroundStyle(.secondary)
                                Text(room.ratioString).font(.caption).foregroundStyle(.secondary)
                            }
                            Image(systemName: room.ratioOK ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundStyle(room.ratioOK ? .green : .red).font(.title3)
                            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4).contentShape(Rectangle())
                    }
                    .buttonStyle(.plain).hoverEffect()
                }
                .listStyle(.insetGrouped)
            }
        }
    }

    private func statTile(_ title: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).font(.title2).foregroundStyle(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(value).font(.system(.title2, design: .rounded, weight: .bold))
                Text(title).font(.caption).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity).padding(.horizontal, 8)
    }
}

#Preview(windowStyle: .automatic) {
    ContentView().environment(AppModel())
}
