# Shared Project Conventions — Comfy Reader (load before any investigation or change)

> Single source of truth for the agents, skills, and commands in this repo.
> Comfy Reader has **no `.cursorrules` and no `CLAUDE.md`** — the human-facing
> references are [README.md](../README.md), [plan.md](../plan.md),
> [QA.md](../QA.md), [PROGRESS_LOG.md](../PROGRESS_LOG.md), and lint config
> [analysis_options.yaml](../analysis_options.yaml). When this file disagrees with
> the live code, **the code wins** — read it, then fix this file.

## 0. What this app is

Comfy Reader is a **cozy PDF reader** for Android (primary) and iOS, built on one
Flutter codebase. Its signature features: a vendored **3D page-curl** engine, an
auto-discovering **library** with rendered covers, **resume/bookmarks**, Day/Sepia/
Night **comfort tints**, and offline **read-aloud (TTS)** with OCR fallback for
scanned PDFs. It is **Flutter-first** — there is **no native app to mirror**, so
"native is the source of truth" does NOT apply here. Android and iOS differ only
where the platform forces it (see §7).

## 1. Non-negotiable rules

1. **Confirm root cause before writing code.** Investigation agents are read-only;
   no fix is proposed until the cause is confirmed with `file:line` evidence.
2. **No hardcoded values.** Colors → `AppColors`; text styles → `AppTypography`;
   spacing/radii/shadows → `Dimens`; asset paths → `asset_paths.dart`; durations →
   `AppDurations` ([lib/core/constants/durations.dart](../lib/core/constants/durations.dart)).
   Sizes that must scale use `flutter_screenutil` (`.w/.h/.sp/.r`, `designSize: 375×812`).
   There is **no `AppStrings` file and no l10n (.arb)** — UI text is inline English
   literals today; keep new copy consistent with the surrounding screen, don't invent
   a strings layer unless asked.
3. **Persistence is split and must round-trip.** Books + bookmarks live in **Hive**
   (`StorageService`, two `Box<Map>`); settings live in **SharedPreferences** as one
   JSON key (`SettingsService` → `AppSettings`). Models are **map-based, no codegen**.
4. **Model change checklist.** Adding/changing a field on `BookModel` / `BookmarkModel`
   / `AppSettings` updates **constructor + `copyWith` + `toMap` + `fromMap`** (and
   `==`/`hashCode` where the model defines them — `AppSettings` does, including
   `mapEquals` for `voiceByLanguage`). Missing one is a latent persistence bug.
5. **State is Provider + ChangeNotifier** (no BLoC, no Riverpod, no codegen). Mutate
   through the provider's own methods, then `notifyListeners()`. `SettingsProvider`
   persists on every `_update`. Don't read a provider after the widget is unmounted;
   guard post-`await` `context` use with `context.mounted`.
6. **State sync across providers** (§6). A page-progress change in `ReaderProvider`
   must propagate to `LibraryProvider` so the library's "Continue Reading"/recents
   reflect it. `ReadAloudController` always reads `ReaderProvider.currentPage`.
7. **`build()` stays small** — no business logic or method definitions inside `build`;
   handlers are named methods passed by reference.
8. **Controllers & timers** are fields, created in `initState` (or the provider ctor),
   and **disposed** in `dispose` (e.g. `ReaderProvider`'s `_overlayTimer` /
   `_saveDebounce`, `FlipbookController`, `TextEditingController`s). Leaks here cause
   the most insidious reader bugs.
9. **Minimize change, avoid regressions, preserve the existing architecture.** Don't
   introduce a new state-management/DI/persistence pattern. Reuse the existing service
   + provider + widget layers.
10. **Resources are short-lived and throttled.** PDF documents are opened → rendered →
    `close()`d in a `finally`. Cover rendering is throttled through `Semaphore(3)`. The
    global image cache is capped (14 pages / ~220 MB, LRU). Respect these — don't open a
    doc you don't close, don't bypass the throttle.

## 2. Architecture facts (verified against the code)

- **State:** `provider` ^6.1 + `ChangeNotifier`. App-wide providers wired in
  [lib/app.dart](../lib/app.dart) via `MultiProvider`: `SettingsProvider`,
  `LibraryProvider`. Per-reader-session controllers created in
  [reader_screen.dart](../lib/features/reader/reader_screen.dart): `ReaderProvider`,
  `ReadAloudController`, and the flipbook's `FlipbookController`.
- **Persistence:** Hive (`hive_ce`) via
  [storage_service.dart](../lib/services/storage_service.dart) — books box keyed by
  `book.id` (`sha1(filePath+fileSize)`), bookmarks box keyed by `"<bookId>:<pageIndex>"`;
  SharedPreferences via [settings_service.dart](../lib/services/settings_service.dart)
  (single `app_settings` JSON). Paths from
  [app_paths.dart](../lib/core/utils/app_paths.dart) (support/documents/books/covers).
- **Models** ([lib/models/](../lib/models/)): `BookModel`, `BookmarkModel`,
  `AppSettings`, and enums (`PageTint`, `LibraryView`, `SortMode`, `AppThemeMode`).
- **Design system** ([lib/core/theme/](../lib/core/theme/)): `AppColors` (day/night +
  paper/sepia/night reading tints), `AppTypography` (Fraunces/Lora/Inter variable
  fonts, weights via `FontVariation('wght', n)`, `textTheme(color)`/`soft()`),
  `AppTheme` (M3 light/dark + `ComfyColors` theme extension), `Dimens` (8px spacing
  scale, radii incl. pill 999, book aspect 3/4, `softShadow`).
- **Routing:** `go_router` ^17 in
  [app_router.dart](../lib/core/router/app_router.dart). Routes: `/splash`, `/home`
  (`HomeShell` bottom-nav: Library · Continue Reading · Settings), `/reader/:bookId`,
  `/voices`. Soft-fade transitions; navigate via `context.go` / `context.push`.
- **Entry/init** ([lib/main.dart](../lib/main.dart)): error sink → `AppLog`; image
  cache 14 / 220 MB; portrait lock; `pdfrxFlutterInitialize()`; then
  `AppPaths.init → StorageService.init → AudioService.init → TtsService.init` → `runApp`.

## 3. The two intricate subsystems (each owns a skill + an agent)

### 3a. Rendering — the page-curl + PDF pipeline (the #1 hotspot)
- [lib/flip_book/flip_book.dart](../lib/flip_book/flip_book.dart) (~3.5k LOC) — the
  vendored `RealisticFlipbook` 3D page-curl: perspective math, drag→progress gesture
  state machine, **widget-snapshot capture** before animation, zoom (1/2/4 + panning),
  single vs spread layout, and a **stuck-flip watchdog** that auto-recovers.
- [book_curl_view.dart](../lib/features/reader/widgets/book_curl_view.dart) wraps
  `FlipbookController`, feeds pages, and on flip calls `ReaderProvider.onPageChanged` +
  `AudioService.playPageTurn`.
- [pdf_page_image_provider.dart](../lib/features/reader/pdf_page_image_provider.dart) —
  lazy `ImageProvider` with `PdfPageKey` (bookId, pageIndex, targetWidth) cache key.
- [pdf_service.dart](../lib/services/pdf_service.dart) — **`pdfx` renders**, **`pdfrx`
  extracts text** (it has no render-for-display use); `probe()` classifies
  ok/missing/protected/corrupt; `firstPageSize()` feeds the flipbook size hint.
- Comfort tints (paper/sepia/night) applied via `ColorFiltered` in the reader.
- Canonical rules + failure modes: **`rendering-rules` skill**; deep diagnosis:
  **`rendering-investigator` agent**.

### 3b. Read-aloud — the TTS/OCR/text pipeline (the highest-stakes correctness domain)
- [read_aloud_controller.dart](../lib/providers/read_aloud_controller.dart) — orchestrates
  extract → (OCR fallback) → detect language → chunk → speak; **always reads
  `ReaderProvider.currentPage`**; auto-advances via `curl.next()`; states idle/loading/
  playing/paused/finished/unavailable; `_extractToken` guards against stale async results;
  `_consecutiveEmpty` (≈8) decides a book is unreadable.
- [tts_service.dart](../lib/services/tts_service.dart) — `flutter_tts` wrapper; Android
  prefers the Google engine; voice enumeration is cached + quality-scored (offline voices
  get a large bonus); `applyLanguage`, `speak/pause/stop/setRate`, `onComplete/onError`.
- [ocr_service.dart](../lib/services/ocr_service.dart) — ML Kit Latin + Devanagari, runs
  both and keeps the longer result; session FIFO cache; fallback only when the text layer
  is empty (scanned pages).
- [language_detector.dart](../lib/core/utils/language_detector.dart) — offline
  Unicode-block script detection → BCP-47 locale; Devanagari Hindi/Marathi ambiguity is
  user-resolved.
- [tts_platform.dart](../lib/services/tts_platform.dart) — `MethodChannel('comfy_reader/tts')`;
  Android `installTtsData`/`openTtsSettings`; iOS returns false (no public API).
- Text chunking: split on `(?<=[.!?])\s+`, hard-split runs > 3500 chars.
- Canonical rules: **`read-aloud-pipeline` skill**; deep audit: **`read-aloud-auditor` agent**.

## 4. High-risk files (handle with extra care + tests)

| File | Why |
|---|---|
| [flip_book/flip_book.dart](../lib/flip_book/flip_book.dart) (~3.5k LOC) | perspective math, gesture/animation state machine, widget-snapshot lifecycle, stuck-flip watchdog — the most fragile area |
| [providers/read_aloud_controller.dart](../lib/providers/read_aloud_controller.dart) | `_extractToken` races, empty-page counter, OCR latency blocking page turns, auto-advance re-entrancy |
| [features/reader/pdf_page_image_provider.dart](../lib/features/reader/pdf_page_image_provider.dart) | memory pressure on big books, cache-key equality, silent decode failures |
| [services/pdf_service.dart](../lib/services/pdf_service.dart) | dual-library coordination, probe error classification, file-handle leaks (must `close()` in `finally`) |
| [services/library_service.dart](../lib/services/library_service.dart) | device-scan recursion, cover throttle, file copy/delete, permission races |
| [providers/library_provider.dart](../lib/providers/library_provider.dart) | list upsert/dedup by id, filter/sort, notify discipline |
| [services/tts_service.dart](../lib/services/tts_service.dart) | voice-list caching/invalidation, quality scoring, language/voice application |
| [core/utils/language_detector.dart](../lib/core/utils/language_detector.dart) | Unicode block ranges, mixed-script fall-through |
| [features/reader/reader_screen.dart](../lib/features/reader/reader_screen.dart) | orchestrates the per-session providers + curl + overlay lifecycle |

## 5. Commands every change should pass

```bash
flutter analyze     # must be clean (lints from analysis_options.yaml)
flutter test        # must be green (test/: language_detector, overflow, widget)
```

Run loop (debug), per [README.md](../README.md):
```bash
flutter run -d <device>                          # or emulator-5554 / an iOS sim id
flutter run -d emulator-5554 --pid-file=/tmp/cr.pid
kill -USR1 $(cat /tmp/cr.pid)   # hot reload  (~4s)
kill -USR2 $(cat /tmp/cr.pid)   # hot restart (~10s)
```
> On an x86 Android emulator the first cold frame (~55–100s) and first PDF render are
> JIT/software-render artifacts, **not** app bugs — profile on a real device.

## 6. State-sync rules (Provider / ChangeNotifier)

The app's most common non-rendering bug class is **stale state across providers that
share data**. Full map: **`state-sync-map` skill**; live tracing: **`state-sync-tracer` agent**.

- **`ReaderProvider` → `LibraryProvider` propagation.** `ReaderProvider` holds a
  `LibraryProvider` reference; `onPageChanged`/`saveNow`/`markOpened` must call
  `library.updateProgress(...)` so the library's `inProgress`/`recents` reflect the
  current page. The final save on `dispose` is **unawaited** — a known smell; if the
  library list looks stale after leaving the reader, suspect this path first.
- **`ReadAloudController` ↔ `ReaderProvider`.** The controller listens to the reader and
  always speaks `currentPage`; auto-advance calls `curl.next()`, which turns the page,
  updates the reader, and **re-enters** the controller's listener. Watch for re-entrancy
  and for `_extractToken` invalidation when the page changes mid-extraction.
- **`SettingsProvider`.** Every mutation routes through `_update(next)` which persists via
  `SettingsService.save()` then `notifyListeners()`. Don't mutate `AppSettings` outside it.
- **Notify discipline.** One mutation → one coherent `notifyListeners()`. Don't notify from
  inside `build`; don't forget to notify after an async write completes.

## 7. Platform behavior (Android vs iOS — Flutter-first, no native parity)

Differences are forced by the platform, not by a native app. Full matrix +
verification: **`platform-parity-investigator` agent** / **`platform-check` command**.

| Capability | Android | iOS |
|---|---|---|
| Device PDF scan | ✅ `LibraryService.scanDevice()` over Download(s)/Documents/Books | ❌ sandboxed — picker import only |
| Storage permission | `MANAGE_EXTERNAL_STORAGE` (broad; triggers Play sensitive-permission declaration) | none needed |
| TTS engine | Google TTS, configurable | system engine, fixed |
| Voice-data install | `TtsPlatform.installTtsData()` intent | manual (UI guides the user) |
| PDF import | any path | must copy into app Documents (`UIFileSharingEnabled`) |
| OCR | ML Kit (Play Services) | ML Kit bundled, requires **iOS 15.5+** |

Never assert "works on both platforms" without checking the platform-split code
(`PermissionService`, `LibraryService`, `TtsService`, `TtsPlatform`, `OcrService`).
