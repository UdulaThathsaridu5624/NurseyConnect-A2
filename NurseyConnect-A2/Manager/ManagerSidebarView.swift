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

    @Query private var reports: [IncidentReport]
    @State private var showingKeyworker = false

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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingKeyworker = true
                } label: {
                    Label("Keyworker", systemImage: "person.fill")
                }
                .tint(Color.nurseryPrimary)
                .help("Switch to Keyworker View")
            }
        }
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
                }
                .padding(AppSpacing.md)
            }
        }
        .fullScreenCover(isPresented: $showingKeyworker) {
            KeyworkerRootView(onChangeRole: { showingKeyworker = false })
        }
    }
}
