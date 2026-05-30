//
//  NurseyConnect_A2App.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import SwiftData

@main
struct NurseyConnect_A2App: App {

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Child.self,
            DiaryEntry.self,
            IncidentReport.self,
            Room.self,
            StaffMember.self,
            AttendanceRecord.self,
        ])
        let isUITesting = CommandLine.arguments.contains("--uitesting")
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isUITesting)
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            let context = container.mainContext
            let childCount = (try? context.fetchCount(FetchDescriptor<Child>())) ?? 0
            if childCount == 0 || isUITesting {
                SampleData.insertSampleData(into: context)
            }
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ManagerRootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
