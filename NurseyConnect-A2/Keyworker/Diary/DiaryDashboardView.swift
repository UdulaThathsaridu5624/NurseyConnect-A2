//
//  DiaryDashboardView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//
import SwiftUI
import SwiftData

struct DiaryDashboardView: View {
    @Query(sort: \Child.fullName) private var children: [Child]
    @State private var selectedDate: Date = .now
    @State private var selectedChild: Child?

    let columns = [GridItem(.adaptive(minimum: 160), spacing: AppSpacing.md)]

    private var activeChildren: [Child] { children.filter { $0.isActive } }

    var body: some View {
        Group {
            if activeChildren.isEmpty {
                ContentUnavailableView("No Children Assigned", systemImage: "person.2.slash",
                    description: Text("No active children are currently assigned to you."))
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                        ForEach(Array(activeChildren.enumerated()), id: \.element.id) { index, child in
                            ChildCard(child: child, date: selectedDate, index: index)
                                .onTapGesture { selectedChild = child }
                        }
                    }
                    .padding(AppSpacing.md)
                }
                .background(Color.nurseryBackground)
            }
        }
        .navigationTitle("Daily Diary")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .labelsHidden()
                    .tint(Color.nurseryPrimary)
            }
        }
        .navigationDestination(item: $selectedChild) { child in
            ChildDiaryView(child: child, date: selectedDate)
        }
    }
}

#Preview {
    NavigationStack { DiaryDashboardView() }
        .modelContainer(SampleData.previewContainer)
}
