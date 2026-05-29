//
//  ChildDiaryView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//
import SwiftUI
import SwiftData

struct ChildDiaryView: View {
    let child: Child
    let date: Date

    @Environment(\.modelContext) private var modelContext
    @State private var showingEntryTypePicker = false
    @State private var selectedEntryType: DiaryEntryType?

    private var entriesForDate: [DiaryEntry] {
        child.diaryEntries(for: date).sorted { $0.timestamp < $1.timestamp }
    }

    private func entries(for type: DiaryEntryType) -> [DiaryEntry] {
        entriesForDate.filter { $0.entryType == type }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if entriesForDate.isEmpty {
                    ContentUnavailableView {
                        Label("No Entries Yet", systemImage: "book.closed")
                    } description: {
                        Text("Tap + to add the first entry for \(child.preferredName) today.")
                    }
                } else {
                    List {
                        ForEach(DiaryEntryType.allCases) { type in
                            let typeEntries = entries(for: type)
                            if !typeEntries.isEmpty {
                                Section {
                                    ForEach(typeEntries) { entry in
                                        DiaryEntryRow(entry: entry)
                                            .listRowBackground(Color.nurseryCard)
                                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                                Button(role: .destructive) {
                                                    modelContext.delete(entry)
                                                } label: { Label("Delete", systemImage: "trash") }
                                            }
                                    }
                                } header: {
                                    Label(type.rawValue, systemImage: type.systemImage)
                                        .foregroundStyle(type.color)
                                        .font(.sectionHead)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }

            Button { showingEntryTypePicker = true } label: {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.nurseryPrimary)
                    .clipShape(Circle())
                    .shadow(color: Color.nurseryPrimary.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(FABButtonStyle())
            .padding(AppSpacing.lg)
            .keyboardShortcut("n", modifiers: .command)
        }
        .navigationTitle(child.preferredName)
        .navigationBarTitleDisplayMode(.large)
        .background(Color.nurseryBackground)
        .sheet(isPresented: $showingEntryTypePicker) {
            EntryTypePicker(selectedType: $selectedEntryType)
        }
        .sheet(item: $selectedEntryType) { type in
            switch type {
            case .activity: ActivityEntryForm(child: child)
            case .sleep:    SleepEntryForm(child: child)
            case .meal:     MealEntryForm(child: child)
            case .nappy:    NappyEntryForm(child: child)
            case .mood:     MoodEntryForm(child: child)
            }
        }
    }
}

#Preview {
    let container = SampleData.previewContainer
    let child = try! container.mainContext.fetch(FetchDescriptor<Child>()).first!
    return NavigationStack { ChildDiaryView(child: child, date: .now) }
        .modelContainer(container)
}
