# NurseyConnect — Assignment 2
## SE4020 Mobile Application Design and Development

**Student ID:** IT22056320  
**Student Name:** Senevirathna K.M.U.T  
**Year:** 4, Semester 1, 2026  

---

## Assignment 1 Repository
🔗 [NurseyConnect A1 — Keyworker Role (iOS)](https://github.com/UdulaThathsaridu5624/Nursery-Connect)

---

## Part A — iPadOS App 

**Setting Manager role** for Little Stars Nursery & Daycare — Dashboard, Rooms (drag & drop), Attendance, Analytics (Swift Charts), Report Generation (PDFKit), and Incident Review. Keyworker role from Assignment 1 carried forward.

### Part A Documents
- 📄 [Full Report](REPORT-PART-A.md) — design choices, AI mockups, regulatory compliance, challenges
- ▶️ [Demo Video](https://drive.google.com/file/d/1Wnc3PbqnJqt5817kuTgHVF5o1x-u51l3/view?usp=sharing)

### Part A Key Features
| Feature | Implementation |
|---|---|
| New role | Setting Manager (Dashboard, Rooms, Attendance, Analytics, Reports, Incidents) |
| Advanced library 1 | Swift Charts — 4 live charts (mood, attendance, incidents, meals) |
| Advanced library 2 | PDFKit — 3 Ofsted-ready PDF report types |
| iPadOS native 1 | `NavigationSplitView` — 2-column sidebar + detail |
| iPadOS native 2 | Drag & Drop — reassign children between rooms |
| iPadOS native 3 | Keyboard shortcuts — Cmd+N, Cmd+P |
| Testing | 39 unit tests (EYFS ratio logic, PDFKit output, incident workflow) |
| Carried from A1 | Full Keyworker role — diary + incidents (accessible via sidebar button) |

---

## Part B — visionOS App 

**NurseyConnect Space** — a spatial dashboard for Apple Vision Pro allowing the Setting Manager to oversee all nursery rooms simultaneously in an immersive mixed-reality environment.

### Part B Documents
- 📄 [Full Report + Learning Reflection](REPORT-PART-B.md)
- 📊 [Slide Deck](https://docs.google.com/presentation/d/1mBsCKHmjNlKGD3iP2kWjmoiRrreLYwEaovZhKKCs12k/edit?usp=sharing)
- ▶️ [Demo Video](https://drive.google.com/file/d/1MMZweu73Wvls0dYAEYkNG5SwhsLvT4IF/view?usp=drive_link)

### Part B Key Features
| Feature | Implementation |
|---|---|
| Spatial UI | `ImmersiveSpace` (mixed immersion) with 3 floating room panels |
| 3D positioning | `RealityView` + `attachments:` API with `AnchorEntity(world:)` |
| Glass material | `.glassBackgroundEffect()` on all panels and windows |
| Hover feedback | `.hoverEffect(.highlight)` on room panels and list rows |
| Incident alert | Floating SwiftUI attachment badge with expandable detail card |
| Multi-window | `WindowGroup<UUID>` — secondary ChildListWindow per room |
| Ratio badge | Inline EYFS compliance indicator next to app title |

---

## AI Usage Documentation
- 🤖 [AI Usage Log](AI-USAGE-LOG.md) — 13 entries covering Part A (Entries 1–9) and Part B (Entries 10–13)

---

## Project Structure

```
NurseyConnect-A2/
├── NurseyConnect-A2/              ← iPadOS app source
│   ├── Models/                    ← SwiftData models (6 @Model classes)
│   ├── Manager/                   ← Setting Manager role views
│   │   ├── Dashboard/
│   │   ├── Rooms/
│   │   ├── Attendance/
│   │   ├── Analytics/
│   │   ├── Reports/
│   │   └── Incidents/
│   ├── Keyworker/                 ← Keyworker role (carried from A1)
│   │   ├── Diary/
│   │   └── Incidents/
│   ├── Shared/                    ← RoleSelectionView
│   ├── Theme/                     ← AppTheme.swift
│   └── Utilities/                 ← PDFReportGenerator, SampleData
├── NurseyConnect-visionOS/        ← visionOS app source
│   ├── ContentView.swift          ← Main glass window
│   ├── ImmersiveView.swift        ← RealityKit immersive space
│   ├── RoomPanelView.swift        ← Floating room card
│   ├── ChildListWindow.swift      ← Secondary spatial window
│   ├── VisionModels.swift         ← Self-contained data structs
│   └── AppModel.swift             ← Immersive space state management
├── NurseyConnect-A2Tests/         ← 39 unit tests
├── README.md                      ← This file
├── REPORT-PART-A.md               ← Part A full report
├── REPORT-PART-B.md               ← Part B report + learning reflection
└── AI-USAGE-LOG.md                ← AI prompts and responses log
```
