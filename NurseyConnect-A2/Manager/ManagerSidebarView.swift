//
//  ManagerSidebarView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import SwiftData

struct ManagerSidebarView: View {
    @Binding var selection: ManagerSection?
    let onExit: () -> Void

    @Query private var reports: [IncidentReport]

    private var pendingCount: Int {
        reports.filter { $0.status == .pendingReview }.count
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(ManagerSection.allCases) { section in
                Label(section.rawValue, systemImage: section.systemImage)
                    .badge(section == .incidents && pendingCount > 0 ? pendingCount : 0)
                    .tag(section)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("NurseyConnect")
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Divider()
                HStack {
                    Image(systemName: "building.2.fill")
                        .foregroundStyle(Color.nurseryPrimary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Little Stars Nursery")
                            .font(.bodySmall.bold())
                        Text("Setting Manager")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(action: onExit) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Change Role")
                }
                .padding(AppSpacing.md)
            }
        }
    }
}
