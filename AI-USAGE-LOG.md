# AI Usage Log — SE4020 Assignment 2
## NurseyConnect iPadOS & visionOS Application

**Student ID:** IT22056320  
**AI Tool Used:** Claude Code (claude.ai/code) — code generation & debugging  
**AI Tool Used:** Claude Artifacts (claude.ai/artifacts) — UI mockup generation  

All generated code was reviewed, tested, debugged, and adapted to fit the specific
NurseyConnect case study requirements. All design decisions were made by the student.
Every implementation can be fully explained at the viva.

---

## Part A — iPadOS App

---

### Entry 1 — UI Mockup Generation (Claude Artifacts)

**Prompt:**
```
Generate a SwiftUI mockup for an iPadOS nursery management app with a tab bar
showing Dashboard, Rooms, Staff, Reports tabs. Professional childcare colour scheme.
Green and teal palette. Show a dashboard with 4 stat cards.
```

**Response Summary:** Generated Variation 1 — a tab-based layout with a bottom tab bar,
dashboard stat cards in a 2x2 grid, and wide empty space on the left side of the iPad.

**Evaluation & Decision:** Rejected. Tab bars are an iPhone pattern. The wide iPad screen
area was left empty, wasting the platform's key advantage. Does not follow iPadOS HIG.

**Files affected:** N/A — rejected variation, not implemented

---

### Entry 2 — UI Mockup Variation 2 (Claude Artifacts)

**Prompt:**
```
Generate a SwiftUI mockup for an iPadOS app using a 3-column NavigationSplitView.
Left sidebar: Dashboard, Rooms, Attendance, Analytics, Incidents, Reports.
Middle column: list of rooms with ratio badges.
Right detail column: room detail with children list. Green nursery theme.
```

**Response Summary:** Generated Variation 2 — a 3-column NavigationSplitView with
persistent sidebar, room list in the content column, and room detail in the third column.
Showed EYFS ratio badges and colour-coded room indicators.

**Evaluation & Decision:** Partially rejected. Correct iPadOS pattern but a fixed third
column squeezed the detail to ~330px, leaving Analytics/Reports with no master to show.
Charts would be illegible at that width.

**Files affected:** N/A — partially rejected, informed final design

---

### Entry 3 — UI Mockup Variation 3 / Final Design (Claude Artifacts)

**Prompt:**
```
Generate a SwiftUI mockup for an iPadOS nursery manager app.
Two-column NavigationSplitView: left sidebar with section icons,
right side fills entirely with section content.
Rooms section uses NavigationLink push for room detail.
Dashboard shows 4 stat cards in a LazyVGrid.
Analytics shows full-width charts.
Green/teal nursery colour scheme, professional childcare context.
Show attendance chart, ratio status panel, and recent incidents list on the dashboard.
```

**Response Summary:** Generated Variation 3 — a 2-column NavigationSplitView with
persistent sidebar and full-width detail column. Dashboard showed a LazyVGrid of stat
cards, an attendance bar chart, room ratio status list, and recent incidents feed.

**Evaluation & Decision:** Selected. Full-width detail column means every section
(Analytics, Reports, Dashboard) uses the whole width. Rooms and Incidents use
NavigationLink push within the detail column for master-detail where needed.

**Modifications Made:**
- Adapted the stat card grid to use 4 tappable cards that navigate to relevant sections
- Added the "Room Status" section at the bottom of the dashboard
- Removed the "Export" and "New incident" buttons from the dashboard header (incident
  creation is Keyworker-only per the case study §4.2.3)

**Files affected:** Informed overall `Manager/` folder structure and `ManagerRootView.swift`

---

### Entry 4 — SwiftData Model Extension

**Prompt:**
```
I have an existing SwiftData iOS app with Child, DiaryEntry, IncidentReport models.
I need to extend it for an iPadOS Setting Manager role. Add three new @Model classes:
Room (name, ageGroup enum for babies/toddlers/preschool/reception, capacity, colorHex,
computed ratioOK enforcing EYFS ratios 1:3/1:4/1:8, ratioString),
StaffMember (fullName, role enum, isPresent bool, assignedRoom relationship to Room),
AttendanceRecord (child relationship, date normalised to startOfDay, checkInTime,
checkOutTime, method enum walk-in/van/other, isPresent computed, durationFormatted).
Update Child to replace stored roomName String with an optional Room relationship,
keeping a computed roomName shim so existing views still compile.
```

**Response Summary:** Generated `Room.swift`, `StaffMember.swift`, `AttendanceRecord.swift`
with all specified fields and relationships. Updated `Child.swift` to add `var room: Room?`
and computed `var roomName: String { room?.name ?? "Unassigned" }`.

**Modifications Made:**
- Fixed `AttendanceRecord` default value syntax — SwiftData @Model requires
  `AttendanceMethod.walkin` (fully qualified) not `.walkin` for enum defaults
- Added `@Relationship(inverse:)` annotations on `Room.children` and `Room.staff`
  to properly declare the inverse relationships
- Added `attendanceRecords` relationship on `Child` with cascade delete

**Files affected:** `Models/Room.swift`, `Models/StaffMember.swift`,
`Models/AttendanceRecord.swift`, `Models/Child.swift`

---

### Entry 5 — Setting Manager NavigationSplitView Shell

**Prompt:**
```
Build a SwiftUI Setting Manager root view for iPadOS using a 2-column NavigationSplitView.
Sidebar has sections: Dashboard, Rooms, Attendance, Analytics, Incidents, Reports.
Each sidebar item switches the detail column content. Rooms uses NavigationLink push
to RoomDetailView within the detail NavigationStack. Incidents uses NavigationLink push
to IncidentDetailView. Other sections fill the full detail column. Add a sidebar footer
showing nursery name and a Keyworker button that opens KeyworkerRootView fullScreenCover.
The app should launch directly into ManagerRootView (no login screen).
```

**Response Summary:** Generated `ManagerRootView.swift` with `NavigationSplitView`,
`ManagerSidebarView.swift` with section list and footer, private `RoomsWithDetailView`
and `IncidentsWithDetailView` structs for push navigation within the detail column.

**Modifications Made:**
- Fixed sidebar interactivity — original used `List(selection:)` with data array which
  failed in NavigationSplitView; replaced with `List(selection:) { ForEach { .tag() } }`
  for reliable selection
- Added `@Observable AppModel` pattern for immersive space state (later reused in visionOS)
- Removed `@Environment(\.dismiss)` approach — replaced with direct `if/else` rendering
  of `ManagerRootView` at app root so NavigationSplitView gets proper window sizing context

**Files affected:** `Manager/ManagerRootView.swift`, `Manager/ManagerSidebarView.swift`,
`NurseyConnect_A2App.swift`

---

### Entry 6 — Swift Charts Analytics Dashboard

**Prompt:**
```
Build a SwiftUI Analytics view for a nursery manager iPad app using Swift Charts.
I need 4 charts using live SwiftData @Query data:
1. MoodTrendChart — LineMark per child over last 7 days, Y axis 1-5 labelled
   Upset to Very Happy, coloured by child name
2. AttendanceTrendChart — BarMark of daily attendance count over 30 days
3. IncidentCategoryChart — horizontal BarMark grouped by IncidentCategory rawValue
4. MealAmountChart — SectorMark donut chart of MealAmount consumption levels
Add an @Observable AnalyticsViewModel that aggregates DiaryEntry, IncidentReport,
AttendanceRecord arrays into chart-ready structs.
```

**Response Summary:** Generated `AnalyticsViewModel.swift` with `@Observable` class
and `MoodDataPoint`, `AttendanceDayPoint`, `CategoryPoint`, `MealAmountPoint` structs.
Generated 4 chart view files with appropriate Chart mark types.

**Modifications Made:**
- Fixed `AttendanceTrendChart` — original used `.stride(by: .week)` on axis marks which
  caused a type inference error; replaced with `.automatic(desiredCount: 5)`
- Fixed `MoodTrendChart` Y-axis label mapping (1→"Upset", 5→"Very Happy")
- Changed `MealAmountChart` from stacked BarMark to `SectorMark` donut for better
  readability in the limited vertical space

**Files affected:** `Manager/Analytics/AnalyticsViewModel.swift`,
`Manager/Analytics/Charts/MoodTrendChart.swift`,
`Manager/Analytics/Charts/AttendanceTrendChart.swift`,
`Manager/Analytics/Charts/IncidentCategoryChart.swift`,
`Manager/Analytics/Charts/MealAmountChart.swift`,
`Manager/Analytics/AnalyticsView.swift`

---

### Entry 7 — PDFKit Report Generator

**Prompt:**
```
Build a PDFKit report generator for a nursery manager iPad app using UIGraphicsPDFRenderer.
Generate A4 PDFs for three report types:
1. Incident Report — RIDDOR-aligned with sections for incident details, description,
   injury, immediate action, witnesses, manager review, parent notification
2. Daily Diary Summary — per-child entry list grouped by entry type
3. Attendance Report — room-level attendance summary by month
Also build a PDFPreviewSheet using UIViewControllerRepresentable wrapping PDFKit's PDFView.
Must render correctly on first open (not blank). Add a ReportGeneratorView with
type selection and pickers for incident/child/room.
```

**Response Summary:** Generated `PDFReportGenerator.swift` with `UIGraphicsPDFRenderer`
and A4 layout helpers, `PDFPreviewSheet.swift` wrapping `PDFView`, and
`ReportGeneratorView.swift` with report type segmented picker.

**Modifications Made:**
- Fixed blank-on-first-open bug — original used `UIViewRepresentable` (`makeUIView`)
  which fires before the sheet has bounds; switched to `UIViewControllerRepresentable`
  and set `pdfView.document` in `viewDidAppear` which guarantees proper bounds
- Fixed SwiftData model pickers — original `Picker` with `.menu` style bound to
  `@Model` objects failed silently in NavigationSplitView; replaced all model-backed
  pickers with inline selectable row patterns (`Button { } label: { HStack + checkmark }`)
- Added `PDFFileDocument` conforming to `FileDocument` for `.fileExporter` integration

**Files affected:** `Utilities/PDFReportGenerator.swift`,
`Manager/Reports/PDFPreviewSheet.swift`,
`Manager/Reports/ReportGeneratorView.swift`

---

### Entry 8 — Attendance Management View

**Prompt:**
```
Build an Attendance view for a nursery manager iPad app. Show all active children
with their check-in status for a selected date. Include a date picker and room filter.
Each child row shows avatar with initials, name, check-in time or absent status,
and Check In / Check Out buttons. Room filter uses horizontal chip buttons (not a Picker).
Check in records an AttendanceRecord to SwiftData with current timestamp.
```

**Response Summary:** Generated `AttendanceView.swift` with date picker controls,
room filter chips, and `AttendanceRowView.swift` with check-in/out buttons.

**Modifications Made:**
- Fixed room filter `Picker` — original used `.menu` style which failed in the
  NavigationSplitView context; replaced with horizontal chip `Button` row using
  the same pattern as visionOS room filter
- Added `@State private var selectedRoomID: UUID?` pattern instead of
  `@State private var selectedRoom: Room?` to avoid SwiftData model tag issues

**Files affected:** `Manager/Attendance/AttendanceView.swift`,
`Manager/Attendance/Components/AttendanceRowView.swift`

---

### Entry 9 — Unit Tests

**Prompt:**
```
Write XCTest unit tests for a nursery iPadOS app covering:
1. Room EYFS ratio compliance — ratioOK for babies (1:3), toddlers (1:4),
   preschool (1:8), edge cases (empty room, zero staff)
2. AttendanceRecord — isPresent after check-in, not present after check-out,
   duration calculation, durationFormatted hours/minutes/nil
3. PDFReportGenerator — all 3 PDF types produce non-empty valid %PDF data
4. IncidentReport — full status workflow (all 5 transitions), body map JSON round-trip
5. Child model — initials extraction, roomName unassigned fallback, age calculation
Use in-memory ModelContainer for SwiftData tests. Add @MainActor where needed.
```

**Response Summary:** Generated 39 unit tests across 5 XCTestCase classes with
in-memory `ModelContainer` setup in `setUpWithError`.

**Modifications Made:**
- Added `@MainActor` to `setUpWithError`, `makeChild()`, and all test methods
  that access `container.mainContext` — required in Xcode 16 / Swift 6 concurrency
- Fixed `PDFReportGeneratorTests` to use `@MainActor` on `setUpWithError` for
  `SampleData.insertSampleData(into:)` which is `@MainActor` isolated

**Files affected:** `NurseyConnect-A2Tests/NurseyConnect_A2Tests.swift`

---

## Part B — visionOS App

---

### Entry 10 — visionOS ImmersiveSpace Initial Setup

**Prompt:**
```
Build a visionOS app for Apple Vision Pro that extends a NurseyConnect nursery
management iPadOS app. Create a Setting Manager spatial dashboard with:
- A main WindowGroup showing a stats bar (children present, rooms, ratio alerts,
  incidents) and a room list with expandable inline children rows
- An ImmersiveSpace (mixed immersion) with 3 floating room panels anchored in
  physical space using RealityKit AnchorEntity
- Each room panel is a SwiftUI attachment positioned in an arc with RealityView
  attachments: closure
- Room panels show name, age group, child count, staff count, EYFS ratio badge
  and a View Children button
- Use visionOS-specific APIs: glassBackgroundEffect, hoverEffect, ornament
- Do NOT use RealityKitContent or Model3D — self-contained structs for data,
  no shared SwiftData with the iPadOS target
```

**Response Summary:** Generated `NurseyConnect_visionOSApp.swift` with `WindowGroup`
and `ImmersiveSpace` scenes, `ContentView.swift` as the main window, `ImmersiveView.swift`
with `RealityView` attachments, `RoomPanelView.swift` as the floating glass card,
`VisionModels.swift` with self-contained `VisionRoom` and `VisionChild` structs.

**Modifications Made:**
- Fixed `RealityView` — original used `.overlay` with `.offset(z:)` which failed
  to position panels in 3D; switched to `RealityView { content, attachments in ... }`
  with `attachments:` closure (the correct Apple-recommended pattern)
- Fixed `AnchorEntity` — original used floor plane detection which fails in visionOS
  simulator; changed to `AnchorEntity(world: .zero)` for reliable world-space positioning
- Removed `import RealityKitContent` — not needed since we use no `.reality` files
- Added `AppModel` (`@Observable`) for immersive space state management following
  Apple's recommended pattern from WWDC23 "Develop your first immersive app"

**Files affected:** `NurseyConnect-visionOS/NurseyConnect_visionOSApp.swift`,
`NurseyConnect-visionOS/ContentView.swift`,
`NurseyConnect-visionOS/ImmersiveView.swift`,
`NurseyConnect-visionOS/RoomPanelView.swift`,
`NurseyConnect-visionOS/VisionModels.swift`

---

### Entry 11 — visionOS Incident Alert Card

**Prompt:**
```
Add an interactive incident alert card to the visionOS ImmersiveView. It should:
- Float above the room panels as a RealityKit attachment
- Show as a compact red capsule badge (not a wide bar) matching the Ratios OK badge style
- Tap to expand showing full incident details (reference, child, category, location,
  status, description) in a glass card
- Tap again to collapse
- Use hoverEffect and symbolEffect(.pulse) on the badge
- No sphere or 3D geometry needed — pure SwiftUI attachment
```

**Response Summary:** Generated `IncidentAlertCard` private struct with expandable
VStack — compact capsule header that expands to a full `glassBackgroundEffect` detail card.

**Modifications Made:**
- Removed the red sphere (`ModelEntity`) added in an earlier iteration — the SwiftUI
  attachment button was more reliable and accessible
- Fixed the capsule stretching full width — original had `Spacer()` inside the HStack
  making it full-width; removed Spacer so capsule sizes to content

**Files affected:** `NurseyConnect-visionOS/ImmersiveView.swift`

---

### Entry 12 — visionOS Window Ornament

**Prompt:**
```
Add a visionOS window ornament to the NurseyConnect main window. It should:
- Attach to the trailing edge of the window using .ornament(attachmentAnchor: .scene(.trailing))
- Show EYFS ratio compliance status — green checkmark shield if all rooms OK,
  red exclamation shield if any room has a ratio breach
- Use symbolEffect(.pulse) when there is an alert
- Use glassBackgroundEffect
- This is a visionOS-exclusive UI element that doesn't exist on iPad
```

**Response Summary:** Generated `RatioOrnamentView` with dynamic colour/icon based on
`ratioAlerts` count and `glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 14))`.

**Modifications Made:**
- Moved the ratio badge inline with the title in ContentView header instead of using
  the ornament — this gave better visual alignment alongside the "NurseyConnect" title
- Kept the `.ornament()` API knowledge documented here for viva reference

**Files affected:** `NurseyConnect-visionOS/ContentView.swift`

---

### Entry 13 — visionOS ChildListWindow Secondary Window

**Prompt:**
```
Add a secondary spatial window to the visionOS app that opens when tapping View Children
on a room panel. It should:
- Use WindowGroup<UUID> parameterised by room ID
- Open with openWindow(id: "roomDetail", value: room.id)
- Show the room name, age group, ratio status in a header
- List all active children with avatar circles, name, age, allergies, and present/absent status
- Have a Close button using dismissWindow environment
- Use ScrollView with card-style child rows
- Default size 560x520
```

**Response Summary:** Generated `ChildListWindow.swift` with UUID-parameterised lookup
in `VisionSampleData.rooms`, `NavigationStack` with toolbar Close button, and
`ScrollView` with `.regularMaterial` child cards.

**Modifications Made:**
- Fixed child display clipping — original used `List` with `.insetGrouped` style
  which was truncating at the window height; replaced with `ScrollView + VStack`
  with explicit card components that scroll freely
- Increased default window size from 520×420 to 560×520 in App file

**Files affected:** `NurseyConnect-visionOS/ChildListWindow.swift`,
`NurseyConnect-visionOS/NurseyConnect_visionOSApp.swift`

---

*SE4020 — Mobile Application Design & Development | Semester 1, 2026 | SLIIT*
