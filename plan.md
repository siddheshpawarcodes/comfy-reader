# Comfy Reader — Execution Plan (`plan.md`)

> A premium, cozy **PDF reader** where documents open and turn like a real physical book — Kindle-style page-curl with a tactile page-turn sound. Android (primary) + iOS, single Flutter codebase.

---

## ⏳ Build progress & session notes (keep updated)

**Done & verified on Android emulator (emulator-5554):** Phase 0 (setup), Phase 1 (foundation), Phase 2 (animated splash), Phase 3 (home/library: scan, grid+list, real PDF covers, search, context menu, empty state), Phase 4 (reader: immersive, lazy `PdfPageImageProvider` render, 3D page-curl via vendored `RealisticFlipbook`, overlay+auto-hide, scrubber, bookmark UI, paper+sepia tints, brightness, resume), **Phase 5 (Settings — full screen wired to `SettingsProvider`: theme, sound+volume, haptics, default tint, keep-awake, Android rescan, About+licenses; theme switches instantly)**. `flutter analyze` is clean; unit tests pass.

**Phase 6 (polish) — 2026-06-24:** 6.1 transitions (cover Hero + shared-axis), 6.2 micro-anim (`Pressable` tap-scale + reduced-motion), 6.3 error states (`PdfService.probe` → friendly reader error), 6.5 a11y (tooltips, button semantics, contrast verified) are **done** (6.1 device-verified; 6.2/6.3/6.5 analyze + unit tests, device pass pending an emulator). 6.4 perf (cover-render throttle + cache docs; **empirical `--profile` deferred**) and 6.6 iOS (code-audited; **runtime + an open-in-place import gap deferred**) are **partial**. `flutter analyze` clean; `flutter test` 5/5.

**Phase 7 (release prep) — 2026-06-24:** 7.2 README build instructions + 7.3 shared permission rationale/Open-settings flow are **done**; 7.4 QA checklist **authored** ([QA.md](QA.md), running it is device-pending); 7.1 launcher icon now uses **real brand art** (periwinkle book+moon) but the **splash still mismatches** (needs a transparent-bg mark + regen). `flutter analyze` clean; `flutter test` 5/5.

**Remaining (all device- or design-dependent):** run [QA.md](QA.md) on a real Android + iOS; 6.4 `--profile` pass on a 500-page PDF; 6.6 iOS sim build + the open-in-place import handler; reconcile the splash art (7.1); the audio follow-up below. The code is feature-complete through Phase 7 and analyzer/test-clean.

**Progress log:** Detailed timestamped session history (what was implemented/changed/removed) lives in [PROGRESS_LOG.md](PROGRESS_LOG.md) — pick it up for context alongside this section.

**Known follow-up:** `AudioService.init()` `setSource` of `assets/audio/page_flip.wav` times out (~30s) on the emulator in `PlayerMode.lowLatency` (swallowed; haptics work, sound doesn't). Fix in Phase 4/5 — try default player mode, or `setSourceBytes`, or a short mp3; verify on a real device.

**Dev workflow (fast iteration):** a persistent `flutter run` is kept alive with `--pid-file=<scratchpad>/cr.pid`. Hot reload = `kill -USR1 $(cat …/cr.pid)` (~4s); hot restart = `kill -USR2` (~10s). The x86 emulator's first cold frame is ~55–100s (JIT/software-render artifact). Screencap latency ~0.4s can't catch sub-second animations — slow the animation or accept functional verification.

**Test data on device:** sample PDFs (`Cozy Tales`, `The Quiet Forest` 200p, `Mountain Notes`, `Ocean Deep`) pushed to `/storage/emulated/0/Download/`; `MANAGE_EXTERNAL_STORAGE` granted via `adb shell appops set com.example.comfy_reader MANAGE_EXTERNAL_STORAGE allow`. Generators in scratchpad: `gen_pdf.py`, `gen_brand.py`, `gen_flip.py`.

**Reminder:** `home_screen.dart` had a temporary theme toggle — it was moved into the overflow menu (not a leftover). Placeholder→real screens created in Phase 1 were fleshed out in their phases.

---

## Overview

**What we're building:** A tightly scoped, premium PDF reader (see Core Features below). Headline experiences: realistic **page-curl turning** of rasterized PDF pages, a **page-turn sound**, an **animated cozy splash**, an **auto-discovering library** with covers (rendered first page) + names, **resume reading**, **bookmarks + Go-To**, and **day/night/sepia** comfort controls.

**Target platforms:** Android (primary) and iOS. Portrait-primary. Landscape two-page spread is explicitly out of v1 scope.

**Toolchain (verified in this repo):** Flutter `3.41.4` stable, Dart `3.11.1` (constraint `^3.11.1`). The existing default counter app uses Dart 3.11 dot-shorthand (`.fromSeed`, `.center`) — confirms the SDK. `flutter_lints: ^6.0.0`.

### Key package & approach decisions (verified on pub.dev at planning time — always `flutter pub add` and let the resolver pick versions; versions below are FYI only)

| Concern | Choice (primary) | Fallback | Why |
|---|---|---|---|
| PDF → page image, page count, cover, metadata | **`pdfx`** (~2.9.2) | **`pdfrx`** (~2.4.4, PDFium, very actively maintained) | We do **not** use any package's built-in viewer — we drive our own curl. `pdfx`'s `PdfDocument` / `PdfPage.render()` → `PdfPageImage` is a simple, mature raster API that is exactly our use case. If `pdfx` shows issues on Flutter 3.41 or very large PDFs, swap to `pdfrx` (newer, faster PDFium core) behind the same `PdfService` interface. |
| Page-curl turning (THE crux) | **Vendored `RealisticFlipbook`** engine at [lib/flip_book/flip_book.dart](lib/flip_book/flip_book.dart) | `page_flip` (~0.2.5+1) → `flip_page` (~0.1.2) | A self-contained 3D flipbook (a `flipbook-vue`/turn.js port; Flutter-SDK-only, **no new dependency**; verified `flutter analyze` clean on 3.41.4). It does a **true 3D polygon curl** with perspective + per-strip diffuse **shadow** and specular **gloss** — higher fidelity than either pub package — and crucially takes per-page content as an **`ImageProvider`** (`FlipbookPage.image`), which is exactly how we hand it rasterized PDF pages. Ships a `FlipbookController` (`flipLeft`/`flipRight`/`goToPage`) for tap-zones + Go-To, drag+tap flipping with fling/revert, and `onFlipLeftEnd`/`onFlipRightEnd` completion callbacks (our hook for sound + haptic + resume-save). We still wrap it behind a thin `BookCurlView` abstraction (one file) so the documented pub-package fallbacks remain a localized swap. **Mitigations baked into the plan:** (a) it assumes a **uniform page size** (measures page 1, paints `BoxFit.fill`) — fine for typical PDFs; (b) it takes an **eager `List<FlipbookPage?>`**, so we feed it a custom lazy `PdfPageImageProvider` and bound memory via Flutter's global `imageCache`; (c) pass `singlePage: true` for portrait v1 (landscape spread → stretch). Add an MIT attribution header to the file. |
| File picking (PDF) | **`file_picker`** (~11.0.2) | — | `FileType.custom` + `allowedExtensions: ['pdf']`. |
| Storage permissions | **`permission_handler`** (~12.0.3) | — | Android 13+ aware (`manageExternalStorage`; `Permission.storage` deprecated on 13+). |
| Filesystem paths / app dirs | **`path_provider`** | — | App documents/support dirs for imported PDFs + cover cache. |
| Page-turn sound (low latency) | **`audioplayers`** (~6.8.0) | — | Preloaded `AssetSource` + `PlayerMode.lowLatency`. |
| Native splash (no white flash) | **`flutter_native_splash`** (~2.4.8) | — | Has Android 12+ support and configurable bg color + image. |
| Animated splash / micro-animations | **`flutter_animate`** | `lottie` (only if we ship a JSON) | `flutter_animate` covers fade/slide/scale/shimmer with zero assets; custom `CustomPaint` book for the centerpiece. `lottie` optional if we later drop in a JSON animation. |
| Shimmer placeholders | **`flutter_animate`** `.shimmer()` | — | Avoids an extra `shimmer` dependency. |
| Typography | **bundled font assets** (Fraunces/Playfair Display, Lora, Inter) | — | **We do NOT add `google_fonts`** (no runtime fetch). We bundle TTFs as assets and register families in `pubspec.yaml` for offline reliability + fewer deps. (Justified deviation from the suggested set.) |
| Persistence (library, recents, bookmarks) | **`hive_ce`** (~2.19.3), **map-based** storage | — | Maintained Hive fork. We store each model as a `Map` in typed boxes (each model has `toMap()`/`fromMap()`), so **no `build_runner`/codegen** is required and the app compiles at every step. `hive_ce_generator` noted as optional if typed adapters are later desired. |
| Settings persistence | **`shared_preferences`** | — | Simple key/values for `AppSettings`. |
| State management | **`provider`** | — | Simple, robust, step-by-step friendly. `ChangeNotifier`: `LibraryProvider`, `ReaderProvider`, `SettingsProvider`. (Do **not** mix in Riverpod.) |
| Routing | **`go_router`** | — | Routes: `/splash` → `/home` → `/reader/:bookId`. Custom fade/shared-axis transitions; hero cover→reader. |
| In-reader brightness | **`screen_brightness`** (~2.1.11) | — | App-scoped brightness, auto-resets on lifecycle. |
| Keep awake | **`wakelock_plus`** | — | Enable while reader is open. |
| Haptics | built-in `HapticFeedback` | — | Light impact on completed turn + key actions. |
| Hashing (stable book id + cache keys) | **`crypto`** | — | `sha1` of `filePath + fileSize`. |
| App icon | **`flutter_launcher_icons`** (dev) | — | Generate adaptive Android + iOS icons. |
| Icon set | built-in **Material Icons rounded** variants (`Icons.*_rounded`) | `lucide_icons` | One consistent rounded set, zero extra dependency. |

### Repo facts confirmed (and deltas from the brief)
- ✅ Flutter 3.41.4 / Dart 3.11.1; module name `comfy_reader`; Android `applicationId`/`namespace` = `com.example.comfy_reader`; Kotlin Gradle DSL; SDK levels inherit Flutter defaults (Java 17).
- ✅ `lib/` has the default counter `main.dart` **plus a vendored 3D flipbook engine at [lib/flip_book/flip_book.dart](lib/flip_book/flip_book.dart)** (`RealisticFlipbook`, ~3,560 lines, Flutter-SDK-only, analyzes clean) — this is the page-curl engine (see decision table). No `assets/` dir. `AndroidManifest.xml` declares **no permissions**; `android:label="comfy_reader"`. Default launcher icon. `pubspec.lock` already present.
- ⚠️ **Delta:** iOS `Info.plist` **already** has `CFBundleDisplayName = "Comfy Reader"`. Only `CFBundleName` (still `comfy_reader`) and the **Android** `android:label` need changing.
- ⚠️ **Delta:** iOS scaffold uses **`SceneDelegate.swift`** + `UIApplicationSceneManifest` (newer Flutter iOS template), not just `AppDelegate.swift`. `flutter_native_splash` supports this; orientation locking is done in Dart via `SystemChrome`.
- ⚠️ **Delta:** iOS `Info.plist` currently allows landscape. Since v1 is portrait-primary, we will lock to portrait in Dart (and may trim the plist) — landscape stays a stretch item.

---

## How to execute this plan

1. **Do exactly one step at a time, in order.** Each step is self-contained and leaves the app compiling and runnable.
2. After each step, run the step's **Done when** commands — at minimum `flutter analyze` must be clean (no errors; warnings triaged), and where stated, `flutter run` on a device/emulator must show the described result.
3. **Check the box** (`- [x]`) for the step in this file the moment it's verified. Do not silently skip steps; if a step must change, edit it here first.
4. **Obey the Guardrails** (Section 8 of the brief): stay in scope (PDF only), design system is law (no scattered hardcoded styling — everything consumes `core/theme` tokens), performance is a feature (lazy render + cache), clean null-safe commented Dart, add packages with `flutter pub add` (no hand-pinned versions unless a conflict forces it).
5. Keep widgets small and focused; keep platform nuances (Android storage permissions, iOS sandbox) handled explicitly.

> **Performance contract (applies to every Reader/cover step):** never decode more than the current page ±2; cache decoded page images in an LRU map capped by count *and* approximate bytes; evict far pages; show a per-page loading state; must stay smooth on a 500+ page PDF with no curl jank.

---

## Phase 0 — Project setup & config

### Step 0.1 — Replace the default counter app with a minimal placeholder
- [x] **Replace `main.dart` so nothing references the counter demo.**
- **Goal:** Start from a clean, compiling base before we add the real shell.
- **Files:** modify `lib/main.dart`.
- **Packages:** none.
- **Implementation details:** Replace the entire file with a minimal `void main() => runApp(const ComfyReaderApp());` and a `ComfyReaderApp` `StatelessWidget` returning a `MaterialApp` (title `'Comfy Reader'`, `debugShowCheckedModeBanner: false`) whose `home` is a `Scaffold` with a centered `Text('Comfy Reader')`. No counter, no `FloatingActionButton`. This is throwaway scaffolding that Phase 1 replaces with `app.dart`.
- **Done when:** `flutter analyze` is clean; `flutter run` shows a blank screen with centered "Comfy Reader" text and no purple counter UI.

### Step 0.2 — Add all runtime + dev dependencies
- [x] **Add the full package set via `flutter pub add` (resolver picks versions).**
- **Goal:** Get every dependency resolving together once, up front.
- **Files:** `pubspec.yaml` (via CLI), `pubspec.lock`.
- **Packages:**
  ```
  flutter pub add pdfx file_picker permission_handler path_provider audioplayers \
    flutter_native_splash flutter_animate hive_ce shared_preferences provider \
    go_router screen_brightness wakelock_plus crypto
  flutter pub add dev:flutter_launcher_icons
  ```
- **Implementation details:** Run the commands, then `flutter pub get`. If the resolver reports a conflict, resolve by relaxing/pinning only the conflicting package (note it here). Do **not** add `google_fonts`, `shimmer`, `lottie`, `page_flip`, `flip_page`, or `pdfrx` — those are fallbacks/optional and added only if needed. **No curl package is required at all:** the page-curl engine is the vendored `RealisticFlipbook` already at [lib/flip_book/flip_book.dart](lib/flip_book/flip_book.dart) (Flutter-SDK-only). The pub fallbacks would only be added in Step 4.3 if that engine is ever abandoned.
- **Done when:** `flutter pub get` succeeds with no version conflicts; `flutter analyze` clean; `flutter run` still shows the placeholder. Record the resolved versions of `pdfx`, `flip_page` (added later), `hive_ce`, `permission_handler` in a comment in `pubspec.yaml` if useful.
- **Resolved (actual):** `pdfx 2.9.2`, `file_picker 11.0.2`, `permission_handler 12.0.3`, `audioplayers 6.7.1`, `flutter_native_splash 2.4.7`, `flutter_animate 4.5.2`, `hive_ce 2.19.3`, `provider 6.1.5+1`, `go_router 17.3.0`, `screen_brightness 2.1.11`, `crypto 3.0.7`. **Dependency conflict fixed:** `wakelock_plus 1.6.x` needs `win32 ^6` but `file_picker 11` needs `win32 ^5.9`; Flutter type-checks the whole package graph (incl. unused Windows source), so a `win32 ^6` override breaks `file_picker`'s build. Fix = pin `wakelock_plus: ">=1.5.2 <1.6.0"` (last release on win32 5.x; identical enable/disable API) so `win32` resolves to `5.15.0`. No `dependency_overrides`.

### Step 0.3 — Create the assets directory structure and register it
- [x] **Create `assets/` subfolders and declare them in `pubspec.yaml`.**
- **Goal:** Establish asset locations every later step references via constants.
- **Files:** create `assets/audio/`, `assets/animations/`, `assets/images/`, `assets/fonts/` (add a `.gitkeep` to each empty folder); modify `pubspec.yaml` `flutter:` section.
- **Packages:** none.
- **Implementation details:** Under `flutter:` add an `assets:` list registering `assets/audio/`, `assets/images/`, `assets/animations/` (folder form). Leave `fonts:` for Step 0.4. Keep `uses-material-design: true`.
- **Done when:** `flutter analyze` clean; `flutter run` builds with no "asset directory does not exist" error.

### Step 0.4 — Bundle and register fonts
- [x] **Add Fraunces (or Playfair Display), Lora, and Inter TTFs as assets and register families.**
- **Goal:** Offline-reliable premium typography with no runtime fetch.
- **Files:** add `.ttf` files under `assets/fonts/`; modify `pubspec.yaml` `fonts:` section.
- **Packages:** none (intentionally no `google_fonts`).
- **Implementation details:** Download static TTFs from Google Fonts: a display serif (**Fraunces** preferred, Playfair Display acceptable) in Regular + SemiBold/Bold; **Lora** Regular + Medium/SemiBold (book titles); **Inter** Regular + Medium + SemiBold (UI/body). Register three families: `Fraunces` (or `PlayfairDisplay`), `Lora`, `Inter`, mapping each weight to its asset + `weight:`. Use exact family names — `AppTypography` (Step 1.2) references these strings.
- **Done when:** `flutter analyze` clean; a temporary `Text('Aa', style: TextStyle(fontFamily: 'Fraunces'))` on the placeholder screen renders in the serif (remove the temporary text after verifying).
- **Done (actual):** Bundled **variable** TTFs (downloaded from the `google/fonts` repo): `Fraunces-Variable.ttf`, `Lora-Variable.ttf`, `Inter-Variable.ttf`, registered as families `Fraunces`/`Lora`/`Inter`. Because they are variable fonts, **AppTypography (Step 1.2) must select weights via `fontVariations: [FontVariation('wght', n)]`** (plain `fontWeight` interpolates but `fontVariations` is exact). Verified on the Android emulator: the placeholder "Comfy Reader" renders in Fraunces serif on cream. Placeholder brand art (`splash_logo`, `app_icon`, `app_icon_foreground`) was generated with PIL (cozy open-book mark); final art lands in Phase 7.

### Step 0.5 — Configure the native splash (no white flash)
- [x] **Set up `flutter_native_splash` with a warm background + centered logo.**
- **Goal:** Eliminate the white launch flash before our animated splash.
- **Files:** create `flutter_native_splash.yaml` at repo root; add a `assets/images/splash_logo.png` (simple monogram/book mark on transparent bg).
- **Packages:** uses `flutter_native_splash` (already added).
- **Implementation details:** In `flutter_native_splash.yaml` set `color: "#F6EEE0"` (Day background), `image: assets/images/splash_logo.png`, a `color_dark: "#1A1714"` + `image_dark`, and an `android_12:` block (`color`, `image`, `icon_background_color`). Then run `dart run flutter_native_splash:create`. This regenerates Android `drawable`/`values` splash resources and iOS `LaunchScreen` assets (works with the SceneDelegate template).
- **Done when:** `flutter analyze` clean; on a cold `flutter run`, the launch screen shows the warm background + logo with **no white flash** before the Flutter UI appears.

### Step 0.6 — Set the app display name to "Comfy Reader"
- [x] **Fix Android `android:label` and iOS `CFBundleName`.**
- **Goal:** Correct launcher/app name on both platforms.
- **Files:** modify `android/app/src/main/AndroidManifest.xml`; modify `ios/Runner/Info.plist`.
- **Packages:** none.
- **Implementation details:** Android: change `android:label="comfy_reader"` → `android:label="Comfy Reader"` on `<application>`. iOS: `CFBundleName` is currently `comfy_reader` → set to `Comfy Reader` (string value, not the `$(...)` var). `CFBundleDisplayName` is already `Comfy Reader` — leave it. Do **not** touch `applicationId`/`namespace`/bundle id (`com.example.comfy_reader`).
- **Done when:** `flutter analyze` clean; after reinstall, the launcher icon label and app switcher show **"Comfy Reader"** on Android and iOS.

### Step 0.7 — Generate the launcher icon
- [x] **Configure `flutter_launcher_icons` and generate adaptive icons.**
- **Goal:** Replace the default Flutter launcher icon with the brand mark.
- **Files:** add `assets/images/app_icon.png` (1024×1024) and `assets/images/app_icon_foreground.png` (adaptive foreground); add a `flutter_launcher_icons` config (in `pubspec.yaml` or `flutter_launcher_icons.yaml`).
- **Packages:** uses dev `flutter_launcher_icons` (already added).
- **Implementation details:** Config: `image_path: assets/images/app_icon.png`, `android: true`, `adaptive_icon_background: "#F6EEE0"`, `adaptive_icon_foreground: assets/images/app_icon_foreground.png`, `ios: true`, `remove_alpha_ios: true`. Run `dart run flutter_launcher_icons`. (Placeholder art is fine now; final art lands in Phase 7.)
- **Done when:** `flutter analyze` clean; reinstalled app shows the new icon on the Android home screen and iOS springboard.

### Step 0.8 — Android permissions + verify SDK levels
- [x] **Declare storage permissions/queries in `AndroidManifest.xml`; verify `minSdk`.**
- **Goal:** Enable (best-effort) device PDF scanning and ensure PDFium-backed rendering builds.
- **Files:** modify `android/app/src/main/AndroidManifest.xml`; possibly `android/app/build.gradle.kts`.
- **Packages:** none.
- **Implementation details:**
  - Add, above `<application>`: `READ_EXTERNAL_STORAGE` with `android:maxSdkVersion="32"`; `MANAGE_EXTERNAL_STORAGE`. Note: `MANAGE_EXTERNAL_STORAGE` is the only way to broadly scan arbitrary `.pdf` files on Android 13+ (PDFs are not "media", so `READ_MEDIA_*` does **not** cover them) and triggers a **Google Play sensitive-permission declaration** — we request it only when the user opts into device scan, and fall back to file-picker import otherwise (Step 3.7). Document this caveat in `permission_service.dart`.
  - Keep the existing `<queries>` block; the system file picker (SAF) needs no extra permission.
  - SDK levels: `pdfx`/PDFium typically need `minSdk ≥ 21`. Flutter 3.41's default `flutter.minSdkVersion` already satisfies this. Only if a build error demands it, set `minSdk = 21` explicitly in `defaultConfig`. Leave `compileSdk`/`targetSdk` inheriting Flutter defaults.
- **Done when:** `flutter analyze` clean; `flutter run` on an Android device builds and launches with no manifest-merge or minSdk errors.

### Step 0.9 — iOS Info.plist: file sharing + orientation
- [x] **Enable open-in-place/file-sharing and lock portrait on iOS.**
- **Goal:** Let users add PDFs via Files/share-sheet (sandbox) and keep v1 portrait.
- **Files:** modify `ios/Runner/Info.plist`.
- **Packages:** none.
- **Implementation details:** Add `UIFileSharingEnabled = true` and `LSSupportsOpeningDocumentsInPlace = true` so PDFs can be opened into the app's Documents dir. `file_picker` (UIDocumentPicker) needs no usage-string. Trim `UISupportedInterfaceOrientations` (iPhone) to `UIInterfaceOrientationPortrait` only for v1 (keep iPad as-is or also portrait). We additionally enforce portrait in Dart via `SystemChrome.setPreferredOrientations` at app start (Step 1.11).
- **Done when:** `flutter analyze` clean; iOS build runs portrait-only; the app appears in the Files app "open with"/share targets (verify in Phase 6 iOS pass).

### Step 0.10 — Lint + .gitignore housekeeping
- [x] **Tighten `analysis_options.yaml` and ignore generated artifacts.**
- **Goal:** Consistent style and a clean repo.
- **Files:** modify `analysis_options.yaml`, `.gitignore`.
- **Packages:** none.
- **Implementation details:** In `analysis_options.yaml`, under `linter: rules:` enable `prefer_single_quotes: true`, `require_trailing_commas: true`, `directives_ordering: true`, `prefer_const_constructors: true`. Optionally add an `analyzer: exclude:` for generated files. In `.gitignore`, ensure generated splash/icon outputs and `**/*.g.dart` (if codegen is ever added) are handled; keep committing `pubspec.lock`.
- **Done when:** `flutter analyze` is clean under the stricter rules (fix any new lints in our own files).

---

## Phase 1 — Foundation (design system, models, services, routing, shell)

### Step 1.1 — Design tokens: colors, dimens, durations, asset paths
- [x] **Create the central token files.**
- **Goal:** Single source of truth for color/spacing/radius/motion/assets (Design system is law).
- **Files:** create `lib/core/theme/app_colors.dart`, `lib/core/theme/dimens.dart`, `lib/core/constants/durations.dart`, `lib/core/constants/asset_paths.dart`.
- **Packages:** none.
- **Implementation details:**
  - `AppColors`: `abstract final class` with `static const Color` for Day (`dayBackground #F6EEE0`, `daySurface #FFFBF3`, `dayText #3A2E25`, `accentTerracotta #C56A4E`, `secondarySage #7C8C72`, `highlightGold #D9A441`, `readingPaper #F4ECD8`, `readingPaperText #2B2117`) and Night (`nightBackground #1A1714`, `nightSurface #241F1A`, `nightText #E8DFD0`, `accentAmber #E0A458`, `readingNight #141210`, `readingNightText #C9BFAE`).
  - `Dimens`: 8px spacing scale (`space1=4, space2=8, space3=12, space4=16, space6=24, space8=32`), radii (`radiusCard=18`, `radiusSmall=12`, `radiusPill=999`), card aspect ratio `bookAspect = 3/4`, soft shadow color/blur constants.
  - `AppDurations`: `fast=200ms`, `base=300ms`, `slow=400ms`, `splash=3000ms`, `overlayAutoHide=4s`, `resumeSaveDebounce=600ms`.
  - `AssetPaths`: `static const String` for `pageFlipSound = 'assets/audio/page_flip.mp3'`, `splashLogo`, `emptyState`, etc.
- **Done when:** `flutter analyze` clean; files compile (no UI yet).

### Step 1.2 — Typography scale
- [x] **Create `AppTypography` using the bundled font families.**
- **Goal:** A consistent, named text-style scale.
- **Files:** create `lib/core/theme/app_typography.dart`.
- **Packages:** none.
- **Implementation details:** `abstract final class AppTypography` exposing `static const TextStyle`: `wordmark` (Fraunces, ~28, w600), `displayLarge`/`sectionTitle` (Fraunces), `bookTitle` (Lora, ~16, w600), `bodyLarge`/`bodyMedium`/`label`/`caption` (Inter). Colors are applied by the theme (leave `color` null here; set via `ThemeData.textTheme`). Provide a helper to build a `TextTheme` from these for Step 1.3.
- **Done when:** `flutter analyze` clean.

### Step 1.3 — Theme system (light & dark `ThemeData`)
- [x] **Create `AppTheme` producing `ThemeData` for Day and Night from tokens.**
- **Goal:** Every screen consumes one theme; no hardcoded styling downstream.
- **Files:** create `lib/core/theme/app_theme.dart`.
- **Packages:** none.
- **Implementation details:** `AppTheme.light` and `AppTheme.dark` build `ThemeData(useMaterial3: true, colorScheme: ...)` seeded/overridden from `AppColors` (light: surface cream, primary terracotta, secondary sage; dark: warm dark + amber). Configure `scaffoldBackgroundColor`, `cardTheme` (radius `Dimens.radiusCard`, soft warm shadow, surface color), `textTheme` from `AppTypography`, `appBarTheme` (transparent/surface, serif title), `floatingActionButtonTheme` (accent), `sliderTheme`, `iconTheme` (rounded). Expose a custom `ThemeExtension` (`ComfyColors`) carrying brand colors not in `ColorScheme` (gold highlight, reading paper/sepia/night tints) so widgets read them type-safely.
- **Done when:** `flutter analyze` clean; temporarily wire `AppTheme.light/dark` into the placeholder `MaterialApp` and confirm the placeholder text adopts cream bg + serif (revert wiring or leave; Step 1.11 finalizes).

### Step 1.4 — Data models
- [x] **Create `BookModel`, `BookmarkModel`, `AppSettings` (+ enums) with map (de)serialization.**
- **Goal:** Typed, persistable domain models (no codegen).
- **Files:** create `lib/models/book_model.dart`, `lib/models/bookmark_model.dart`, `lib/models/app_settings.dart`, `lib/models/enums.dart`.
- **Packages:** none.
- **Implementation details:**
  - `enums.dart`: `enum PageTint { paper, sepia, night }`, `enum LibraryView { grid, list }`, `enum SortMode { recent, name, dateAdded }`, `enum AppThemeMode { system, day, night }`.
  - `BookModel { String id; String title; String filePath; String? coverImagePath; int totalPages; int lastReadPage; double progress; int fileSize; DateTime addedAt; DateTime? lastOpened; bool isImported; }` — `id` = `sha1(filePath + fileSize)` (Step 1.x uses `crypto`); `progress` derived = `(lastReadPage+1)/totalPages`. Add `toMap()`/`fromMap()` (DateTimes as `millisecondsSinceEpoch`), `copyWith`, and a `factory` to build a fresh book from a file path.
  - `BookmarkModel { String bookId; int pageIndex; DateTime createdAt; String? note; }` + `toMap`/`fromMap`.
  - `AppSettings { AppThemeMode themeMode; bool soundEnabled; double soundVolume; bool hapticsEnabled; PageTint pageTint; bool keepScreenOn; }` with sensible defaults (sound on, volume 0.7, haptics on, tint paper, keepScreenOn on) + `toMap`/`fromMap`/`copyWith`.
- **Done when:** `flutter analyze` clean; add a throwaway unit test or `assert` round-tripping each model through `toMap`/`fromMap` (then remove).

### Step 1.5 — Storage service (Hive CE + SharedPreferences init)
- [x] **Create `StorageService` that opens Hive boxes and SharedPreferences.**
- **Goal:** Centralized persistence bootstrap used by other services.
- **Files:** create `lib/services/storage_service.dart`.
- **Packages:** uses `hive_ce`, `shared_preferences`, `path_provider`.
- **Implementation details:** `StorageService.init()` (async, called in `main`): `Hive.init(appSupportDir)` (via `path_provider`), open `Box<Map> booksBox` (`'books'`) and `Box<Map> bookmarksBox` (`'bookmarks'`); init `SharedPreferences`. Expose getters for the boxes + prefs. Store models as `Map` (call `model.toMap()`), keyed by `book.id` / `'${bookId}:${pageIndex}'`. Provide CRUD helpers: `saveBook`, `deleteBook`, `allBooks()`, `saveBookmark`, `deleteBookmark`, `bookmarksFor(bookId)`. No codegen/adapters.
- **Done when:** `flutter analyze` clean; a temporary call in `main` opens boxes without error on `flutter run`.

### Step 1.6 — Settings service + provider
- [x] **Create `SettingsService` (persist `AppSettings`) and `SettingsProvider`.**
- **Goal:** App-wide reactive settings driving theme and reader behavior.
- **Files:** create `lib/services/settings_service.dart`, `lib/providers/settings_provider.dart`.
- **Packages:** uses `shared_preferences` (via `StorageService`), `provider`.
- **Implementation details:** `SettingsService` reads/writes `AppSettings` to SharedPreferences (single JSON string key `'app_settings'`). `SettingsProvider extends ChangeNotifier` holds current `AppSettings`, exposes setters (`setThemeMode`, `setSoundEnabled`, `setSoundVolume`, `setHaptics`, `setPageTint`, `setKeepScreenOn`) that persist + `notifyListeners()`. Loads in constructor/`load()`.
- **Done when:** `flutter analyze` clean.

### Step 1.7 — Permission service
- [x] **Create `PermissionService` for the Android storage flow.**
- **Goal:** Encapsulate platform permission logic + rationale.
- **Files:** create `lib/services/permission_service.dart`.
- **Packages:** uses `permission_handler`.
- **Implementation details:** Methods: `Future<bool> ensureStorageAccess()` — on iOS return `true` (sandbox, no scan); on Android, branch by SDK: request `Permission.manageExternalStorage` (broad scan) and report granted/denied; expose `Future<bool> hasBroadAccess()`. Provide `String get rationaleText` (shown before requesting — Step 7.3). Never throw on denial; callers degrade to import-only.
- **Done when:** `flutter analyze` clean.

### Step 1.8 — PDF service (render, cover, page count, metadata)
- [x] **Create `PdfService` wrapping `pdfx`.**
- **Goal:** The single boundary for all PDF rasterization (swappable to `pdfrx`).
- **Files:** create `lib/services/pdf_service.dart`.
- **Packages:** uses `pdfx`.
- **Implementation details:** Methods (all async, isolate/compute-friendly where possible):
  - `Future<int> pageCount(String path)` — open `PdfDocument.openFile`, read `.pagesCount`, close.
  - `Future<Uint8List> renderPage(String path, int pageIndex, {required double targetWidth})` — open doc, get page, `page.render(width, height, format: PdfPageImageFormat.png, backgroundColor: '#FFFFFF')`, return bytes; compute height from page aspect to keep ratio; close page/doc.
  - `Future<String> generateCover(BookModel book, {double width = 600})` — render page 0, write PNG to `coversDir/{book.id}.png` (via `path_provider`), return path; skip if exists.
  - Keep documents **short-lived** (open→render→close) to bound native memory; the in-memory image LRU (Step 4.2) handles reuse. Wrap all calls in try/catch returning a typed result so callers can show error states.
- **Done when:** `flutter analyze` clean; a temporary debug call renders page 0 of a sample PDF and logs byte length > 0.

### Step 1.9 — Audio service (page-turn sound)
- [x] **Create `AudioService` with a preloaded low-latency player.**
- **Goal:** Instant, glitch-free page-turn sound.
- **Files:** create `lib/services/audio_service.dart`; add `assets/audio/page_flip.mp3` (short, subtle flip sound).
- **Packages:** uses `audioplayers`.
- **Implementation details:** Singleton holding an `AudioPlayer` set to `PlayerMode.lowLatency`; `init()` preloads `AssetSource('audio/page_flip.mp3')` via `setSource`. `playPageTurn({required bool enabled, required double volume})` → if enabled, `setVolume(volume)` + `resume()`/`seek(0)` to replay quickly. Guard against overlap. Provide `dispose()`.
- **Done when:** `flutter analyze` clean; a temporary button triggers an audible flip sound on device (remove the button).

### Step 1.10 — Library service + provider (discover, import, persist)
- [x] **Create `LibraryService` and `LibraryProvider`.**
- **Goal:** Own the book list lifecycle: discover, import, cover-gen, persistence, sort/filter.
- **Files:** create `lib/services/library_service.dart`, `lib/providers/library_provider.dart`.
- **Packages:** uses `file_picker`, `path_provider`, `crypto`, plus `StorageService`/`PdfService`/`PermissionService`.
- **Implementation details:**
  - `LibraryService.importFromPicker()` — open `file_picker` (`FileType.custom`, `allowedExtensions: ['pdf']`), copy chosen file into app Documents `books/` dir (so it persists; required on iOS), build `BookModel` (id via `crypto` sha1), `pageCount` + `generateCover`, save to Hive. Returns the new `BookModel`.
  - `LibraryService.scanDevice()` (Android only) — if broad access granted, recursively walk common dirs (`/storage/emulated/0/Download`, `/Documents`, `/Books`, `/DCIM`? no — docs only) for `*.pdf`, dedupe by id, import metadata + covers; throttle cover generation. iOS: return persisted/imported books only.
  - `LibraryService.allBooks()`, `removeBook(id)` (also delete copied file + cover), `updateProgress(id, page)`.
  - `LibraryProvider extends ChangeNotifier`: holds `List<BookModel>`, `LibraryView`, `SortMode`, `searchQuery`, `isScanning`; exposes `filteredSortedBooks` getter, `recents` getter (lastOpened desc, started only), and async actions delegating to the service with `notifyListeners()`.
- **Done when:** `flutter analyze` clean; provider instantiates and `allBooks()` returns persisted books (empty initially) without error.

### Step 1.11 — Routing + app shell + bootstrap
- [x] **Create `app.dart` (MaterialApp.router + providers + theme) and finalize `main.dart`.**
- **Goal:** Wire everything into a runnable shell with real routing.
- **Files:** create `lib/app.dart`, `lib/core/router/app_router.dart`; rewrite `lib/main.dart`.
- **Packages:** uses `go_router`, `provider`.
- **Implementation details:**
  - `main.dart`: `WidgetsFlutterBinding.ensureInitialized()`, `SystemChrome.setPreferredOrientations([portraitUp])`, `await StorageService.init()`, `await AudioService.init()`, then `runApp(ComfyReaderApp())`.
  - `app.dart`: `MultiProvider` (Settings, Library providers; Reader provider is created per-route in Phase 4) → `Consumer<SettingsProvider>` → `MaterialApp.router(theme: AppTheme.light, darkTheme: AppTheme.dark, themeMode: mapped from settings, routerConfig: appRouter)`.
  - `app_router.dart`: `GoRouter` routes `/splash` (initial), `/home`, `/reader/:bookId`. Provide custom `CustomTransitionPage` (fade/shared-axis). Temporary placeholder widgets for home/reader until their phases.
- **Done when:** `flutter analyze` clean; `flutter run` launches → native splash → `/splash` placeholder; manual `context.go('/home')` works. Theme switches Day/Night when `SettingsProvider.themeMode` changes (test via a temporary toggle).
- **Done (actual):** Verified on Android emulator — splash → Home flow works; Home shows the Fraunces wordmark app bar + empty-state; **Day↔Night toggle confirmed**. Added `AppPaths` util (Step 1.5) for books/covers dirs. **Placeholder screens created** at `features/{splash,home,reader}/*_screen.dart` — Phases 2/3/4 flesh these out (those "create" steps become "modify"). `home_screen.dart` has a **temporary theme-toggle action to remove in Phase 3**. `main()` inits `AppPaths` → `StorageService` → `AudioService` before `runApp`. (Debug first-frame on the x86 emulator is ~55–100s — a JIT/software-render artifact, not a code issue.)

---

## Phase 2 — Splash screen

### Step 2.1 — Animated in-app splash
- [x] **Build the cozy animated splash at `/splash`.**
- **Goal:** Deliver the premium first impression.
- **Files:** create `lib/features/splash/splash_screen.dart` (+ `lib/features/splash/widgets/book_mark_painter.dart` for the centerpiece).
- **Packages:** uses `flutter_animate` (and optionally `lottie` if a JSON is added to `assets/animations/`).
- **Implementation details:** Full-screen warm radial/mesh gradient (Day/Night aware) with a soft vignette. Centerpiece: either a `CustomPaint` self-drawing open-book/monogram or a Lottie of gently fluttering pages. Wordmark **"Comfy Reader"** in Fraunces fading + sliding up; tagline *"Read like it's a real book."* below, delayed. Use `flutter_animate` chains (`.fadeIn().slideY().scale()`, soft glow via `.shimmer()`/`.blur()`), total ~2.5–3.5s (`AppDurations.splash`). Respect reduced-motion (`MediaQuery.disableAnimations`) by shortening.
- **Done when:** `flutter analyze` clean; `flutter run` shows the animated splash with smooth motion, correct fonts/colors, in both Day and Night.

### Step 2.2 — Real init work + transition to Home
- [x] **Do startup work during the splash, then navigate to `/home`.**
- **Goal:** Use the splash time productively and transition smoothly.
- **Files:** modify `lib/features/splash/splash_screen.dart`.
- **Packages:** none new.
- **Implementation details:** In `initState`/a `Future`, run in parallel with the animation: `SettingsProvider.load()`, `LibraryProvider.loadFromStorage()` (read persisted books + warm covers into memory), `PermissionService.hasBroadAccess()` check (no prompt here). Await `max(animationDuration, workDuration)` then `context.go('/home')` via the router's fade/shared-axis transition. Guard against navigating after dispose.
- **Done when:** `flutter analyze` clean; cold launch flows native splash → animated splash → Home with no flash/jank; persisted books are already loaded when Home appears.

---

## Phase 3 — Home / Library

### Step 3.1 — Home scaffold + app bar
- [x] **Build the Home screen shell and app bar.**
- **Goal:** The library frame everything else slots into.
- **Files:** create `lib/features/home/home_screen.dart`.
- **Packages:** none new.
- **Implementation details:** `Scaffold` with a `CustomScrollView`/`NestedScrollView`. App bar: serif wordmark **"Comfy Reader"** left; actions: search (toggles a search field — Step 3.9), grid/list toggle (Step 3.4), Day/Night quick toggle (flips `SettingsProvider.themeMode`), overflow → push Settings (Phase 5). Body shows `Consumer<LibraryProvider>` with sections: Continue Reading (3.8), Library (3.3/3.4). FAB placeholder (3.6).
- **Done when:** `flutter analyze` clean; `flutter run` shows the themed app bar + empty body (empty state arrives in 3.10); Day/Night toggle works.

### Step 3.2 — Book card + cover image + shimmer placeholder
- [x] **Build `BookCard` and a reusable cover widget with shimmer.**
- **Goal:** The core library tile (cover + name + meta + progress).
- **Files:** create `lib/features/home/widgets/book_card.dart`, `lib/features/home/widgets/book_cover.dart`, `lib/shared/widgets/shimmer_box.dart`.
- **Packages:** uses `flutter_animate` for shimmer.
- **Implementation details:** `BookCover` takes a `BookModel`; shows the cover image from `coverImagePath` (FileImage) at `Dimens.bookAspect` with rounded corners + soft warm shadow + a subtle page-edge detail; while the cover is still generating, show `ShimmerBox`. `BookCard` = `BookCover` + **PDF name below** (Lora, 1–2 lines, ellipsis) + small meta (page count or size) + a thin progress bar if `progress > 0`. Whole card and the name are both tappable → `context.go('/reader/${book.id}')` (Tapping cover OR name opens reader). Long-press → context menu (Step 3.11). Wrap cover in a `Hero(tag: book.id)` for the cover→reader transition.
- **Done when:** `flutter analyze` clean; with a fake/imported book, the card renders cover + name + meta; shimmer shows when cover path is null.

### Step 3.3 — Library grid (default)
- [x] **Render the library as a 2–3 column grid.**
- **Goal:** Default browse view.
- **Files:** create `lib/features/home/widgets/library_grid.dart`; modify `home_screen.dart`.
- **Packages:** none new.
- **Implementation details:** `SliverGrid` with `SliverGridDelegateWithMaxCrossAxisExtent` (≈180px max extent → 2–3 columns responsive), spacing from `Dimens`, `childAspectRatio` accounting for cover + label. Feed `LibraryProvider.filteredSortedBooks`. Staggered fade/slide-in of items via `flutter_animate` (Step 6.2 refines).
- **Done when:** `flutter analyze` clean; imported books appear in a responsive grid; tapping opens the (placeholder) reader.

### Step 3.4 — List view + grid/list toggle
- [x] **Add a list layout and wire the app-bar toggle.**
- **Goal:** Alternate compact view.
- **Files:** create `lib/features/home/widgets/library_list.dart`; modify `home_screen.dart`, `library_provider.dart`.
- **Packages:** none new.
- **Implementation details:** `library_list.dart`: row = small `BookCover` + name + meta + progress. `LibraryProvider.libraryView` toggled by the app-bar action; persist preference (optional via settings). `home_screen` switches between `LibraryGrid`/`LibraryList` with an `AnimatedSwitcher`.
- **Done when:** `flutter analyze` clean; toggling switches layouts smoothly; both open the reader.

### Step 3.5 — Cover generation pipeline + caching
- [x] **Generate + cache covers on import/discovery, off the UI thread.**
- **Goal:** Fast, persistent covers without jank.
- **Files:** modify `lib/services/library_service.dart`, `lib/services/pdf_service.dart`; create `lib/core/utils/cover_cache.dart`.
- **Packages:** none new.
- **Implementation details:** Covers persist to `coversDir/{id}.png` (Step 1.8). Generate lazily: when a book lacks `coverImagePath`, enqueue generation (bounded concurrency, e.g. 2–3 at a time) and update the provider per-cover so cards fill in progressively (shimmer → image). Cache `FileImage`s in Flutter's `ImageCache`. Never regenerate an existing cover.
- **Done when:** `flutter analyze` clean; importing several PDFs fills covers progressively with shimmer placeholders, and covers reload instantly on next launch.

### Step 3.6 — FAB import
- [x] **Add the "Add PDF" FAB → pick, import, cover, persist, snackbar.**
- **Goal:** Manual add path (works on all platforms incl. iOS).
- **Files:** create `lib/features/home/widgets/add_pdf_fab.dart`; modify `home_screen.dart`.
- **Packages:** uses `file_picker`.
- **Implementation details:** Accent-colored FAB ("+"/"Add PDF") bottom-right → `LibraryProvider.importFromPicker()` → on success show a snackbar ("Added '<name>'") with an **Open** action that navigates to the reader; on cancel, no-op; on error, error snackbar. Disable/spinner while importing.
- **Done when:** `flutter analyze` clean; tapping FAB opens the system PDF picker, the chosen PDF appears in the library with a cover and persists across restarts.

### Step 3.7 — Auto-discovery + pull-to-refresh
- [x] **Scan device for PDFs (Android) with permission; pull-to-refresh.**
- **Goal:** Auto-populate the library where the OS allows.
- **Files:** modify `lib/features/home/home_screen.dart`, `lib/services/library_service.dart`, `lib/services/permission_service.dart`.
- **Packages:** uses `permission_handler`.
- **Implementation details:** Wrap body in `RefreshIndicator`. On first launch and on pull-to-refresh: show the **permission rationale** (Step 7.3) then `PermissionService.ensureStorageAccess()`; if granted, `LibraryService.scanDevice()` recursively over Download/Documents/Books for `.pdf` (throttled), merging into the library; if denied/iOS, **gracefully** keep only imported books and show a gentle note ("Grant access or tap + to add PDFs"). Shimmer placeholders while covers render. Run the scan off the UI thread (`compute`/isolate where feasible).
- **Done when:** `flutter analyze` clean; on Android with access granted, device PDFs appear after refresh; with access denied, the app still works via import; on iOS only imported books show.

### Step 3.8 — Continue Reading section
- [x] **Show recent in-progress books at the top.**
- **Goal:** One-tap resume of recent reads.
- **Files:** create `lib/features/home/widgets/continue_reading.dart`; modify `home_screen.dart`.
- **Packages:** none new.
- **Implementation details:** Only render if `LibraryProvider.recents` is non-empty. Horizontal-scroll list of prominent cards: cover + title + progress bar + "page n of m • X%". Tap resumes at saved page (`/reader/:id`, reader restores `lastReadPage`). Hidden entirely when no started books.
- **Done when:** `flutter analyze` clean; after reading partway into a book (Phase 4 wires saving), it appears here with correct progress and resumes on tap.

### Step 3.9 — Search + sort
- [x] **Filter by name and sort (recent / name / date added).**
- **Goal:** Find books fast.
- **Files:** modify `home_screen.dart`, `library_provider.dart`; optional `lib/features/home/widgets/library_search_bar.dart`.
- **Packages:** none new.
- **Implementation details:** Search action reveals a search field bound to `LibraryProvider.searchQuery` (case-insensitive title contains). Sort menu (in app bar/overflow) sets `SortMode`; `filteredSortedBooks` applies filter then sort (recent = `lastOpened`/`addedAt` desc, name = A→Z, dateAdded = `addedAt` desc). Empty search result shows a "No matches" state.
- **Done when:** `flutter analyze` clean; typing filters live; each sort reorders correctly.

### Step 3.10 — Empty state
- [x] **Friendly cozy empty state when the library is empty.**
- **Goal:** Guide first-time users.
- **Files:** create `lib/features/home/widgets/empty_state.dart`; add `assets/images/empty_state.png` (cozy illustration).
- **Packages:** none new.
- **Implementation details:** Centered illustration + "No books yet — tap + to add a PDF." in brand styles. Shown when `filteredSortedBooks` is empty AND not scanning. Distinct copy for "no search matches" vs "library empty".
- **Done when:** `flutter analyze` clean; fresh install shows the empty state; it disappears once a book is added.

### Step 3.11 — Long-press context menu
- [x] **Long-press a book → remove / details / share.**
- **Goal:** Manage library items.
- **Files:** modify `book_card.dart`; create `lib/features/home/widgets/book_context_sheet.dart`.
- **Packages:** none new (use platform share via `Share`? — out of scope; use a simple "copy path"/system share intent only if trivial, else show details only).
- **Implementation details:** Long-press opens a bottom sheet: **Remove from library** (confirm; deletes copied file + cover + Hive entry via `LibraryProvider.removeBook`), **Details** (title, pages, size, added date, progress), **Share** (optional — only if a zero-config share is available; otherwise omit from v1 and park in Future). 
- **Done when:** `flutter analyze` clean; remove deletes the book + files and updates the grid; details shows correct metadata.

---

## Phase 4 — Reader (the star)

### Step 4.1 — Reader scaffold + immersive mode + document open
- [x] **Create the Reader screen, go full-screen, open the book, set up `ReaderProvider`.**
- **Goal:** The reading frame + per-book state.
- **Files:** create `lib/features/reader/reader_screen.dart`, `lib/providers/reader_provider.dart`; modify `app_router.dart` (provide `ReaderProvider` scoped to the route).
- **Packages:** none new.
- **Implementation details:** Route `/reader/:bookId` looks up the `BookModel` from `LibraryProvider`, creates a `ReaderProvider(book)`. On open: `SystemChrome.setEnabledSystemUIMode(immersiveSticky)` (hide system UI), warm paper `Scaffold` background (theme/tint aware), read `totalPages`, set `currentPage = book.lastReadPage`. On dispose: restore system UI, save position. `ReaderProvider` holds `currentPage`, `totalPages`, `isOverlayVisible`, `pageTint`, and the page-image cache handle.
- **Done when:** `flutter analyze` clean; opening a book hides system UI, shows a warm full-screen with the page index; back restores system UI.

### Step 4.2 — Lazy page render via a custom `PdfPageImageProvider`
- [x] **Build an on-demand PDF-page `ImageProvider` that bounds memory.**
- **Goal:** Smooth on 500+ page PDFs (Performance contract). `RealisticFlipbook` consumes one `ImageProvider` per page, so this is the lazy-render boundary.
- **Files:** create `lib/features/reader/pdf_page_image_provider.dart`; modify `reader_provider.dart`, `pdf_service.dart`, `main.dart` (image-cache limits).
- **Packages:** none new.
- **Implementation details:**
  - `PdfPageImageProvider extends ImageProvider<PdfPageKey>` where the key = `(bookId, pageIndex, targetWidth)`. `loadImage`/`load` calls `PdfService.renderPage(path, index, targetWidth)` (device-DPR-aware width), decodes to `ui.Image`, and returns it. Equality/hashCode on the key so Flutter's global `imageCache` de-dupes concurrent requests and reuses decoded frames — **this is the LRU**: tune `PaintingBinding.instance.imageCache.maximumSize` (≈12) and `maximumSizeBytes` in `main.dart` so far pages evict automatically.
  - The flipbook already precaches current ±3 and prunes; we don't need a separate widget cache. Render at a single target width per book (uniform-page assumption) so cache keys collide and reuse.
  - Renders run off the UI isolate where feasible (`PdfService` uses `compute`); per-page errors fall back to the flipbook's `blankPageColor` (its `Image.errorBuilder` already handles this).
- **Done when:** `flutter analyze` clean; a temporary `RealisticFlipbook` fed `PdfPageImageProvider`s for a 500+ page PDF flips smoothly with bounded memory (watch DevTools — decoded image count stays near the cache cap; far pages evict).

### Step 4.3 — Page-curl turning (BookCurlView wrapping RealisticFlipbook)
- [x] **Wire the vendored 3D flipbook behind a swappable abstraction, with drag + tap zones.**
- **Goal:** THE headline interaction.
- **Files:** create `lib/features/reader/widgets/book_curl_view.dart`; modify `reader_screen.dart`; add an MIT attribution/provenance header to [lib/flip_book/flip_book.dart](lib/flip_book/flip_book.dart).
- **Packages:** none — uses the vendored `RealisticFlipbook`. (Only if that engine is abandoned: `flutter pub add page_flip` and reimplement `BookCurlView` against it with the same public API.)
- **Implementation details:**
  - `BookCurlView` exposes a minimal API: `pageCount`, `currentIndex`, `controller` with `next()/previous()/jumpTo(i)`, and `onPageChanged(i)`. Internally it builds `pages: [for i in 0..n FlipbookPage(image: PdfPageImageProvider(book.id, i, targetWidth), sizeHint: firstPageSize)]` and renders a `RealisticFlipbook` with `controller: FlipbookController`, `singlePage: true` (portrait v1), warm `paperColor`, `bookChrome: false`, tuned `flipDuration`/`perspective`/`gloss`/`ambient` for a cozy curl, and a `loadingBuilder` (themed spinner).
  - Map `BookCurlView.controller.next()/previous()/jumpTo()` → `FlipbookController.flipRight()/flipLeft()/goToPage()`. Wire `onFlipLeftEnd`/`onFlipRightEnd` → `onPageChanged(controller.page-1)` (this is also the sound/haptic/resume hook in Steps 4.4/4.7).
  - **Tap zones:** set the flipbook's `tapToFlip: false` and `clickToZoom: false`, keep `dragToFlip: true` (the curl drag). Layer a sibling `GestureDetector` (HitTestBehavior.translucent so drags still reach the flipbook) reading tap x: **right third → controller.next(), left third → controller.previous(), center third → toggle overlay** (Step 4.5).
  - `sizeHint` from page 1's rendered size avoids the initial blank measure frame; given the uniform-size assumption, render all pages at the same `targetWidth` so the box matches.
- **Done when:** `flutter analyze` clean; swiping produces the 3D curl with shadow + gloss; tap thirds turn/toggle; `goToPage` jumps; a 500-page PDF stays smooth with no jank.

### Step 4.4 — Page-turn audio + haptic
- [x] **Play the flip sound + light haptic on each completed turn.**
- **Goal:** Tactile feedback (signature feel).
- **Files:** modify `book_curl_view.dart`/`reader_provider.dart` to call `AudioService` + `HapticFeedback`.
- **Packages:** uses `audioplayers` (via `AudioService`), built-in `HapticFeedback`.
- **Implementation details:** On `onPageChanged` (a **completed** turn, not every drag frame), call `AudioService.playPageTurn(enabled: settings.soundEnabled, volume: settings.soundVolume)` and `HapticFeedback.lightImpact()` if `settings.hapticsEnabled`. Debounce so rapid turns don't stack sounds.
- **Done when:** `flutter analyze` clean; each completed turn plays a subtle sound + light haptic; disabling either in settings silences/stops it.

### Step 4.5 — Overlay UI (top + bottom bars, toggle + auto-hide)
- [x] **Build the toggled reader overlay.**
- **Goal:** Reading controls that stay out of the way.
- **Files:** create `lib/features/reader/widgets/reader_overlay.dart`; modify `reader_screen.dart`.
- **Packages:** none new.
- **Implementation details:** Center-third tap toggles `isOverlayVisible`; auto-hide after `AppDurations.overlayAutoHide` of inactivity; animate in/out (fade/slide). **Top bar:** back, book title (Lora, ellipsis), bookmark toggle (Step 4.8), overflow → reader settings (tint/brightness/sound shortcuts or push Settings). **Bottom bar:** page scrubber (Step 4.6), prev/next, brightness slider (Step 4.10), Day/Night/Sepia toggle (Step 4.9), sound on/off. Bars use theme tokens with a translucent scrim.
- **Done when:** `flutter analyze` clean; center tap shows/hides bars; bars auto-hide; all controls are visible and themed (wiring lands in subsequent steps).

### Step 4.6 — Page scrubber + Go-To with thumbnail preview
- [x] **Add a slider that jumps pages, with a live thumbnail preview.**
- **Goal:** Fast navigation across long PDFs.
- **Files:** create `lib/features/reader/widgets/page_scrubber.dart`; modify `reader_overlay.dart`.
- **Packages:** none new.
- **Implementation details:** `Slider` from 1..totalPages showing "current / total". While dragging, show a small thumbnail preview (render that page at low res via `PdfService`, cached/throttled) above the thumb. On release, `BookCurlView.controller.jumpTo(index)` (no per-page curl animation for big jumps). Debounce thumbnail renders.
- **Done when:** `flutter analyze` clean; dragging shows a live thumbnail; releasing jumps to that page; smooth on a 500-page PDF.

### Step 4.7 — Resume reading (debounced save + restore)
- [x] **Persist last-read page and restore on reopen.**
- **Goal:** Never lose the reader's place.
- **Files:** modify `reader_provider.dart`, `library_service.dart`.
- **Packages:** none new.
- **Implementation details:** On each completed turn and on dispose/app-pause (`WidgetsBindingObserver.didChangeAppLifecycleState`), debounce (`AppDurations.resumeSaveDebounce`) then `LibraryService.updateProgress(book.id, currentPage)` → updates `lastReadPage`, `progress`, `lastOpened` in Hive and notifies `LibraryProvider`. On reader open, start at `book.lastReadPage`.
- **Done when:** `flutter analyze` clean; close mid-book and reopen → resumes at the saved page; Home "Continue Reading" + card progress reflect it.

### Step 4.8 — Bookmarks
- [x] **Toggle bookmarks on pages; list + jump.**
- **Goal:** Mark and return to pages.
- **Files:** modify `reader_overlay.dart`; create `lib/features/reader/widgets/bookmarks_sheet.dart`; modify `storage_service.dart`/`reader_provider.dart`.
- **Packages:** none new.
- **Implementation details:** Top-bar bookmark icon toggles a `BookmarkModel` for the current page (filled when present). A "bookmarks" action opens a sheet listing this book's bookmarks (page number + optional note + small thumbnail); tap jumps via `controller.jumpTo`. Persist via `StorageService` bookmarks box keyed `'{bookId}:{pageIndex}'`.
- **Done when:** `flutter analyze` clean; toggling adds/removes a bookmark (persists across restart); the sheet lists them and jumping works.

### Step 4.9 — Day / Night / Sepia page tint
- [x] **Apply a paper/sepia/night tint over rendered pages.**
- **Goal:** Reading comfort without re-rendering PDFs.
- **Files:** modify `book_curl_view.dart`/`reader_screen.dart`, `reader_provider.dart`, `reader_overlay.dart`.
- **Packages:** none new.
- **Implementation details:** `ReaderProvider.pageTint` (init from `settings.pageTint`). Apply the tint as a single overlay over the whole `BookCurlView` (cheaper and simpler than per-page, and the flipbook paints page images itself): wrap it in a `ColorFiltered`/`IgnorePointer` overlay — **paper** = warm `#F4ECD8` low-opacity multiply; **sepia** = stronger warm `BlendMode.multiply` wash; **night** = darken toward `#141210` with reduced blue (dark `BlendMode.multiply` + optional `ColorFilter.matrix` slight invert for light pages). Also set the flipbook's `paperColor` to match the tint so page edges/back match. Toggle in the bottom bar; reader-local override of the default tint.
- **Done when:** `flutter analyze` clean; cycling tint visibly changes page warmth/darkness; night is comfortably dim and low-blue; choice persists per session (default from settings).

### Step 4.10 — In-reader brightness + keep awake
- [x] **Add a brightness slider and keep the screen on while reading.**
- **Goal:** Comfortable, uninterrupted reading.
- **Files:** modify `reader_overlay.dart`, `reader_screen.dart`.
- **Packages:** uses `screen_brightness`, `wakelock_plus`.
- **Implementation details:** Bottom-bar brightness `Slider` sets app brightness via `ScreenBrightness().setApplicationScreenBrightness(value)`; reset on reader dispose (app-scoped auto-reset). On reader open, if `settings.keepScreenOn`, `WakelockPlus.enable()`; disable on dispose.
- **Done when:** `flutter analyze` clean; dragging the slider dims/brightens the screen; screen stays awake while reading and brightness resets after leaving the reader.

---

## Phase 5 — Settings

### Step 5.1 — Settings screen
- [x] **Build the settings screen wired to `SettingsProvider`.**
- **Goal:** Central control of app preferences.
- **Files:** create `lib/features/settings/settings_screen.dart`; modify `app_router.dart` (add `/settings`), `home_screen.dart` overflow.
- **Packages:** none new.
- **Implementation details:** Sections: **Theme** (System / Day / Night — segmented), **Page-turn sound** (switch + volume slider, disabled when off), **Haptics** (switch), **Default page tint** (paper / sepia / night), **Keep screen on** (switch), **Rescan device for PDFs** (triggers `LibraryProvider.scanDevice` with the permission flow), **About** (app name, version from `PackageInfo`/hardcoded, short blurb, licenses via `showLicensePage`). Every control reads/writes `SettingsProvider` (persisted). Themed with tokens only.
- **Done when:** `flutter analyze` clean; changing theme updates the app instantly; sound/haptics/tint toggles affect the reader; "Rescan" runs discovery; settings persist across restarts.
- **Done (actual) — 2026-06-24:** Replaced the placeholder with the full screen. The `/settings` route and Home-overflow "Settings" item **already existed** (Phase 1 scaffolding) — no router/Home change needed. Uses `SegmentedButton` for Theme + Default page tint, `SwitchListTile` for sound/haptics/keep-awake, a dimmed (no-op) Volume `Slider` when sound is off, an Android-only "Rescan device for PDFs" tile reusing the rationale→request→`scanDevice` flow from Home, and an About section. **Version is hardcoded `1.0.0`** (mirrors `pubspec.yaml`) via `showLicensePage` — no `package_info_plus` dependency added (no-extra-deps guardrail). `flutter analyze` clean. **Verified on emulator-5554** (hot reload): all sections render in Night theme; tapping **Day** flips the whole app to the cream theme **instantly** (the headline criterion); Night restored; **Open-source licenses** opens `showLicensePage` titled "Comfy Reader v1.0.0". Full progress history in [PROGRESS_LOG.md](PROGRESS_LOG.md).

---

## Phase 6 — Polish

### Step 6.1 — Transitions
- [x] **Hero cover→reader + refined route transitions.** _(2026-06-24: shared-axis for `/settings`; cover Hero into reader with a cover-image flight shuttle; verified on emulator, no Hero conflicts. See [PROGRESS_LOG.md](PROGRESS_LOG.md).)_
- **Goal:** Cohesive premium motion.
- **Files:** modify `app_router.dart`, `book_card.dart`, `reader_screen.dart`.
- **Packages:** none new.
- **Implementation details:** Hero-animate the tapped cover (`Hero(tag: book.id)`) into the reader's first visible page/frame. Use shared-axis/fade `CustomTransitionPage` for splash→home and home↔settings. 250–400ms ease-in-out (`AppDurations`).
- **Done when:** `flutter analyze` clean; tapping a cover smoothly expands into the reader; route transitions feel intentional, no abrupt cuts.

### Step 6.2 — Micro-animations
- [x] **Staggered grid entrance, shimmer, splash refinement, button feedback.** _(2026-06-24: grid stagger/shimmer/splash already in place; added reusable `Pressable` tap-scale to cards + reduced-motion guards. Analyze-clean; device pass deferred — emulator busy with another project.)_
- **Goal:** The "polished and intentional" feel.
- **Files:** modify `library_grid.dart`, `book_card.dart`, `splash_screen.dart`, shared widgets.
- **Packages:** uses `flutter_animate`.
- **Implementation details:** Staggered fade/slide-in of grid items (`flutter_animate` with per-index delay); shimmer on loading covers/pages; subtle scale/opacity on card tap; refine splash easing/timings. Respect reduced-motion.
- **Done when:** `flutter analyze` clean; grid items cascade in; loading states shimmer; nothing janks.

### Step 6.3 — Error / empty / loading states pass
- [x] **Audit every async surface for graceful states.** _(2026-06-24: added `PdfService.probe` + reader load-status → friendly missing/protected/corrupt error screen with Back; import/scan/permission/empty already graceful; per-page failure = blank-page fallback (engine). Analyze + unit test pass; protected/corrupt render to confirm on-device. See [PROGRESS_LOG.md](PROGRESS_LOG.md).)_
- **Goal:** No dead ends or silent failures.
- **Files:** across `features/*` and `services/*`.
- **Packages:** none new.
- **Implementation details:** Per-page render errors show a retry; corrupt/locked PDF on open shows a friendly error + back; import failure → snackbar; scan with no results → gentle note; permission denied → clear path to import + retry. Password-protected PDFs are **out of scope** — detect and show "Can't open protected PDF" (park in Future).
- **Done when:** `flutter analyze` clean; manually feeding a corrupt PDF, a denied permission, and a cancelled import each yield a clear, recoverable state.

### Step 6.4 — Performance pass on a large PDF
- [~] **Profile and tune on a 500+ page PDF.** _(2026-06-24: code/tests done — added `Semaphore(3)` cover-render throttle, documented LRU cache math in main.dart, confirmed DPR-aware target width + native off-isolate render. **Remaining: empirical `--profile` run on a real device** (60fps/memory graph) — emulator busy & unrepresentative. See [PROGRESS_LOG.md](PROGRESS_LOG.md).)_
- **Goal:** Meet the performance contract.
- **Files:** tune `page_image_cache.dart`, `pdf_service.dart`, `book_curl_view.dart`.
- **Packages:** none new.
- **Implementation details:** Run a profile build; check the curl stays ~60fps, memory is bounded (LRU evicts), no main-thread jank during render (move rendering off the UI isolate via `compute` if needed). Tune cache caps (count/bytes) and render target width per device DPR. Confirm cover generation never blocks scrolling.
- **Done when:** `flutter run --profile` on a 500+ page PDF: smooth curl, stable bounded memory, fast page loads; record final cache settings in code comments.

### Step 6.5 — Accessibility
- [x] **Semantics, contrast, text scaling, tap targets.** _(2026-06-24: tooltips on all icon buttons, button-role semantics on cards via `Pressable`, brightness slider label; contrast computed — body/reading text 10–13.5 (≫AA), accent passes 3:1; reduced-motion honored. Text-scale 1.3× to spot-check on device. See [PROGRESS_LOG.md](PROGRESS_LOG.md).)_
- **Goal:** Usable and inclusive.
- **Files:** across UI.
- **Packages:** none new.
- **Implementation details:** Add `Semantics`/`tooltip` to icon buttons; ensure ≥48px tap targets; verify Day/Night contrast meets WCAG AA for text; support OS text-scale without breaking layouts (test 1.3×); honor reduced-motion in animations.
- **Done when:** `flutter analyze` clean; screen-reader announces controls; layouts hold at large text scale; contrast checks pass.

### Step 6.6 — iOS pass
- [~] **Verify iOS sandbox import, picker, splash, orientation.** _(2026-06-24: code-audited — iOS-conditional paths (no scan, auto-grant), import copy, and Info.plist flags all correct. **Found gap:** Files "open-in-place" launches but doesn't import (no incoming-URL handler in AppDelegate; needs a scoped follow-up). Runtime sim build + manual checklist deferred to a Mac/Xcode session. See [PROGRESS_LOG.md](PROGRESS_LOG.md).)_
- **Goal:** Cross-platform correctness.
- **Files:** verify `Info.plist`, splash assets, import flow.
- **Packages:** none new.
- **Implementation details:** On a real iOS device/simulator: confirm no device-scan attempted; UIDocumentPicker import copies the PDF into Documents and persists; "open with Comfy Reader" from Files works (`UIFileSharingEnabled`/`LSSupportsOpeningDocumentsInPlace`); native splash shows no white flash; portrait lock holds; audio/haptics/brightness/wakelock behave.
- **Done when:** `flutter analyze` clean; full happy path (add → library → read → resume → bookmark) works on iOS.

---

## Phase 7 — Release prep

### Step 7.1 — Final icon + splash assets
- [~] **Drop in final brand art and regenerate.** _(2026-06-24: real brand logo added + launcher icons regenerated (periwinkle book+moon); **splash_logo still placeholder → mismatch**, needs a transparent-bg mark then `flutter_native_splash:create`. See [PROGRESS_LOG.md](PROGRESS_LOG.md).)_
- **Goal:** Production-quality icon + splash.
- **Files:** replace `assets/images/app_icon*.png`, `assets/images/splash_logo*.png`; rerun generators.
- **Packages:** uses `flutter_launcher_icons`, `flutter_native_splash`.
- **Implementation details:** Replace placeholder art with final 1024² icon + adaptive foreground and splash logo (light/dark). Rerun `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`.
- **Done when:** Final icon + splash appear on both platforms; no white flash; `flutter analyze` clean.

### Step 7.2 — Build instructions
- [x] **Document debug/release builds for both platforms.** _(2026-06-24: rewrote README — setup, debug/release for Android + iOS, MANAGE_EXTERNAL_STORAGE Play note + import-only fallback, debug-signing placeholder. See [PROGRESS_LOG.md](PROGRESS_LOG.md).)_
- **Goal:** Repeatable builds.
- **Files:** update `README.md`.
- **Packages:** none.
- **Implementation details:** Document `flutter run`, `flutter build apk --release` / `flutter build appbundle`, `flutter build ios`. Note the **`MANAGE_EXTERNAL_STORAGE` Google Play sensitive-permission declaration** requirement and the import-only fallback if a developer prefers not to ship it. Note debug signing is currently used for release (placeholder) and where to add a real keystore.
- **Done when:** Following the README from clean produces installable Android + iOS builds.

### Step 7.3 — Permission rationale copy + pre-request dialog
- [x] **Show a short rationale before requesting storage access.** _(2026-06-24: extracted shared `PermissionRationaleDialog` + `StoragePermissionFlow` (adds permanently-denied "Open settings"); wired into Home + Settings, removed the duplicated inline dialogs. Analyze clean. See [PROGRESS_LOG.md](PROGRESS_LOG.md).)_
- **Goal:** Higher grant rate + transparency (cross-platform correctness).
- **Files:** modify `permission_service.dart`; create `lib/shared/widgets/permission_rationale_dialog.dart`; wire into Home discovery + Settings rescan.
- **Packages:** none new.
- **Implementation details:** Before any Android storage request, show a themed dialog: *"Comfy Reader scans your Downloads, Documents, and Books folders to find PDFs. We never upload or share your files — everything stays on your device."* with **Continue** / **Not now**. Only on Continue call `ensureStorageAccess()`. If permanently denied, offer **Open settings** (`openAppSettings`).
- **Done when:** `flutter analyze` clean; the rationale shows before the OS prompt; declining keeps the app fully usable via import.

### Step 7.4 — Manual QA checklist
- [~] **Run the end-to-end QA checklist on Android + iOS.** _(2026-06-24: checklist authored in [QA.md](QA.md) covering all phases incl. Phase-6 surfaces; **running it on devices is pending** an Android emulator + an iOS build. See [PROGRESS_LOG.md](PROGRESS_LOG.md).)_
- **Goal:** Ship confidence.
- **Files:** add a QA checklist to `README.md` (or `QA.md`).
- **Packages:** none.
- **Implementation details:** Checklist: cold launch (native→animated splash→home, no flash); import PDF (cover + persist); Android device scan (grant/deny paths); grid/list toggle; search + 3 sorts; open reader (immersive); page-curl swipe + tap zones; sound + haptic on turn (and toggles off); scrubber + Go-To thumbnail; resume after kill; bookmark add/list/jump; Day/Night/Sepia tint; brightness + wakelock; settings persist; theme switch; empty state; corrupt/locked PDF error; large (500+ page) PDF smoothness; iOS open-in-place. Note pass/fail per item.
- **Done when:** All checklist items pass on at least one Android and one iOS target; failures filed/fixed.

---

## Future / Optional (out of scope for v1)

Deliberately excluded — park here, do not build in v1:

- **Other formats:** EPUB, MOBI, DJVU, **CBZ/CBR comics**, office formats, EPUB3 multimedia.
- **Reading aids:** TTS / read-aloud, dictionary lookup, online translation, PDF text reflow, white-space cropping, page splitting, reading-direction options, locked-page settings.
- **Annotation/markup:** drawing, highlights, notes export.
- **Connectivity/accounts:** cloud sync, accounts, Calibre/OPDS online catalogs, opening books inside zips/emails, desktop widgets.
- **PDF specifics:** password-protected PDFs (detected + politely declined in v1), per-PDF metadata editing.
- **Reader layout:** **landscape two-page spread** — the vendored `RealisticFlipbook` already supports it (auto-engages in landscape; `singlePage`/`singlePageSpreadNavigation` flags), so this is a near-free stretch but stays out of the v1 acceptance bar. Also: adjustable cover size, favorites (beyond Continue Reading), library folders/tag organization.
- **Sharing:** zero-config share of a book file (only if it later proves trivial; otherwise omit).
- **Curl fidelity / mixed page sizes:** the flipbook assumes a uniform page size (measures page 1). Per-page aspect handling, in-reader pinch-zoom on a page, and a shader-based curl are future refinements; v1 uses the vendored engine as-is.

> Anything requested beyond Section 3's ten features routes here first and is scoped separately.
