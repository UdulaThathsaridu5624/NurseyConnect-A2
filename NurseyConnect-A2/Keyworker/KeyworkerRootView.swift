//
//  KeyworkerRootView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import SwiftData

struct KeyworkerRootView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TabView {
            Tab("Daily Diary", systemImage: "book.fill") {
                NavigationStack { DiaryDashboardView() }
            }
            Tab("Incidents", systemImage: "exclamationmark.triangle.fill") {
                NavigationStack { IncidentListView() }
            }
        }
        .tint(Color.nurseryPrimary)
    }
}

#Preview {
    KeyworkerRootView()
        .modelContainer(SampleData.previewContainer)
}
