---
name: read-aloud-pipeline
description: >
  Canonical reference + rules for Comfy Reader's read-aloud (TTS) pipeline: PDF text extraction,
  the OCR fallback for scanned pages, offline language/script detection, sentence chunking, TTS
  voice selection and playback, page auto-advance, and the idle/loading/playing/paused/finished/
  unavailable state machine — across the Android (Google engine) and iOS (system engine) split.
  TRIGGER when reading, changing, or testing read_aloud_controller.dart, tts_service.dart,
  ocr_service.dart, tts_platform.dart, language_detector.dart, or PdfService.extractPageText.
---

# Read-Aloud Pipeline

Read-aloud is the app's most stateful, most race-prone correctness domain: a long-running pipeline
spanning text extraction, on-device OCR, language detection, TTS, and page navigation — over two
platforms with different engines. Errors mean the app speaks the wrong page, the wrong language,
gibberish, or nothing. For a live audit run **read-aloud-auditor**.

## Read alongside this
- `.claude/project-conventions.md` §3b (read-aloud), §4 (high-risk files), §7 (platform behavior).
- The code: [read_aloud_controller.dart](../../../lib/providers/read_aloud_controller.dart),
  [tts_service.dart](../../../lib/services/tts_service.dart),
  [ocr_service.dart](../../../lib/services/ocr_service.dart),
  [tts_platform.dart](../../../lib/services/tts_platform.dart),
  [language_detector.dart](../../../lib/core/utils/language_detector.dart),
  and `PdfService.extractPageText` in [pdf_service.dart](../../../lib/services/pdf_service.dart).
- Reference table: [reference/script-locale-table.md](reference/script-locale-table.md).

## The pipeline (each stage is a failure surface)
```
ReaderProvider.currentPage
   │
   ▼  extract text (pdfrx)  →  _normalizeForSpeech
   │        │ empty?  ── yes ─▶ OCR fallback (ML Kit Latin+Devanagari, longer wins)   [if readScannedBooks]
   ▼        ▼ no / OCR text
   detect language  (Unicode-block script count → BCP-47 locale)
   ▼
   chunk  (split on (?<=[.!?])\s+ ; hard-split runs > ~3500 chars)
   ▼
   applyLanguage(locale, preferredVoice)  →  speak(chunk)
   ▼
   onComplete → next chunk, else curl.next() → next page (re-enters the listener)
```

## The 10 rules

1. **Always read `ReaderProvider.currentPage`.** The controller never caches a page number it
   speaks from; it reads the reader. Auto-advance calls `curl.next()`, which turns the page and
   updates the reader, **re-entering** the listener — guard against double-speak and skips.
2. **`_extractToken` guards every async result.** Capture the token before the `await` (extract or
   OCR), re-check it after; if the page changed mid-flight, **discard** the stale text. A missing
   re-check is how the wrong page gets spoken.
3. **OCR is a fallback, not the default.** Run OCR only when the text layer is empty **and**
   `readScannedBooks` is on. It's expensive (renders a ~2000px PNG + runs ML Kit).
4. **Run both recognizers; keep the longer.** Latin + Devanagari run together; the wrong script
   returns little/nothing, so the **longer** result wins. One recognizer failing must not kill the
   other. Cache per page (session FIFO ≈64) so pause/resume doesn't re-scan; temp-file cleanup is
   best-effort.
5. **Detect language on the actual (post-normalize) text, per page.** `_normalizeForSpeech` joins
   hyphenated line breaks and collapses whitespace but **preserves `.!?`** for sentence splitting.
   `LanguageDetector` counts runes by Unicode block → `ReadingScript` → BCP-47 locale. Devanagari is
   **Hindi vs Marathi**, resolved by the user's `devanagariLanguage` setting. An undetected script
   must degrade gracefully, not crash.
6. **Chunk for the engine.** Split on `(?<=[.!?])\s+`; hard-split any run > ~3500 chars (engine
   limit ~4000). Pause/resume must resume the correct chunk; stop must fully tear down so no orphan
   utterance fires `onComplete` into a dead controller.
7. **Voice selection is offline-first.** `applyLanguage(locale, preferredVoiceName)` prefers the
   user's `voiceByLanguage[locale]`, else the best **offline** voice (the quality score gives
   offline a large bonus — network voices are unreliable offline). A missing/uninstalled voice falls
   back gracefully and surfaces the install path, not a silent failure.
8. **The voice list is cached — invalidate it.** Enumeration is expensive and cached after first
   call; invalidate after returning from the TTS-install screen so newly-installed voices appear.
9. **Empty/finish logic is explicit.** `_consecutiveEmpty` (≈8) → `unavailable` (a fully-scanned
   book with OCR off must END as `unavailable`, not spin). Finishing the last page → `finished`.
   `_ocrRunning` drives the "Scanning…" status — it must clear on every exit path.
10. **Respect the platform split (§7).** Android prefers the Google engine and can fire
    install/settings intents via `TtsPlatform`; iOS uses the fixed system engine and `TtsPlatform`
    returns false (UI guides the user). OCR needs **iOS 15.5+**. Never assume one platform's behavior
    on the other.

## State machine
`idle → loading → playing ⇄ paused → finished` and any → `unavailable`. Every transition must be
reachable and reversible where intended; `stop()` returns to `idle` and tears down cleanly.

## Investigation / test checklist
- [ ] Pipeline traced extract → OCR → detect → chunk → speak → advance, with the guard at each hop.
- [ ] `_extractToken` captured-before/checked-after the await on both extract and OCR.
- [ ] OCR runs only when needed; both recognizers attempted; longer-result rule; cache hit on resume.
- [ ] Language detected on post-normalize text; Hindi/Marathi setting honored; unknown script safe.
- [ ] Chunking + pause/resume + stop teardown correct; no orphan `onComplete`.
- [ ] Offline-first voice pick; missing-voice fallback + install path; list invalidated post-install.
- [ ] `_consecutiveEmpty`/finish/`_ocrRunning` exits correct.
- [ ] Both Android and iOS paths considered (engine, install, OCR version gate).

## Test matrix (drop into `test/`)
Use [reference/script-locale-table.md](reference/script-locale-table.md) and the
`read-aloud-test-matrix` template: text page · scanned page (OCR on/off) · mixed script ·
Hindi vs Marathi · missing/uninstalled voice · rapid page change mid-extraction · pause→resume ·
last page · empty/blank book.

## Hand-offs
- Speaks the wrong page because the **page rendered/turned wrong** → **rendering-rules** /
  **rendering-investigator**.
- Cross-provider staleness (reader↔library) rather than the pipeline → **state-sync-map** /
  **state-sync-tracer**.
- Pure Android-vs-iOS engine/permission divergence → **platform-parity-investigator**.

## Hard rule
Read-only investigation. Cite `file:line`. Don't blame "wrong language" without checking the
detector's actual input (post-normalize text); don't blame TTS for an extraction/OCR gap.

## Example usage
- "A scanned Hindi PDF stays silent." → empty text-layer → OCR path → Devanagari wins → hi-IN/mr-IN
  per setting → offline Hindi voice. Find the stage that breaks, per platform.
- "It reads two sentences then jumps a page." → auto-advance re-entrancy / chunk-complete logic.
