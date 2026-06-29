---
name: rendering-rules
description: >
  Canonical investigation rules for Comfy Reader's rendering subsystem — the vendored page-curl
  engine (flip_book.dart: curl math, drag gestures, widget-snapshot capture, zoom, single/spread
  layout, stuck-flip watchdog), the PDF render pipeline (pdf_service, pdf_page_image_provider,
  book_curl_view), the image cache + Semaphore throttle, and comfort tints. TRIGGER when reading,
  changing, debugging, or reviewing flip_book.dart, book_curl_view.dart, pdf_page_image_provider.dart,
  pdf_service.dart, the image-cache setup, or any page-render / curl / tint / cover logic.
---

# Rendering Rules (page-curl + PDF pipeline)

Comfy Reader's rendering core is its **#1 hotspot**: a vendored 3D page-curl engine fed by a
short-lived PDF-to-image pipeline. Most rendering bugs are one of: (a) a **curl geometry/gesture**
error, (b) a **widget-snapshot or image-load race** (blank/stale/wrong page mid-flip), (c) a
**stuck-flip / watchdog** failure, (d) an **image-cache / memory** problem, or (e) a **tint or
aspect-ratio** mismatch. Find which — with `file:line` evidence — before anyone writes code. For
the deep trace, run **rendering-investigator**.

## Read alongside this
- `.claude/project-conventions.md` §3a (rendering), §4 (high-risk files), §10 (resource rules).
- The code: [flip_book/flip_book.dart](../../../lib/flip_book/flip_book.dart),
  [book_curl_view.dart](../../../lib/features/reader/widgets/book_curl_view.dart),
  [pdf_page_image_provider.dart](../../../lib/features/reader/pdf_page_image_provider.dart),
  [pdf_service.dart](../../../lib/services/pdf_service.dart),
  [semaphore.dart](../../../lib/core/utils/semaphore.dart), and the image-cache setup in
  [lib/main.dart](../../../lib/main.dart).

## The 10 rules

1. **Open → render → close, always.** A PDF document is opened, rendered, and `close()`d in a
   `finally`. Never leave a handle open; never render a page you don't need. `PdfService.probe()`
   classifies ok/missing/protected/corrupt — respect that result, don't re-open blindly.
2. **pdfx renders, pdfrx extracts — don't cross them.** Display rendering goes through `pdfx`
   (`PdfService.renderPage`, **1-based** page index, white background, aspect-preserving height);
   text for read-aloud goes through `pdfrx`. Using the wrong library for the wrong job is a bug.
3. **`PdfPageKey` is the cache identity.** `(bookId, pageIndex, targetWidth)` with `==`/`hashCode`.
   A key mismatch causes redundant re-renders or a wrong-page cache hit; a too-coarse key serves a
   stale render. Verify equality covers exactly what changes the pixels.
4. **Respect the image-cache cap.** `PaintingBinding.instance.imageCache` is capped (≈14 pages /
   ≈220 MB, LRU) in `main.dart`. A single page can be ~14 MB. Don't hold extra `ImageProvider`
   references that defeat eviction; large books are where OOM/jank appears.
5. **Throttle cover renders.** Library cover generation runs through `Semaphore(3)`
   (`LibraryService.ensureCover`). Don't bypass it — unthrottled concurrent renders stall the
   PDFium renderer during scroll.
6. **Snapshots happen before the flip.** The curl captures widget pages to `ui.Image` *before*
   animating, and preloads ±3. A blank/wrong page mid-flip is usually a snapshot-not-ready or an
   image-load that resolved for the wrong (already-changed) page — a race, not a draw bug.
7. **The watchdog is a safety net, not a fix.** `flip_book.dart` detects a stuck flip (idle +
   no-progress timeout) and recovers (animated retry, max ~2, then manual reset). If a flip
   regularly triggers the watchdog, the cause is upstream (snapshot/image timing) — trace that.
8. **Lifecycle callbacks are `onFlip*Start/End`, not `onPageChanged`.** `book_curl_view.dart`
   bridges them to `ReaderProvider.onPageChanged` + `AudioService.playPageTurn`. Page-state changes
   must flow through that bridge so progress + sound + read-aloud stay consistent.
9. **Tints recolor, they don't re-render.** Paper/sepia/night are applied via `ColorFiltered` over
   the rendered page (night inverts luminance). A "wrong color in the reader" is the tint matrix or
   the theme, not the PDF render. Verify the matrix and that the same page image is reused.
10. **Aspect ratio comes from `firstPageSize`.** The flipbook's size hint and per-page height derive
    from the PDF point size; a squashed/letterboxed page means a wrong size hint or a mismatched
    `targetWidth`→height computation, not a curl bug.

## Investigation checklist
- [ ] Repro defined: book (page count, scanned vs text, large?), single vs spread, zoom, tint, gesture.
- [ ] Render path traced: visible page → `PdfPageImageProvider`/`PdfPageKey` → `renderPage` → decode
      → `ImageInfo` → flipbook page → snapshot → curl draw (with `file:line`).
- [ ] Flip path traced: drag→progress→animate→settle→`onFlip*End`→`book_curl_view`→reader+audio.
- [ ] Races labeled "observed in code" vs "theoretical" (snapshot-vs-flip-start, preload-vs-change,
      `PdfPageKey` staleness, watchdog firing).
- [ ] Memory/cache checked: can this book exceed the cap? wrong-page hit? swallowed decode failure?
- [ ] Tint/geometry checked: `ColorFiltered` matrix, `firstPageSize`/`targetWidth` aspect.
- [ ] Resource lifecycle: every opened doc `close()`d; cover renders via `Semaphore(3)`.

## Hand-offs
- Cross-provider staleness (shelf/resume page) beyond rendering → **state-sync-map** + **state-sync-tracer**.
- Read-aloud reads the wrong page / TTS / OCR → **read-aloud-pipeline** + **read-aloud-auditor**.
- One-platform-only divergence → **platform-parity-investigator**.
- "Show me how it renders" (pixels) → **visual-verification** skill / **visual-verification-engineer**
  (note: live PDF/curl needs a device, not pure `flutter test`).

## Hard rule
Read-only investigation. Cite `file:line` for every claim; distinguish facts from assumptions. **Do
not propose fixes unless explicitly asked.** A slow first frame / first PDF render on a debug x86
emulator is a JIT/software artifact (`README.md`), not a defect — reproduce on the terms that matter.

## Example usage
- "Flipping fast on a 600-page PDF shows a blank page for a beat."
- "Night mode looks washed out on some PDFs but not others."
- "Covers stutter the library scroll when many new books appear."
