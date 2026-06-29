---
name: ui-investigation-rules
description: >
  Canonical rules + checklists for investigating UI behavior and visual implementation in Comfy
  Reader — user-flow reconstruction, state-flow tracing (Provider/ChangeNotifier →
  Consumer/Selector/context.read → rebuild), interaction/lifecycle/async paths, conditional
  rendering, navigation (go_router), and the visual audit (typography, icons, layout, color, theme,
  comfort tints, assets, accessibility, design-system compliance against
  AppColors/AppTypography/AppTheme/Dimens/shared widgets/flutter_screenutil). TRIGGER when reading,
  debugging, reviewing, or reasoning about any screen, widget, dialog, interaction, visual
  inconsistency, or design-system deviation. For live diagnosis, run the ui-investigator agent.
---

# UI Investigation Rules

Comfy Reader's UI is **Provider/ChangeNotifier + `go_router`** over a cozy design system. Most UI
bugs are one of: (a) a `Consumer`/`Selector` reading stale or wrong state, (b) an enable/disable
condition that doesn't match its data source, (c) a controller/timer lifecycle mismatch (not
disposed, not seeded), (d) a navigation/arg gap, (e) an async race (save debounce, overlay timer,
TTS callbacks, image loads), or (f) a visual/design-system deviation (hardcoded color/size, ad-hoc
`TextStyle`). Find which — with `file:line` evidence — before anyone writes code. For the deep
trace, run **ui-investigator**.

## Read alongside this
- `.claude/project-conventions.md` §1 (non-negotiable rules), §2 (architecture facts), §4
  (high-risk files), §6 (state-sync rules).
- Design-system anchors: [lib/core/theme/](../../../lib/core/theme/) (`AppColors`, `AppTypography`,
  `AppTheme` + `ComfyColors`, `Dimens`), [asset_paths.dart](../../../lib/core/constants/asset_paths.dart),
  [durations.dart](../../../lib/core/constants/durations.dart), and reusable widgets in
  [lib/shared/widgets/](../../../lib/shared/widgets/) (`Pressable`, `ShimmerBox`, `MaxTextScale`,
  `PermissionRationaleDialog`).
- Routing: [app_router.dart](../../../lib/core/router/app_router.dart) (`/splash`, `/home`,
  `/reader/:bookId`, `/voices`).
- Responsive: `flutter_screenutil`, `designSize: Size(375, 812)` (`ScreenUtilInit` in
  [app.dart](../../../lib/app.dart)); app is **portrait-locked**.

## The 12 rules

1. **Reconstruct the journey first.** Before reading code, write the flow: starting state → user
   action → UI event → state change → rebuild → result, and observed vs expected. The trace must
   explain the *expected* behavior too, not only the bug.
2. **One state source per fact.** Identify where each piece of state lives (which provider/
   controller, local `setState`, or `TextEditingController`) and trace created → mutated → notified
   → consumed. Two widgets showing the same data must read the same source — divergence is a desync
   smell (hand off to **state-sync-tracer**).
3. **Reactive vs side-effect vs one-off.** Reactive UI uses `Consumer`/`context.watch`/`Selector`;
   one-off actions use `context.read`. A `read` where the UI should rebuild (or a too-broad `watch`
   that rebuilds the world) is a defect. `Selector` narrows rebuilds — missing it on a hot path
   (the reader during a flip, the library during scroll) is a jank smell.
4. **Notify discipline.** A mutation notifies **once** per coherent change, never inside `build`,
   and *after* an async write the UI depends on. Missing/duplicate notifies → stale or flickering UI.
5. **Controllers & timers follow the lifecycle.** Created as fields / in `initState` or the provider
   ctor, disposed in `dispose` — the reader's `_overlayTimer` (4s auto-hide), `_saveDebounce`
   (600ms), `FlipbookController`, and any `TextEditingController`. A leaked timer firing after
   dispose, or a controller not seeded from the model, is a classic bug.
6. **Enable/disable & conditional state must match their data.** For every gated control and every
   `if`/`switch`/ternary/visibility, name the exact condition and the state it derives from. Map
   expected vs actual outcome of each branch (e.g. the read-aloud bar's play/pause/Scanning states).
7. **`build()` stays small.** No function/logic definitions inside `build`. Handlers
   (`onTap`/`onChanged`) are named methods passed by reference. Logic in `build` is both a
   convention violation and a rebuild-cost smell.
8. **Navigation goes through the router.** Trace via `go_router` (`context.go`/`context.push`), not
   ad-hoc `Navigator`. Verify route args are passed and read on the destination — `/reader/:bookId`
   with a missing/typed-wrong id is a frequent "blank screen / null" cause.
9. **No hardcoded UI values.** Colors → `AppColors`/`ComfyColors`/theme; text styles →
   `AppTypography`; spacing/radii/shadows → `Dimens`; images/icons → `asset_paths`; durations →
   `AppDurations`. Sizes use `flutter_screenutil` (`.w/.h/.sp/.r`). Flag every raw `Color(0x..)`,
   `Colors.*`, ad-hoc `TextStyle`, or raw px. Prefer `lib/shared/widgets/` over re-rolling.
10. **Comfort tints recolor the page.** The reader applies paper/sepia/night via `ColorFiltered`
    (night inverts luminance). A "wrong color in the reader" is usually the tint or the day/night
    theme, not a widget style — check which, and check both themes.
11. **Copy is inline (no l10n).** There is **no `AppStrings` and no `.arb`** — visible text is
    English literals. Don't flag a literal as a missing-key bug; do flag inconsistent copy/casing vs
    the surrounding screen, and overflow/truncation on long strings (book titles!).
12. **Accessibility & responsiveness.** Tap targets ≥ ~48dp, meaningful semantic labels,
    text-scaling tolerance (`MaxTextScale`), contrast in both themes. Note overflow risks (unbounded
    `Row`/`Text`, fixed heights with scaling), and that the app is portrait-only.

## Investigation checklist
- [ ] User journey written: action → event → state → rebuild → result; observed vs expected.
- [ ] Widget hierarchy mapped (screen entry → children → dialogs/sheets/overlays/painters).
- [ ] Every relevant state variable: source, where notified, which UI consumes it (R2).
- [ ] `Consumer`/`Selector`/`read` usage correct; rebuild scope right (R3–R4).
- [ ] Controllers/timers seeded/disposed; no fire-after-dispose (R5).
- [ ] Every enable/disable/conditional mapped expected vs actual (R6).
- [ ] Navigation traced through router; route args present on destination (R8).
- [ ] Lifecycle side effects (initState/dispose/postFrame) and async/races labeled "observed" vs
      "theoretical" (R5, save debounce, overlay timer, TTS callbacks, image loads).
- [ ] Visual audit done (typography/icon/layout/color+tint/theme/asset) with origins cited (R9–R10).
- [ ] Accessibility + responsive behavior checked (R12).

## Visual audit quick-reference
- **Typography:** widget · text · `AppTypography` role · family (Fraunces/Lora/Inter) · size (`.sp`)
  · weight (`FontVariation`) · height · color · overflow.
- **Icon:** source (IconData / asset via `asset_paths`) · size · color · purpose · interaction.
- **Layout:** padding/margin/alignment/constraints · `Dimens` spacing · Expanded/Flexible ·
  responsive · overflow risk.
- **Color/Tint/Theme/Asset:** origin of every color (flag non-`AppColors`/`ComfyColors`);
  reader-tint correctness; `ThemeData`/`TextTheme`/`ColorScheme` source; `asset_paths` refs +
  missing assets.

## Output headings (the ui-investigator agent uses these)
`Scope Investigated` · `Files Investigated` · `User Flow` · `Widget Hierarchy` · `State Flow` ·
`Interaction Trace` · `Conditional Rendering Audit` · `Navigation & Lifecycle` · `Async Findings` ·
`Visual Audit` · `Accessibility Findings` · `Performance Findings` · `Hidden Dependencies` ·
`Root Cause Candidates` (Evidence + Confidence) · `Confidence Assessment` ·
`Recommended Verification Steps`.

## Hand-offs
- Page-curl / PDF render / image-cache / tint geometry → **rendering-rules** skill +
  **rendering-investigator**.
- Read-aloud / TTS / OCR / voice-picker behavior → **read-aloud-pipeline** skill +
  **read-aloud-auditor**.
- Cross-provider staleness (reader↔library↔settings) → **state-sync-map** skill +
  **state-sync-tracer**.
- Android-vs-iOS behavior → **platform-parity-investigator**.
- "Prove how it renders" (pixels) → **visual-verification** skill / **visual-verification-engineer**.

## Hard rule
Read-only investigation. Cite `file:line` for every claim; distinguish facts from assumptions.
**Do not propose fixes unless explicitly asked.** If evidence is insufficient, state "Investigation
incomplete — additional tracing required" and name what to trace next.

## Example usage
- "Why does the read-aloud bar stay on 'Scanning…' forever?"
- "The reader overlay auto-hides while I'm still using the scrubber."
- "This screen's heading uses the wrong font/color — where does the style come from?"
- "Long book titles overflow the library card."
