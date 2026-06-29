---
description: Audit the read-aloud pipeline — text extraction / OCR / language detection / TTS / chunking / auto-advance
argument-hint: [behavior, file, or scenario to audit]
allowed-tools: Read, Grep, Glob, Bash, Task
---

Audit the read-aloud logic for: **$ARGUMENTS**

Apply the `read-aloud-pipeline` skill and delegate the deep work to the `read-aloud-auditor` agent.
It must:
- Cross-check against the `read-aloud-pipeline` skill and
  `.claude/skills/read-aloud-pipeline/reference/script-locale-table.md`.
- Trace the pipeline end to end — `PdfService.extractPageText` + `_normalizeForSpeech` → OCR fallback
  (`OcrService`, Latin+Devanagari, longer-wins) → `LanguageDetector` → chunking (`(?<=[.!?])\s+`,
  >3500 hard-split) → `TtsService.applyLanguage`/`speak` → auto-advance — and verify the race guard
  at each hop (`_extractToken`, the listener re-entrancy, `_consecutiveEmpty`, `_ocrRunning`).
- Check the idle/loading/playing/paused/finished/unavailable state machine, offline-first voice
  selection + missing-voice fallback, the Hindi/Marathi setting, and the Android/iOS engine split.
- Return a stage-by-stage trace, concrete failing inputs for any defect, and a ready-to-use test
  matrix (`.claude/templates/read-aloud-test-matrix.md`).

Escalate: speaks the wrong page because the page rendered/turned wrong → `rendering-investigator`;
cross-provider staleness → `state-sync-tracer`; pure Android-vs-iOS divergence →
`platform-parity-investigator`.
