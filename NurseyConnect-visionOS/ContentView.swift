//
//  ContentView.swift
//  NurseyConnect-visionOS
//
//  Created by Udula on 2026-05-30.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var appModel

    private let rooms = VisionSampleData.rooms
    private let nurseryGreen = Color(nurseryHex: "#2E9E66")

    @State private var expandedRoomID: UUID? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Header
                HStack(spacing: 14) {
                    Image(systemName: "building.2.crop.circle.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(nurseryGreen)
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 10) {
                            Text("NurseyConnect")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                            // Ratio compliance badge — inline with title
                            let allOK = VisionSampleData.ratioAlerts == 0
                            Label(allOK ? "Ratios OK" : "\(VisionSampleData.ratioAlerts) Alert",
                                  systemImage: allOK ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                                .font(.system(.caption, design: .rounded, weight: .bold))
                                .foregroundStyle(allOK ? .white : .white)
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(allOK ? Color.green : Color.red, in: Capsule())
                                .symbolEffect(.pulse, isActive: !allOK)
                        }
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
                    statTile("Incidents",    "1",                                "bell.badge.fill",               .orange)
                }
                .padding(.vertical, 8)
                .background(.thinMaterial)

                Divider()

                // Room list with expandable children
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(rooms) { room in
                            VStack(spacing: 0) {
                                // Room row — tap to expand
                                Button {
                                    withAnimation(.spring(response: 0.35)) {
                                        expandedRoomID = expandedRoomID == room.id ? nil : room.id
                                    }
                                } label: {
                                    HStack(spacing: 14) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(room.color)
                                            .frame(width: 6, height: 52)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(room.name)
                                                .font(.system(.headline, design: .rounded, weight: .semibold))
                                            Text(room.ageGroup)
                                                .font(.subheadline).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("\(room.activeChildrenCount) children")
                                                .font(.subheadline).foregroundStyle(.secondary)
                                            Text(room.ratioString)
                                                .font(.caption).foregroundStyle(.secondary)
                                        }
                                        Image(systemName: room.ratioOK ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                            .foregroundStyle(room.ratioOK ? .green : .red)
                                            .font(.title3)
                                        Image(systemName: expandedRoomID == room.id ? "chevron.up" : "chevron.down")
                                            .font(.caption).foregroundStyle(.secondary)
                                    }
                                    .padding(.horizontal, 16).padding(.vertical, 10)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .hoverEffect()

                                // Expanded children list
                                if expandedRoomID == room.id {
                                    Divider().padding(.horizontal, 16)
                                    VStack(spacing: 0) {
                                        ForEach(room.children.filter { $0.isActive }) { child in
                                            HStack(spacing: 14) {
                                                Circle()
                                                    .fill(LinearGradient(
                                                        colors: [nurseryGreen, Color(nurseryHex: "#269BB5")],
                                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                                                    .frame(width: 40, height: 40)
                                                    .overlay {
                                                        Text(child.initials)
                                                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                                                            .foregroundStyle(.white)
                                                    }
                                                VStack(alignment: .leading, spacing: 3) {
                                                    Text(child.preferredName)
                                                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                                    if !child.allergies.isEmpty {
                                                        Label(child.allergies.joined(separator: ", "),
                                                              systemImage: "allergens")
                                                            .font(.caption).foregroundStyle(.orange)
                                                    }
                                                }
                                                Spacer()
                                                Text(child.age)
                                                    .font(.caption).foregroundStyle(.secondary)
                                                Label(child.isPresent ? "Present" : "Absent",
                                                      systemImage: child.isPresent ? "checkmark.circle.fill" : "xmark.circle")
                                                    .font(.caption)
                                                    .foregroundStyle(child.isPresent ? .green : .secondary)
                                            }
                                            .padding(.horizontal, 20).padding(.vertical, 10)
                                            if child.id != room.children.filter({ $0.isActive }).last?.id {
                                                Divider().padding(.leading, 74)
                                            }
                                        }
                                    }
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(16)
                }
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

// MARK: - Window Ornament (visionOS-exclusive — attaches to the window edge)

struct RatioOrnamentView: View {
    private let rooms = VisionSampleData.rooms

    private var alertCount: Int { rooms.filter { !$0.ratioOK }.count }
    private var allOK: Bool { alertCount == 0 }

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: allOK ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                .font(.system(size: 26))
                .foregroundStyle(allOK ? .green : .red)
                .symbolEffect(.pulse, isActive: !allOK)

            Text(allOK ? "Ratios OK" : "\(alertCount) Alert\(alertCount > 1 ? "s" : "")")
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .foregroundStyle(allOK ? .green : .red)

            Text("EYFS")
                .font(.system(size: 9, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview(windowStyle: .automatic) {
    ContentView().environment(AppModel())
}
