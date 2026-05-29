//
//  KeyworkerRootView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import SwiftData

struct KeyworkerRootView: View {
    var onChangeRole: (() -> Void)? = nil

    var body: some View {
        TabView {
            Tab("Daily Diary", systemImage: "book.fill") {
                NavigationStack {
                    DiaryDashboardView()
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Change Role") { onChangeRole?() }
                                    .tint(Color.nurseryPrimary)
                            }
                        }
                }
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
