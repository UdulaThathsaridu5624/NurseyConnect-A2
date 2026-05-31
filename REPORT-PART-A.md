# SE4020 Assignment 2 — Part A Report
## NurseyConnect iPadOS Application

**Student ID:** IT22056320  
**Module:** SE4020 — Mobile Application Design and Development  
**Year:** 4, Semester 1, 2026  

---

## Demo Video

▶️ [Watch Part A Demo — NurseyConnect iPadOS](https://drive.google.com/file/d/1Wnc3PbqnJqt5817kuTgHVF5o1x-u51l3/view?usp=sharing)

> Setting Manager dashboard, Rooms with drag & drop, Attendance check-in/out,
> Analytics charts (Swift Charts), PDF report generation (PDFKit),
> Incident review workflow, and Keyworker role carried forward from Assignment 1.

---

## 1. Introduction & Extension from Assignment 1

Assignment 1 implemented the **Keyworker role** — daily diary logging (activity, sleep,
meal, nappy, mood entries) and RIDDOR-aligned incident reporting with an interactive
body map. The app used SwiftData for persistence with two tabs: Daily Diary and Incidents.

Assignment 2 extends this with the **Setting Manager role**, selected because it represents
the complementary oversight function described in the NurseryConnect case study (§4.2.2).
The Setting Manager requires aggregate visibility across all rooms — the opposite of the
Keyworker's child-level focus. This also demonstrates UK GDPR **data minimisation**
(Article 5): Managers see operational aggregate data; Keyworkers see only their assigned children.

### What is NEW in Assignment 2
- Setting Manager role with 6 sections: Dashboard, Rooms, Attendance, Analytics, Reports, Incidents
- 3 new SwiftData models: `Room`, `StaffMember`, `AttendanceRecord`
- Swift Charts integration (4 analytical charts)
- PDFKit integration (3 Ofsted-ready PDF report types)
- iPadOS NavigationSplitView, drag & drop, keyboard shortcuts
- 39 automated unit tests

### Carried Forward from Assignment 1
- Complete Keyworker role (all 5 diary entry forms, 4-step incident wizard, interactive body map)
- Models: `Child`, `DiaryEntry`, `IncidentReport` with all enums and computed properties
- Custom nursery theme (AppTheme.swift — PrimaryGreen, PrimaryTeal, AccentOrange)

---

## 2. AI-Driven UI Design Process

### Tool Selection

**Tool used:** Claude AI (claude.ai/artifacts)

**Justification:** Claude was selected over image-only tools (Midjourney, DALL-E) because
it generates complete SwiftUI code alongside visual mockups. This allows direct evaluation
of whether the proposed layout is technically achievable in SwiftUI. Claude Artifacts renders
live interactive UI previews, making design decisions more concrete than static images.
It also understands iOS/iPadOS HIG conventions, which image generators do not.

---

### Mockup Variation 1 — Tab-Based Layout (Rejected)

**Prompt used:**
> "Generate a SwiftUI mockup for an iPadOS nursery management app with a tab bar
> showing Dashboard, Rooms, Staff, Reports tabs. Professional childcare colour scheme."

![Mockup Variation 1 - Tab Based Layout](https://drive.google.com/uc?export=view&id=1XXP88sMBUJgUkzl21uw307qTXgltiDV8)
*Figure 1: Variation 1 — Tab-Based Layout (Rejected)*

**Evaluation:**

| Criterion | Assessment |
|---|---|
| iPadOS conventions | ❌ Tab bars are an iPhone pattern — inappropriate for iPad |
| Screen utilisation | ❌ Wastes the wide left area of the iPad screen |
| Platform-specific features | ❌ No NavigationSplitView or persistent sidebar |
| Nursery context | ✅ Correct colour scheme and terminology |

**Decision: Rejected** — does not follow iPadOS HIG. Tab bars belong on iPhone,
not iPad where sidebar navigation is the standard. The wide iPad screen area is
left completely empty, wasting the platform's key advantage.

---

### Mockup Variation 2 — Three-Column NavigationSplitView (Partially Rejected)

**Prompt used:**
> "Generate a SwiftUI mockup for an iPadOS app using a 3-column NavigationSplitView.
> Left sidebar: Dashboard, Rooms, Attendance, Analytics, Incidents, Reports.
> Middle column: list of rooms with ratio badges.
> Right detail column: room detail with children list. Green nursery theme."

![Mockup Variation 2 - Three Column NavigationSplitView](https://drive.google.com/uc?export=view&id=1lC5E_-Y0vzWNQAPcXu-H1nrwLq_EbX6W)
*Figure 2: Variation 2 — Three-Column NavigationSplitView (Partially Rejected)*

**Evaluation:**

| Criterion | Assessment |
|---|---|
| iPadOS conventions | ✅ Correct use of NavigationSplitView |
| Persistent navigation | ✅ Sidebar always visible |
| Detail column usage | ❌ Most sections (Analytics, Reports) have no detail — third column empty |
| Chart legibility | ❌ Detail column too narrow (~330px) for analytics charts |
| Nursery context | ✅ Appropriate content structure with ratio indicators |

**Decision: Partially rejected** — correct navigation pattern but three columns creates
dead space for non-master-detail sections like Analytics and Reports. The fixed third
column compresses chart views to illegibility.

---

### Mockup Variation 3 — Two-Column NavigationSplitView (Selected)

**Prompt used:**
> "Generate a SwiftUI mockup for an iPadOS nursery manager app.
> Two-column NavigationSplitView: left sidebar with section icons,
> right side fills entirely with section content.
> Rooms section uses NavigationLink push for room detail.
> Dashboard shows 4 stat cards in a LazyVGrid.
> Analytics shows full-width charts.
> Green/teal nursery colour scheme, professional childcare context."

![Mockup Variation 3 - Two Column NavigationSplitView](https://drive.google.com/uc?export=view&id=1-XGo91MEZEalt39eavT5vkZgeW_A-Or0)
*Figure 3: Variation 3 — Two-Column NavigationSplitView (Selected)*

**Evaluation:**

| Criterion | Assessment |
|---|---|
| iPadOS conventions | ✅ Standard iPad sidebar + detail pattern |
| Screen utilisation | ✅ Full detail column width for every section |
| Analytics legibility | ✅ Full-width charts render clearly |
| Rooms navigation | ✅ NavigationLink push within detail column |
| Nursery context | ✅ Professional, appropriate colour use |
| Adaptability | ✅ LazyVGrid stat cards respond to screen size |

**Decision: Selected**

### Design Decision Rationale

Variation 3 was selected because sections like Analytics require the full detail column
width to render 4 charts legibly. Forcing a third column would compress charts to
illegibility. The two-column approach also means the sidebar is always visible, giving
the Setting Manager persistent access to all sections without losing context. For the
Rooms and Incidents sections that do require master-detail navigation, `NavigationLink`
push is used within the single detail column — giving the master-detail experience
where it makes sense without imposing it everywhere.

---

## 3. Final Implementation

The implemented app follows Variation 3 closely. Below is a screenshot of the actual
Attendance section showing the two-column NavigationSplitView in the iPad Air 13"
simulator:

![Final Implementation - Actual App](https://drive.google.com/uc?export=view&id=1TyhRMopLGh7WtQT1xd4Ts3ctGwsrTmNu)
*Figure 4: Final implementation — Attendance section showing NavigationSplitView*

---

## 4. Platform-Specific Features

### NavigationSplitView
The Manager uses a 2-column `NavigationSplitView` with `.balanced` style. The sidebar
lists all 6 sections; the detail column adapts per section. This is the canonical iPad
navigation pattern recommended by Apple HIG and does not exist on iPhone.

### Drag & Drop
Children can be reassigned between rooms by dragging their card. `ChildRoomCard` uses
`.draggable(child.id.uuidString)`. Drop targets are registered on both `RoomDetailView`
and room list rows using `.dropDestination(for: String.self)`. A visual `+` indicator
appears on the target row when a drag hovers over it. A "Move to Room" button provides
the same function for accessibility and simulator testing.

### Keyboard Shortcuts
`Cmd+N` opens a new incident form; `Cmd+P` triggers PDF generation in the Reports
section. These are wired via `.keyboardShortcut()` modifiers on the relevant buttons.

---

## 5. Advanced Library Integration

### Swift Charts

Four chart components under `Manager/Analytics/Charts/`:

| Chart | Type | Data Source |
|---|---|---|
| MoodTrendChart | `LineMark` per child | Mood entries over last 7 days |
| AttendanceTrendChart | `BarMark` | Daily attendance over 30 days |
| IncidentCategoryChart | Horizontal `BarMark` | Incidents grouped by category |
| MealAmountChart | `SectorMark` donut | Meal consumption levels |

All charts consume live SwiftData via `@Query` in `AnalyticsView`. The
`AnalyticsViewModel` (`@Observable`) aggregates raw model data into chart-ready
structs, separating data transformation from presentation.

**Value added:** Directly addresses case study §4.2.2: *"Reviews daily attendance,
meal consumption, and sleep data across all rooms."*

### PDFKit

`PDFReportGenerator` uses `UIGraphicsPDFRenderer` to produce A4 PDF data for three
report types:

- **Incident Report** — RIDDOR-aligned layout (satisfies FR29)
- **Daily Diary Summary** — per-child entry record
- **Attendance Report** — room-level attendance by month

`PDFPreviewSheet` wraps PDFKit's `PDFView` in a `UIViewControllerRepresentable`
(not `UIViewRepresentable`). This was necessary because `viewDidAppear` is required
to call `autoScales` after the view has proper bounds — `makeUIView` alone runs too
early during sheet animation and produces a blank render on first open.

**Value added:** Directly satisfies FR29: *"RIDDOR-aligned incident log exportable
as PDF for Ofsted inspections."*

---

## 6. Architecture & Code Quality

**SwiftData** is used for all persistence. Six `@Model` classes: `Child`, `DiaryEntry`,
`IncidentReport`, `Room`, `StaffMember`, `AttendanceRecord`. Cascade delete rules
prevent orphaned records.

**MVVM:** `AnalyticsViewModel` (`@Observable`) handles chart data aggregation.
Simple CRUD views use `@Query` directly — adding ViewModels for these would be
unnecessary abstraction. This follows SwiftUI's recommendation of using ViewModels
only where meaningful state transformation is needed.

**Role separation** is enforced at the UI layer. The Manager has no navigation route
to individual diary entries. The Keyworker cannot access room management or analytics.
This implements GDPR data minimisation at the application architecture level.

---

## 7. Testing

39 automated unit tests passing across 5 test classes (`⌘U` in Xcode):

| Test Class | Tests | What it verifies |
|---|---|---|
| `RoomTests` | 10 | EYFS ratios (1:3/1:4/1:8), edge cases (empty room, zero staff) |
| `AttendanceRecordTests` | 8 | `isPresent`, duration calculation, formatting, date normalisation |
| `PDFReportGeneratorTests` | 6 | All 3 PDF types produce valid `%PDF` header data |
| `IncidentReportTests` | 5 | Full status workflow, body map JSON round-trip |
| `ChildModelTests` | 5 | Initials, roomName shim, age calculation, empty diary |

Manual testing performed on iPad Air 13" simulator. Edge cases tested: empty rooms,
no staff on duty, nil attendance durations, children with no room assigned,
generating PDFs with no data.

---

## 8. Regulatory Compliance

### UK GDPR Article 5 — Data Minimisation
The Manager role sees aggregate statistics only. Individual child health data, diary
entries, and personal details are only accessible via the Keyworker role. Role
separation is enforced at the UI layer — the Manager has no navigation route to
individual diary entries.

### EYFS Staff:Child Ratios (§3.3)
`Room.ratioOK` enforces statutory ratios:
- **Babies (0–1):** 1:3
- **Toddlers (1–2):** 1:4
- **Pre-school/Reception (2–5):** 1:8

The Dashboard shows a "Ratio Alerts" counter; room badges turn red when breached.
Unit tests verify all four age groups and edge cases.

### RIDDOR-Aligned PDF (FR29)
The incident PDF includes reference number, child details, injury description,
immediate action, witnesses, manager review, and parent notification — all fields
required by RIDDOR 2013 and EYFS statutory framework.

### UK GDPR Article 25 — Data Protection by Design
In production, Face ID/Touch ID via `LocalAuthentication` would be added before
any data is accessible. The assignment prohibits login screens, so this is
acknowledged as a production deployment requirement.

---

## 9. Challenges

### SwiftData Picker Failure
`Picker` with `.menu` style bound to `@Model` objects fails silently inside
`Form` + `NavigationSplitView`. Selection taps registered visually but state
never updated. Diagnosed as a known SwiftUI/SwiftData interaction issue in
nested navigation containers. Resolved by replacing all model-backed pickers
with explicit `Menu { Button }` constructs that set state directly via closures,
and inline selectable row patterns for multi-option selections.

### PDFKit Blank on First Open
`PDFView.autoScales` requires the view to have non-zero bounds. `UIViewRepresentable`'s
`makeUIView` is called during sheet animation before layout is complete, producing a
blank view. Fixed by switching to `UIViewControllerRepresentable` and setting the
document in `viewDidAppear`, which is guaranteed to fire after the view has bounds.

### NavigationSplitView Interactivity
Initially `ManagerRootView` was presented via `.fullScreenCover`, which caused
`NavigationSplitView` to collapse its sidebar — all content rendered in the detail
column with no sidebar visible. Fixed by rendering the Manager view directly using
conditional `if/else` at the root, giving `NavigationSplitView` proper sizing context
from the window hierarchy.

---

## 10. AI Usage Documentation

*See `AI-USAGE-LOG.md` for full prompt and response history from Claude AI,
covering code generation, architectural decisions, and UI design iterations.*

**Summary of AI tool usage:**
- **Code generation:** Claude Code (claude.ai/code) used throughout development for SwiftUI implementation, debugging, and architecture decisions
- **UI mockup generation:** Claude Artifacts (claude.ai/artifacts) used for the 3 design variations documented in Section 2
- All generated code was reviewed, tested, and adapted to fit the specific NurseryConnect requirements
- All challenges and bugs were diagnosed and resolved through iterative AI-assisted debugging
