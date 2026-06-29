---
description: Investigate a rendering / page-curl / PDF-render / tint bug (read-only, no fixes)
argument-hint: [symptom, e.g. "blank page on fast flip" or flip_book.dart]
allowed-tools: Read, Grep, Glob, Bash, Task
---

Investigate this rendering / page-curl issue: **$ARGUMENTS**

Apply the `rendering-rules` skill and delegate the deep trace to the `rendering-investigator` agent.
It must:
- Load `.claude/project-conventions.md` §3a/§4/§10 and the `rendering-rules` skill checklist.
- Trace the render + flip flow across `flip_book.dart`, `book_curl_view.dart`,
  `pdf_page_image_provider.dart`, `pdf_service.dart`, and the image-cache/`Semaphore` setup, using
  the real anchors (`FlipbookController`, `onFlip*Start/End`, widget-snapshot capture, `_preloadImages`,
  the stuck-flip watchdog, `PdfPageKey`, `PdfService.renderPage` 1-based index, `ColorFiltered` tints).
- Determine the root-cause class: curl geometry/gesture, widget-snapshot/image-load race, stuck-flip/
  watchdog, image-cache/memory, or tint/aspect-ratio mismatch.
- Output: Render Flow Analysis / Root Cause / Impact Analysis / Risk Assessment / Validation Scenarios.

Escalate as needed: cross-provider staleness (shelf/resume) → `state-sync-tracer`; read-aloud reads
the wrong page / TTS → `read-aloud-auditor`; one-platform-only divergence →
`platform-parity-investigator`. Don't call a slow debug/emulator first-frame a bug. Do not propose
code until the root cause is confirmed.
