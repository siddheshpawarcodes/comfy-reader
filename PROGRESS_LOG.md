# Comfy Reader — Progress Log

> A running, timestamped record of work on Comfy Reader: what was implemented,
> what was changed, and what was removed. Companion to [plan.md](plan.md) (the
> spec) — this file is the **history**. Newest entries at the top.
>
> Timestamp format: `YYYY-MM-DD HH:MM TZ`. Each entry notes phase/step, the
> files touched, anything **removed**, and verification status.

---

## 2026-06-24 — Phase 7 (Release prep) — mostly done

### Step 7.3 — Permission rationale dialog + Open-settings recovery — ✅ DONE (analyze 2026-06-24 15:20 IST)

- **New** [lib/shared/widgets/permission_rationale_dialog.dart](lib/shared/widgets/permission_rationale_dialog.dart):
  `PermissionRationaleDialog` (themed pre-request dialog, `show()` → bool) +
  `StoragePermissionFlow.ensure(context)` orchestrating rationale → OS request →
  (if **permanently denied**) an "Open settings" prompt → `openAppSettings()`.
  No-ops to `true` on iOS (no scan).
- **Removed the duplicated inline rationale** from
  [home_screen.dart](lib/features/home/home_screen.dart) (`_showRationale` +
  `_perm` field deleted; `_onRefresh` now calls the shared flow) and
  [settings_screen.dart](lib/features/settings/settings_screen.dart)
  (`_RescanTile._showRationale` deleted; `_rescan` calls the flow). New
  behavior: permanently-denied users now get the Open-settings path (was absent).
- **Verification:** `flutter analyze` clean (incl. `use_build_context_synchronously`
  guards across the async dialog flow). Runtime is Android-only; the same
  `showDialog` pattern was device-verified in Phase 5.

### Step 7.2 — Build instructions — ✅ DONE (2026-06-24 15:22 IST)

Rewrote [README.md](README.md) (was default boilerplate): app blurb + doc links;
requirements (Flutter 3.41.4 / Dart 3.11.1); setup (`pub get`, iOS `pod install`);
debug run + the PID-file hot-reload dev-loop + the emulator slow-first-frame
caveat; **release builds** for Android (`apk`/`appbundle`) and iOS
(`--release`/`--simulator`); the **`MANAGE_EXTERNAL_STORAGE` Google Play
sensitive-permission declaration** + import-only fallback; **debug-signing-for-
release placeholder** + where to add a keystore; project layout; asset-regen
commands; and the iOS open-in-place known gap.

### Step 7.4 — Manual QA checklist — ✅ DONE (2026-06-24 15:24 IST)

New [QA.md](QA.md): end-to-end Android + iOS checklist (launch/shell, library,
reader, settings, cross-cutting), with per-platform P/F marks, _(A only)_ tags,
and the new Phase-6 surfaces (cover Hero, press feedback, reader error screen,
500-page profile, reduced-motion, a11y). Linked from README.

### Step 7.1 — Final icon + splash assets — ◑ PARTIAL (icon real; splash mismatch) 2026-06-24 15:25 IST

- **Launcher icon = real brand art (done, this session, by the user):**
  `assets/images/app_logo.jpeg` (cozy open book + yellow bookmark + smiling
  crescent moon on a periwinkle field) was added and `app_icon.png` /
  `app_icon_foreground.png` regenerated from it; `flutter_launcher_icons.yaml`
  uses `adaptive_icon_background: #7179B8` to match the field.
- **⚠️ Mismatch flagged (not changed):** `splash_logo.png` / `_dark` are still
  the Phase-0 PIL placeholder book-mark — so the **native + in-app splash don't
  match the new icon**. Reconciling needs a **transparent-background** version of
  the book+moon mark (the source is a composited periwinkle jpeg; auto-removing
  its background would look poor). Left for a real asset, then:
  `dart run flutter_native_splash:create`. Did **not** overwrite splash art with
  a guess.
- `flutter analyze` clean; `flutter test` 5/5 (no code change in this step).

---

## 2026-06-24 — Phase 6 (Polish) — done (6.4/6.6 have device-deferred sub-items)

> **Device-verification note (from ~14:57 IST):** the persistent `comfy_reader`
> `flutter run` (the Phase-0 dev-loop harness) exited and the emulator is now
> running a **different project** (`WMM-UI-UX`). To avoid hijacking that active
> session, Steps 6.2+ are verified with **`flutter analyze` only**; an on-device
> pass is deferred until the emulator is free. Step 6.1 was fully device-verified
> before this.

### Step 6.6 — iOS pass — ◑ PARTIAL (code-audited; runtime deferred) 2026-06-24 15:30 IST

**Code audit (device-independent) — all correct:**
- **No device scan on iOS:** `PermissionService.supportsDeviceScan` =
  `Platform.isAndroid`; `hasBroadAccess`/`ensureStorageAccess` return `true`
  (no prompt); `LibraryService.scanDevice` returns `[]` on non-Android. Settings
  rescan tile + Home pull-to-refresh are both gated on `supportsDeviceScan`.
- **Import path is sandbox-safe:** `importFromPicker` copies the picked file into
  `AppPaths.books` (app Documents) — works on iOS.
- **Info.plist:** `CFBundleDisplayName` & `CFBundleName` = "Comfy Reader";
  `UIFileSharingEnabled` = true; `LSSupportsOpeningDocumentsInPlace` = true;
  portrait orientation arrays present (+ Dart `setPreferredOrientations`).
- iOS simulators are installed (iPhone 17 Pro etc., all shut down); CocoaPods
  1.16.2 present; **no Pods/build yet** (cold iOS build needed).

**⚠️ Functional gap found — open-in-place does NOT import:** `AppDelegate.swift`
has only the default `didFinishLaunchingWithOptions`; there is **no** incoming-URL/
document handler and no sharing-intent package. So "Open with Comfy Reader" from
Files will launch the app but **not import** the tapped PDF. The `+ Add PDF`
picker import is the working path. Implementing open-in-place needs a scoped
native handler (`application(_:open:options:)` / SceneDelegate) + a Dart bridge,
then device testing → **tracked as a follow-up** (was assumed working under 6.6's
"verify"; it needs code).

**Deferred (needs Mac + Xcode/simulator session):** cold build & launch
(`flutter run -d <ios-sim-id>`), then manually confirm: native splash (no white
flash), portrait lock, picker import persists, audio/haptics/brightness/wakelock,
and (after the gap above is built) Files open-in-place.

### Step 6.5 — Accessibility — ✅ DONE (analyze + contrast calc 2026-06-24 15:24 IST)

- **Tooltips:** added to the reader overlay's Back / Previous page / Next page
  buttons ([reader_overlay.dart](lib/features/reader/widgets/reader_overlay.dart));
  all **8** `IconButton`s now have tooltips (the rest already did), plus the
  `PopupMenuButton`'s default tooltip. Brightness `Slider` wrapped in
  `Semantics(label: 'Screen brightness')`.
- **Button role:** [pressable.dart](lib/shared/widgets/pressable.dart) now emits
  `Semantics(button: onTap != null)` so every library card/row/continue tile is
  announced as a button (title/meta text still read as the label).
- **Contrast (computed, WCAG 2.1):** body & reading text pairs score
  **10.3–13.5** (≫ AA 4.5) in both Day and Night. Accent terracotta on cream =
  **3.67** — below AA-normal but passes the **3:1** bar for UI components/large
  text; used only for accents / the FAB label / small-caps section labels, never
  body text. Acceptable + documented (brand palette, verified visually in P3/P5).
- **Reduced-motion:** honored in splash (`_boot`), grid stagger (6.2), and
  `Pressable` (6.2). The page-curl is core content (not chrome) → intentionally
  not suppressed.
- **Tap targets:** all `IconButton`s are Material's 48px min; cards are large;
  Settings switches/segments are standard Material (≥48).

**Deferred (device):** OS text-scale at 1.3× — layouts use flex/ellipsis; the
tightest spot is the `BookCard` grid cell (fixed `childAspectRatio` 0.54; back-of-
envelope ~88<91px of label room at 1.3×, so OK, but confirm on device). No code
change made to avoid disturbing the P3-verified grid layout.

### Step 6.4 — Performance pass — ◑ PARTIAL (code/tests done; device profile deferred) 2026-06-24 15:18 IST

**Done (device-independent):**
- **Cover-render throttle (the real gap):** new
  [lib/core/utils/semaphore.dart](lib/core/utils/semaphore.dart) (`Semaphore`,
  FIFO, `withPermit`). `LibraryService.ensureCover` now renders covers through a
  `Semaphore(3)` so a burst of newly-visible cards can't flood the native PDF
  renderer and stutter scrolling (Done-when: "cover generation never blocks
  scrolling"). Previously every visible card kicked off an unbounded render.
- **Cache settings documented** in [main.dart](lib/main.dart): explained the LRU
  math (max width 1600 → ~14 MB/decoded page; ±3 precache ≈ 7 live; cap 14 /
  220 MB → byte cap is the true bound; far pages evict → flat memory on 500+ pp).
- **Render target width** reviewed: `(width × DPR).clamp(400, 1600)` in
  `reader_screen` — DPR-aware and bounded; uniform width → cache-key reuse.
- **Off-UI-isolate:** `pdfx` renders natively (platform channel) and the PNG→
  `ui.Image` decode uses `ImageDecoderCallback` — so no `compute()` is needed;
  the Dart UI isolate isn't blocked by rendering.

**Verification:** `flutter analyze` clean; `flutter test` 5/5 incl. new
`Semaphore caps concurrency at its limit`.

**Deferred (needs a real device — NOT done):** the empirical `flutter run
--profile` pass on a 500+ page PDF (sustained 60fps curl, DevTools memory graph
showing bounded/evicting cache, page-load latency). The x86 emulator is both
busy with another project AND unrepresentative (first render ~19s, software
raster). Marked in plan.md as the remaining sub-item.

### Step 6.3 — Error / empty / loading states — ✅ DONE (analyze + unit test 2026-06-24 15:10 IST)

**Audit result — already graceful (confirmed, unchanged):** import failure →
"Couldn't import that file." snackbar ([add_pdf_fab.dart](lib/features/home/widgets/add_pdf_fab.dart));
scan-no-results → "No new books found"; permission denied → snackbar + degrade
to import (Home + Settings); empty state (library-empty vs no-search-matches);
all `PdfService` methods already return null/0/defaults (never throw).

**Added — the gap (corrupt / missing / protected PDF on open):**
- [pdf_service.dart](lib/services/pdf_service.dart): new `PdfOpenResult`
  {ok, missing, protected, corrupt}, `PdfProbe` (result + page count), and
  `PdfService.probe(path)` — cheap open→count→close that detects a missing file
  (no native call), a password-protected doc (exception text contains
  password/encrypt/security), or a corrupt one.
- [reader_provider.dart](lib/providers/reader_provider.dart): new
  `ReaderStatus` {loading, ready, error}, `errorMessage`, and `init()` that
  probes the doc and maps the result to a friendly message; `totalPages` now
  prefers the probed count (fixes a book imported with a stale 0 count).
- [reader_screen.dart](lib/features/reader/reader_screen.dart): calls
  `_reader!.init()` on open; build now `switch`es on status —
  **loading** = cover image under a themed spinner (kept inside the cover Hero
  so the 6.1 flight still completes), **error** = friendly
  "Can't open this book" + reason + **Go back** button, **ready** = the existing
  flipbook + overlay.

**Per-page render errors:** the vendored flipbook already wraps each page
`Image` with an `errorBuilder` → `blankPageColor` (flip_book.dart:2737) and we
pass `blankPageColor: paperColor`, so a single failed page degrades to a blank
paper page (no crash/dead-end). A per-page **retry** button isn't exposed by the
engine (it renders pages internally) — documented deviation; the dominant
whole-document failure is now caught by the probe.

**Known minor limitation:** a book whose cover can't be rendered shows a
perpetual shimmer (not the broken-book icon) because per-book cover-failure
state isn't tracked. Not a dead-end (tap still routes to the reader's friendly
error). Parked.

**Verification:** `flutter analyze` clean (whole project); `flutter test` → 4/4
pass incl. new `PdfService.probe reports a missing file` (runs without a
device/PDFium). Error-screen **rendering** for protected/corrupt to be confirmed
on-device when the emulator frees up.

### Step 6.2 — Micro-animations — ✅ DONE (analyze-verified 2026-06-24 14:58 IST)

**Already present (Phases 3/6 scaffolding), confirmed:** staggered grid entrance
(`flutter_animate` per-index `fadeIn`+`moveY` in `library_grid.dart`); shimmer on
loading covers (`ShimmerBox`); polished splash choreography with reduced-motion
handling in `splash_screen.dart` — left as-is (already meets the bar).

**Added this step (the gap = tap feedback + reduced-motion coverage):**
- **New** [lib/shared/widgets/pressable.dart](lib/shared/widgets/pressable.dart):
  `Pressable` — wraps a tappable child with a subtle `AnimatedScale` press-down
  (0.96, `AppDurations.fast`, `easeOut`); **honors `MediaQuery.disableAnimations`**
  (no scale when reduced-motion is on). Replaces bespoke `GestureDetector`s.
- Adopted `Pressable` in
  [book_card.dart](lib/features/home/widgets/book_card.dart),
  [library_list.dart](lib/features/home/widgets/library_list.dart) (`_LibraryRow`),
  and [continue_reading.dart](lib/features/home/widgets/continue_reading.dart)
  (`_ContinueCard`) — **removed** their raw `GestureDetector` wrappers (onTap/
  onLongPress preserved).
- [library_grid.dart](lib/features/home/widgets/library_grid.dart): the staggered
  entrance now **skips entirely** when reduced-motion is on (returns the bare
  `BookCard`).

**Verification:** `flutter analyze` on all five touched files → No issues. Tap
navigation path is unchanged from 6.1 (already device-verified). Press-scale is a
transient visual — to confirm on device when the emulator frees up.

### Step 6.1 — Transitions — ✅ DONE (verified 2026-06-24 14:51 IST)

**Implemented:**
- [lib/core/router/app_router.dart](lib/core/router/app_router.dart): added a
  `_sharedAxisPage` builder (slide-from-right + fade, `easeOutCubic`, reverse
  enabled) and switched `/settings` to use it (was `_fadePage`). Splash → home
  and the reader keep the soft `_fadePage`. Documented both builders.
- [lib/features/reader/reader_screen.dart](lib/features/reader/reader_screen.dart):
  wrapped the reader page area (`_applyTint(BookCurlView(...))`) in a
  `Hero(tag: 'cover_${book.id}')` matching the library card's existing cover
  Hero, with a `_coverFlightShuttle` that renders the **cover image** expanding
  from the card to full screen (corner radius `radiusSmall → 0`, `easeOutCubic`)
  so the in-flight frame is the cover, not a blank/loading flipbook. Added
  `import 'dart:io'`.

**Hero-tag audit (no conflicts):** `BookCard` (grid) and `_LibraryRow` (list)
already use `cover_<id>` but are mutually exclusive. `ContinueReading` correctly
**omits** the Hero (a recent book also in the grid would otherwise create two
heroes with one tag on the home route → flight error). Left as-is. The reader
route has exactly one Hero.

**Verification (emulator-5554, hot reload):** tapped a grid cover (Ocean Deep) →
reader opened with **no Hero/Flutter exceptions** in logcat; first page rendered
("Page 1 of 48", paper tint); back/pop also clean. `flutter analyze` clean.

**Perf note for Step 6.4:** first-page render of `Ocean Deep.pdf` took ~19s on
this x86 emulator (logcat open→destroy 14:49:27→14:49:46) — the known
JIT/software-render artifact; revisit under a profile build / real device.

---

## 2026-06-24 14:16 IST — Phase 5 (Settings) started

**Context picked up from:** [plan.md](plan.md) "Build progress & session notes"
(top of file). Phases 0–4 were already done & verified on the Android emulator;
Phase 5 (Settings) was the next open item — its only step is **Step 5.1**.

**State found at start of session:**
- `lib/features/settings/settings_screen.dart` was a **placeholder** (a centered
  "Settings — coming soon" `Text`).
- The `/settings` route **already existed** in
  [lib/core/router/app_router.dart](lib/core/router/app_router.dart) (added during
  Phase 1 scaffolding) — no router change needed.
- The Home overflow menu **already pushes** `/settings`
  ([lib/features/home/home_screen.dart](lib/features/home/home_screen.dart) `_onMenu`)
  — no Home change needed.
- `SettingsProvider` exposes: `setThemeMode`, `setSoundEnabled`, `setSoundVolume`,
  `setHaptics`, `setPageTint`, `setKeepScreenOn` (all persist + notify).
- `package_info_plus` is **not** a dependency → About version is **hardcoded**
  to `1.0.0` (matches `pubspec.yaml version: 1.0.0+1`), per the plan's
  "PackageInfo/hardcoded" allowance and the no-extra-deps guardrail.

### Step 5.1 — Settings screen — ✅ DONE (verified 2026-06-24 14:24 IST)

**Implemented** ([lib/features/settings/settings_screen.dart](lib/features/settings/settings_screen.dart)):
- **Removed:** the placeholder `SettingsScreen` (a centered "Settings — coming
  soon" `Text`) — replaced wholesale by the real screen.
- **Appearance** — `SegmentedButton<AppThemeMode>`: System / Day / Night →
  `SettingsProvider.setThemeMode`.
- **Reading** — `SwitchListTile`s: Page-turn sound (`setSoundEnabled`), Haptics
  (`setHaptics`), Keep screen on (`setKeepScreenOn`); a Volume `Slider`
  (`setSoundVolume`) that is **dimmed + no-op (`onChanged: null`) when sound is
  off**.
- **Default page tint** — `SegmentedButton<PageTint>`: Paper / Sepia / Night →
  `setPageTint`, with a helper caption.
- **Library** (Android only, gated on `PermissionService.supportsDeviceScan`) —
  "Rescan device for PDFs" tile that reuses the Home rationale → request →
  `LibraryProvider.scanDevice` flow, shows a spinner while `isScanning`, and
  reports results via snackbar.
- **About** — app name + tagline + `v1.0.0` (hardcoded; **no
  `package_info_plus` added**), and "Open-source licenses" → `showLicensePage`.
- Two private widgets in-file: `_SectionHeader` (muted, primary-colored caps)
  and `_RescanTile`.

**Not changed (already in place from Phase 1 scaffolding):**
- `lib/core/router/app_router.dart` — `/settings` route already present.
- `lib/features/home/home_screen.dart` — overflow "Settings" already pushes
  `/settings`.

**Lint fix during build:** added `const` to `_RescanTile(perm: _perm)`
(`prefer_const_constructors`).

**Verification:**
- `flutter analyze` → **No issues found!** (whole project).
- Live on emulator-5554 via hot reload (existing `flutter run` from the prior
  session, pid file under that session's scratchpad):
  - All sections render correctly in Night theme.
  - Volume slider correctly dimmed (current persisted state has sound off).
  - Tapping **Day** flipped the entire app to the cream Day theme **instantly**
    (headline acceptance criterion) — then restored to **Night** to leave the
    app as found.
  - **Open-source licenses** opens Flutter's `showLicensePage` titled
    "Comfy Reader / v1.0.0".
  - (Screencap latency note: the first post-toggle capture showed a stale dark
    frame; a re-capture confirmed the Day theme — a known emulator quirk, not a
    bug.)

**plan.md updated:** Step 5.1 checked `- [x]` with a "Done (actual)" note; the
top "Build progress & session notes" moved Phase 5 into Done.

**Phase 5 complete. Next open work:** Phase 6 (polish) then Phase 7 (release).
