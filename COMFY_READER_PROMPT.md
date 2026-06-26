# Comfy Reader — Master Prompt (for generating `plan.md`)

> **How to use this file (read me first — this part is for you, the human):**
> 1. Open Claude Code in this Flutter project (`comfy_reader`).
> 2. Copy **everything below the line `=== PASTE FROM HERE ===`** and send it as your message.
> 3. Claude Code will produce a single file: **`plan.md`** — a phased, checkbox-driven build plan. It will NOT write app code yet.
> 4. Review `plan.md`, then execute it step by step. For each step, tell Claude Code: *"Do step X.Y from plan.md"*, review, and check it off.
> 5. If you ever feel it's drifting, paste: *"Re-read plan.md and the Guardrails. Stay in scope."*

---

=== PASTE FROM HERE ===

You are an expert Flutter/Dart mobile engineer and product designer. Your task in **this** message is **only** to produce a single, comprehensive, execution-ready file named **`plan.md`** in the project root. **Do NOT write any app source code, do NOT modify `pubspec.yaml`, do NOT create screens yet.** Output the plan only.

Before writing the plan, inspect the current repository state yourself (read `pubspec.yaml`, `lib/`, `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`) and confirm the facts in the "Project Facts" section below are still accurate. Where you recommend packages, verify the package exists on pub.dev and is compatible with the SDK/Flutter version, and prefer adding them via `flutter pub add <pkg>` (let the resolver pick versions) rather than hardcoding version numbers.

---

## 1. Product Vision

**App name:** Comfy Reader
**One-liner:** A premium, cozy PDF reader where documents open and behave like a real physical book — pages curl and turn like Kindle, complete with a tactile page-turning sound.
**Platforms:** Android (primary) and iOS. Flutter, single codebase.
**Feeling to deliver:** warm, calm, tactile, premium, "reading in a sunlit nook." Every interaction should feel polished and intentional.

This is a **focused PDF reader**, not a do-everything app. The Librera Reader feature list (below, in "Inspiration") is *mood/feature inspiration only* — we are building a tightly scoped subset. **Do not implement EPUB/MOBI/DJVU/CBZ, TTS/read-aloud, dictionaries, translation, online catalogs, drawing/annotation, or cloud sync** unless explicitly listed under "Future / Optional (out of scope for v1)."

---

## 2. Project Facts (current state of this repo — verify before planning)

- Existing Flutter scaffold. Flutter **3.41.4 stable**, Dart SDK constraint `^3.11.1`.
- Package/module name: `comfy_reader`. Android `applicationId` and `namespace`: `com.example.comfy_reader`.
- Android uses **Kotlin Gradle DSL** (`build.gradle.kts`), `minSdk`/`targetSdk`/`compileSdk` inherit Flutter defaults.
- `lib/` currently contains only `main.dart` (default counter app — to be replaced).
- No `assets/` directory yet. No permissions declared in `AndroidManifest.xml`. App label is still `comfy_reader`. Default launcher icon.
- iOS scaffold present (`ios/Runner/Info.plist`, `AppDelegate.swift`).

The plan must account for renaming the display label to **"Comfy Reader"**, adding assets, adding permissions, and replacing the default `main.dart`.

---

## 3. Core Features (v1 scope — build exactly these)

1. **Book-like PDF reading with page-curl turning.** Pages render as a real page and turn with a Kindle-style curl/fold animation on swipe and tap. This is the headline feature — it must look and feel premium and realistic, with a curl shadow/gradient.
2. **Page-turning audio.** A subtle, satisfying page-flip sound plays on each completed turn (toggleable; respects a volume setting; paired with a light haptic).
3. **Trendy animated splash screen.** A native splash (no white flash) followed by a custom animated in-app splash that reflects the cozy/premium brand, then transitions smoothly into Home. Use creativity (see Design System for direction).
4. **Home / Library screen.** A grid (default) and list view of available PDFs. Each item shows a **cover image = the rendered first page of the PDF**, with the **PDF name below it**. Tapping the cover **or** the name opens the reader.
5. **Auto-discovery of PDFs from device storage.** On first launch and on pull-to-refresh, with permission, scan the device for PDF files and populate the library (Android). Degrade gracefully where the OS restricts broad access; on iOS rely on imported files (sandbox).
6. **Manual add via Floating Action Button.** A FAB on Home opens the system file picker (PDF only). Selected PDFs are imported into the app's library, a cover is generated, and they persist across launches.
7. **Resume reading.** Remember the last-read page per book; show progress; resume on reopen. A "Continue Reading" section surfaces the most recent book(s).
8. **Bookmarks + Go To.** Bookmark pages; a page scrubber with a "Go To" page lets the reader jump quickly.
9. **Day / Night / Sepia reading + brightness.** Light/dark app themes and a paper/sepia/night tint over rendered pages; in-reader brightness control; keep-screen-awake while reading.
10. **Lightweight settings.** Theme mode, page-turn sound on/off + volume, haptics on/off, default page tint, keep screen on, rescan device, about.

---

## 4. Recommended Technical Approach (the planner should adopt or improve, with justification)

**Page-curl on PDF content (the crux).** PDFs are not images, so:
- Rasterize each PDF page to an image using **`pdfx`** (mature page-to-image API; also used for cover thumbnails and page count). Note `pdfrx` as a viable modern alternative if `pdfx` hits issues.
- Drive the turn animation with a page-curl widget: recommend **`page_flip`** for the most book-like curl. If large-PDF performance or lazy building is a problem, evaluate **`turn_page_view`** (builder-based, lazy) as an alternative. The plan must pick one as primary and name the fallback.
- **Performance is mandatory:** render lazily (only the current page ±2), cache rendered page images in memory with an LRU-style cap and evict far pages, and show a per-page loading state. The app must stay smooth on a 500+ page PDF. If the chosen curl package needs an eager children list, wrap it so pages are still produced lazily/cached.
- Optionally note a "stretch" path: a custom `CustomPainter`/shader page curl for maximum fidelity — but the package approach is the v1 plan.

**Suggested package set (verify + `flutter pub add`; swap with justification if better exists):**
- PDF rendering / page images / page count / metadata: `pdfx` (fallback `pdfrx`).
- Page-curl animation: `page_flip` (fallback `turn_page_view`).
- File picking (PDF): `file_picker`.
- Storage permissions: `permission_handler`.
- Filesystem paths / app dirs: `path_provider`.
- Page-turn sound (low-latency): `audioplayers` (preload, `PlayerMode.lowLatency`).
- Native splash (no white flash): `flutter_native_splash`.
- Animated splash / micro-animations: `lottie` and/or `flutter_animate`.
- Typography: `google_fonts` — **but bundle the chosen fonts as local assets** for offline reliability instead of runtime fetching.
- Persistence (library, recents, bookmarks): `hive_ce` (maintained Hive fork) **or** a JSON file via `path_provider`; settings via `shared_preferences`. Planner picks one and is consistent.
- State management: **`provider`** (simple, robust, good for step-by-step execution). `flutter_riverpod` is an acceptable alternative if justified — pick one, do not mix.
- Routing: `go_router` (splash → home → reader) or plain `Navigator` with custom transitions. Pick one.
- In-reader brightness: `screen_brightness`. Keep awake: `wakelock_plus`. Haptics: built-in `HapticFeedback`. Hashing for cache keys: `crypto`. App icon: `flutter_launcher_icons`.
- Modern icon set: Material Symbols (rounded) or `lucide_icons` — pick one for consistency.

**Android storage nuance (the plan must handle this explicitly):** broad device scanning is restricted on modern Android. Use `permission_handler` to request appropriate storage access, and recursively scan common document folders (Download, Documents, Books, etc.) for `.pdf`. If broad access is unavailable/denied, fall back gracefully to file-picker-imported books (persisted). On iOS, do not attempt device-wide scanning — use the document picker + app documents directory only. Declare all required permissions and usage strings (`AndroidManifest.xml`, iOS `Info.plist`) and write a short permission rationale shown to the user before requesting.

---

## 5. Screen-by-Screen Specification

The planner must expand each of these into concrete build steps. Keep the design system (Section 6) consistent across all.

### 5.1 Splash Screen
- Native launch screen via `flutter_native_splash` (warm background + centered logo, no white flash).
- Custom animated in-app splash (~2.5–3.5s) reflecting the cozy/premium brand: a warm gradient/mesh background with a subtle vignette; a centerpiece animation (e.g., an open book with gently fluttering pages, or a self-drawing book/monogram logo); the wordmark **"Comfy Reader"** in an elegant serif fading/sliding up; a short tagline (e.g., *"Read like it's a real book."*). Add tasteful motion (scale, parallax, soft glow).
- Do real initialization work during the splash: init storage, load the persisted library, check permission status, warm caches — then transition smoothly (fade / shared-axis) into Home.

### 5.2 Home / Library Screen
- **App bar:** wordmark/logo (serif) left; actions: search, grid/list toggle, day/night toggle, overflow → settings.
- **Continue Reading** (only if a recent book exists): prominent card(s) with the last-read book's cover, title, a progress bar and "page n of m • X%"; tap resumes at the saved page. Horizontal-scroll recents.
- **Library grid (default):** 2–3 columns of book cards. Card = cover (rendered first page, ~3:4 book aspect, rounded corners, soft warm shadow, subtle page-edge detail) with the **PDF name below** (1–2 lines, truncated) and small meta (page count or size) + a thin progress bar if started. Tapping cover **or** name opens the Reader. Long-press → context menu (remove from library, details, share).
- **List view** alternative: row with small cover + name + meta + progress.
- **Search** (filter by name) and **sort** (recent / name / date added).
- **Empty state:** friendly cozy illustration + "No books yet — tap + to add a PDF."
- **FAB** (bottom-right, accent color, "+"/"Add PDF"): opens PDF file picker → imports, generates cover, persists, shows snackbar, optionally opens it.
- **Auto-discovery + pull-to-refresh** to (re)scan device; shimmer placeholders while covers render.

### 5.3 Reader Screen (the star)
- Immersive full-screen (hide system UI), warm paper background behind the page.
- **Page-curl turning:** swipe/drag to curl; tap right third = next, left third = previous, center third = toggle overlay UI. Realistic curl with shadow/gradient.
- **Page-turn sound + light haptic** on each completed turn (respecting settings).
- **Overlay UI** (toggled, auto-hides): top bar (back, book title, bookmark toggle, overflow→reader settings); bottom bar (page scrubber/slider with current/total + thumbnail preview "Go To", prev/next, brightness slider, day/night/sepia toggle, sound on/off).
- **Resume:** auto-save reading position (debounced) on each turn and on close; restore on reopen.
- **Reading comfort:** day/night/sepia tint over rendered pages (night = warm, low blue light); in-app + system brightness; keep screen awake.
- Robust loading/error states per page; smooth on very large PDFs (lazy render + cache from Section 4).
- Portrait primary; landscape two-page spread is **optional/stretch**, not v1-blocking.

### 5.4 Settings (a sheet or simple screen)
- Theme: System / Day / Night. Page-turn sound: on/off + volume. Haptics: on/off. Default page tint: paper / sepia / night. Keep screen on: on/off. Rescan device for PDFs. About.

---

## 6. Design System (premium "comfy" direction — be prescriptive and consistent)

**Brand concept:** warm, cozy, tactile, paper-like, calm, premium.

**Color — Day theme (warm cream/paper):**
- Background `#F6EEE0`, Surface/cards `#FFFBF3`, Primary text/espresso `#3A2E25`.
- Accent (terracotta) `#C56A4E`; secondary (sage) `#7C8C72`; highlight (gold) `#D9A441`.
- Reading page (sepia/paper) `#F4ECD8` with text-dark `#2B2117`.

**Color — Night theme (warm dark):**
- Background `#1A1714`, Surface `#241F1A`, Text `#E8DFD0`, Accent (amber) `#E0A458`.
- Reading page (night) `#141210` with warm-grey text `#C9BFAE`.

**Typography (bundle as assets):** Display/wordmark + section titles: an elegant serif (Playfair Display / Fraunces). Book titles: Lora. UI/body: Inter or Nunito Sans. Define a clear text-style scale.

**Shape & elevation:** rounded corners (cards 16–20px), soft warm-tinted shadows, generous spacing, an 8px spacing scale.

**Motion:** 250–400ms ease-in-out; hero transition cover → reader; staggered fade/slide-in of grid items; shimmer placeholders; the page curl as the signature motion; light haptics on key actions.

**Iconography:** one consistent rounded/line icon set.

The plan must include a step that builds this as a real design-token + theme system (`AppColors`, `AppTypography`, `AppTheme` with `ThemeData` for light & dark, spacing/radius constants) that every screen consumes — no hardcoded colors/sizes scattered in widgets.

---

## 7. Suggested Architecture (feature-first; planner may refine)

```
lib/
  main.dart                 # bootstrap (init services, runApp)
  app.dart                  # MaterialApp(.router), themes, routes
  core/
    theme/                  # app_colors, app_typography, app_theme, dimens
    constants/              # asset paths, durations
    router/                 # routes
    utils/                  # extensions, file/hash helpers
  services/
    pdf_service.dart        # render pages & cover, page count, metadata (pdfx)
    library_service.dart    # discover + import + persist books
    storage_service.dart    # hive/json + shared_prefs init
    audio_service.dart      # page-turn sound (audioplayers)
    permission_service.dart # storage permission flow
    settings_service.dart
  models/                   # book_model, bookmark_model, app_settings
  providers/                # library, reader, settings (provider/riverpod)
  features/
    splash/
    home/    (+ widgets/: book_card, continue_reading, library_grid, empty_state, add_pdf_fab, search_bar)
    reader/  (+ widgets/: page_flip_view, reader_overlay, page_scrubber, brightness_control)
  shared/widgets/           # shimmer, buttons, etc.
assets/
  audio/      # page_flip sound
  animations/ # lottie json (if used)
  images/     # logo, empty-state illustration
  fonts/      # bundled fonts
```

**Data models** (at minimum): `BookModel { id(hash of path), title, filePath, coverImagePath, totalPages, lastReadPage, progress, fileSize, addedAt, lastOpened, isImported }`; `BookmarkModel { bookId, pageIndex, createdAt, note? }`; `AppSettings { themeMode, soundEnabled, soundVolume, hapticsEnabled, pageTint, keepScreenOn }`.

---

## 8. Guardrails (the plan and all later execution MUST obey)

1. **Stay in scope.** Build only Section 3 features. No EPUB/MOBI/CBZ, no TTS, no dictionaries/translation, no annotation/drawing, no cloud/accounts, no online catalogs. Anything else → "Future / Optional."
2. **PDF only** for v1.
3. **Design system is law** — all UI consumes the central theme/tokens; no scattered hardcoded styling.
4. **Performance is a feature** — lazy render + cache; smooth on large PDFs; no jank on the page curl.
5. **Verify after every step** — each step ends with `flutter analyze` clean and (where applicable) `flutter run` on a device/emulator with a stated expected result.
6. **Cross-platform correctness** — handle Android storage-permission nuances and iOS sandbox limits explicitly; declare permissions + usage strings.
7. **Clean, null-safe, commented Dart**, consistent naming, small focused widgets.
8. **No version chaos** — add packages with `flutter pub add`; confirm they resolve together; pin only if needed.
9. **Update `plan.md`** — keep checkboxes current as steps complete; do not silently skip steps.

---

## 9. Required `plan.md` Output Format

Produce **`plan.md`** with:

- A short **Overview** (what we're building, target platforms, chosen key packages + the curl/render approach decision and why, state-management + storage + routing choices).
- A **"How to execute this plan"** note (one step at a time; verify each; check the box).
- The build broken into **ordered phases** (foundation first, then screen by screen, then polish/release):
  - **Phase 0 — Project setup & config** (replace default app, dependencies, assets folders, fonts, native splash, app label → "Comfy Reader", launcher icon, Android permissions + Gradle SDK levels if needed, iOS Info.plist usage strings, `.gitignore`/analysis options).
  - **Phase 1 — Foundation** (design tokens + theme system, models, services scaffolding, storage init, routing, app shell).
  - **Phase 2 — Splash screen.**
  - **Phase 3 — Home / Library** (discovery, FAB import, cover generation + caching, grid/list, continue-reading, search/sort, empty state, pull-to-refresh, shimmer).
  - **Phase 4 — Reader** (PDF render pipeline + cache, page-curl, page-turn audio + haptics, overlay UI, scrubber/Go-To, resume, bookmarks, day/night/sepia, brightness, wakelock).
  - **Phase 5 — Settings.**
  - **Phase 6 — Polish** (transitions, micro-animations, error/empty/loading states, performance pass on a large PDF, accessibility, iOS pass).
  - **Phase 7 — Release prep** (final icon + splash, build instructions, permission rationale, manual QA checklist).
- Each phase contains numbered **steps** (e.g., `Step 3.2`). **Every step MUST include:**
  - `- [ ]` checkbox + a clear title.
  - **Goal:** one line on why.
  - **Files:** exact paths to create/modify.
  - **Packages:** exact `flutter pub add ...` commands (if any).
  - **Implementation details:** concrete, specific instructions (key classes/widgets/functions, props, behavior) — detailed enough to execute without re-deciding scope.
  - **Done when:** explicit acceptance criteria + what to run (`flutter analyze`, `flutter run`) and the expected on-device result.
- Steps must be **small, ordered, and independently executable** — each leaves the app compiling and runnable.
- End with a **"Future / Optional (out of scope for v1)"** section parking everything from the Inspiration list we deliberately excluded (EPUB/MOBI/CBZ, TTS, dictionaries, annotations, cloud, two-page landscape spread, etc.).

Now: inspect the repo, confirm the Project Facts, make the package/approach decisions, and **write `plan.md`** following Section 9 exactly. Do not write any other code.

---

## 10. Inspiration (mood/feature reference ONLY — most of this is intentionally out of v1 scope)

The app is loosely inspired by *Librera Reader* (a lightweight all-formats e-book reader): modern reading UI, theme/accent colors, day/night mode, book display as list or grid, adjustable cover size, library search, favorites & recent lists, notes/bookmarks, library folders, filtered/sorted search, reading settings (backgrounds, fonts, reading direction, white-space cropping, page splitting, locked pages), thumbnailed Go-To, password-protected PDFs, PDF text reflow, TTS read-aloud, dictionary lookup & online translation, comic (CBZ/CBR) support, remember reading position, open books inside zips/emails, export notes, desktop widget, Calibre/OPDS catalogs, EPUB3 multimedia, office formats.

**For Comfy Reader v1 we take only:** the cozy modern reading UI, grid/list library with covers + names, day/night themes, bookmarks, Go-To with thumbnails, remember reading position, and find-PDFs-on-device — **plus our signature additions: realistic book-like page-curl turning and page-turn audio.** Everything else above is explicitly deferred.

=== END OF PROMPT ===
