# SE4020 Assignment 2 — Part B Report
## NurseyConnect Space — visionOS Spatial Dashboard

**Student ID:** IT22056320  
**Module:** SE4020 — Mobile Application Design and Development  
**Year:** 4, Semester 2, 2026  

---

## Demo Video

▶️ [Watch Part B Demo — NurseyConnect Space (visionOS)](https://drive.google.com/file/d/1MMZweu73Wvls0dYAEYkNG5SwhsLvT4IF/view?usp=drive_link)

> Main glass window with stats and room list, expandable children rows,
> immersive space with floating room panels anchored in physical space,
> interactive incident alert card, secondary ChildListWindow, and ornament badge.

---

## Slide Deck

📊 [View Presentation Slides — NurseyConnect Space](https://docs.google.com/presentation/d/1mBsCKHmjNlKGD3iP2kWjmoiRrreLYwEaovZhKKCs12k/edit?usp=sharing)

> 6–8 slides covering concept, target audience, spatial UX design decisions,
> technical implementation, GDPR compliance, and value proposition for the
> NurseyConnect childcare ecosystem.

---

## AI Usage Documentation

See [AI-USAGE-LOG.md](AI-USAGE-LOG.md) — Part B section (Entries 10–13) covers all
visionOS-specific AI interactions including ImmersiveSpace setup, incident alert card,
window ornament, and ChildListWindow secondary window.

---

## Learning Reflection

### Introduction

When I began Part B of this assignment, I had no prior experience with visionOS or
spatial computing. My goal was to build a meaningful extension of the NurseyConnect
Setting Manager dashboard for Apple Vision Pro — one that went beyond simply
recreating a flat UI in 3D space and demonstrated genuine understanding of spatial
computing principles.

---

### Resource 1 — WWDC23: "Meet SwiftUI for spatial computing"
*Apple Developer, WWDC 2023 Session*

This session was my starting point for understanding how visionOS differs from iOS/iPadOS
at the UI framework level. The key insight was that visionOS uses the same SwiftUI
primitives as iOS but adds spatial-specific modifiers that simply do not exist on other
platforms. `.glassBackgroundEffect()` replaces the iOS `.background()` pattern — windows
in visionOS have a translucent glass appearance that lets users see their physical
environment through the UI. I also learned about `.hoverEffect()` and `.ornament()` —
two APIs that have no equivalent on iPhone or iPad and signal to the user that the app
was designed specifically for Vision Pro.

I applied all three in my implementation: glass material on all panels and the child
list window, hover highlights on room panels and list rows, and a ratio-alert badge
inline with the title (informed by the ornament positioning API). Understanding that
visionOS uses the same SwiftUI I already know — extended with spatial modifiers rather
than replaced — significantly reduced the learning curve.

---

### Resource 2 — WWDC23: "Develop your first immersive app"
*Apple Developer, WWDC 2023 Session*

This session explained the three immersion styles (`.mixed`, `.progressive`, `.full`)
and when to use each. I chose `.mixed` because the Setting Manager still needs to see
their physical environment — they are in a real nursery with children and staff around
them. Full immersion would disconnect them from the people they are responsible for
supervising, which would be inappropriate and potentially unsafe in a childcare setting.

The session also explained the correct pattern for `ImmersiveSpace` state management
using an `@Observable` `AppModel` class that tracks `.open`, `.inTransition`, and
`.closed` states. This prevents invalid state changes — for example, tapping "Show
Immersive Space" while a transition is already in progress. I implemented this pattern
directly in `AppModel.swift` and `ToggleImmersiveSpaceButton.swift`, and it proved
essential for preventing crashes when the user rapidly toggled the immersive space.

---

### Resource 3 — Apple Developer Documentation: "Adding 3D content to your app"
*Apple Developer Documentation, developer.apple.com*

This reference taught me the `RealityView` `attachments:` API — the correct way to
position SwiftUI views in 3D space in visionOS. My initial approach used `.overlay`
on the `RealityView` with `.offset(z:)` modifiers, which failed to position panels
correctly because SwiftUI overlays do not resolve 3D transforms in the same world
coordinate space as the physical environment.

The `attachments:` closure gives each SwiftUI view a `ViewAttachmentEntity` that can
be positioned and oriented in world space using `SIMD3<Float>` coordinates and
`simd_quatf` rotations — the same coordinate system as any other RealityKit entity.
Switching to this pattern was the critical fix that made the floating room panels
appear correctly in the simulator at the expected physical positions.

This resource also taught me the distinction between `AnchorEntity(.plane(.horizontal))`
(which requires floor plane detection — unreliable in the simulator) and
`AnchorEntity(world: .zero)` (which works reliably in both simulator and device). Using
the world anchor made development and testing significantly more predictable.

---

### Challenges

**RealityKitContent module error:** The default visionOS App template in Xcode includes
a `RealityKitContent` Swift package for loading 3D assets created in Reality Composer Pro.
My implementation uses only procedural RealityKit geometry (`ModelEntity` with
`SimpleMaterial`) and SwiftUI attachments — no `.reality` files. The initial fix attempted
was selecting "None" as the Immersive Space Renderer during target creation to remove the
package dependency. However, this did not resolve the error immediately — the fix that
actually worked was restarting Xcode, which forced the package resolution cache to clear
and recognised that the `RealityKitContent` module was no longer required by the target.

**SwiftData sharing between targets:** An initial approach attempted to share SwiftData
`@Model` files between the iPadOS and visionOS targets via target membership. This caused
`@Model` macro conflicts and build failures. Resolved by creating `VisionModels.swift`
with self-contained plain Swift structs (`VisionRoom`, `VisionChild`) and hardcoded
`VisionSampleData` — appropriate for a prototype since visionOS simulator cannot share
a live data store with the iPad simulator anyway.

**`.offset(z:)` vs `attachments:`:** Positioning SwiftUI views in 3D space is not
achievable via standard SwiftUI offset modifiers in visionOS. The `.offset(z:)` modifier
in a `.overlay` moves the view in the 2D flat window plane, not into depth in the physical
world. The `RealityView attachments:` pattern is the only correct way to place SwiftUI
content at specific real-world coordinates — a key learning that took significant debugging
to understand.

---

### Conclusion

Building the visionOS prototype required learning an entirely new spatial computing
paradigm in a short timeframe. The most valuable lesson was understanding that effective
spatial UX is not about placing 2D screens in 3D space — it is about using depth,
physical anchoring, and always-available peripheral information to reduce cognitive load
for the user.

The NurseyConnect Space dashboard demonstrates this principle: a Setting Manager can see
all three rooms simultaneously at comfortable viewing angles without navigating between
screens. The incident alert badge floats centrally above the panels where it naturally
draws attention. The ratio compliance status is visible at a glance without requiring
any interaction. This spatial awareness is impossible to replicate on a flat iPad screen
and represents the genuine value of the Apple Vision Pro platform for professional
management applications.

In a production deployment, the visionOS app would sync via CloudKit with the iPadOS
app — sharing live SwiftData in real time so the Setting Manager's spatial view reflects
what the Keyworker is logging on their iPad. As a prototype, it demonstrates the spatial
UX concepts with representative sample data, which is standard practice for Vision Pro
prototyping given the limited availability of physical devices.

---

*SE4020 — Mobile Application Design & Development | Semester 1, 2026 | SLIIT*
