---
description: Root-cause a bug and produce the mandated 7-section report (delegates to specialists)
argument-hint: [symptom or short description]
allowed-tools: Read, Grep, Glob, Bash, Task
---

Investigate this bug: **$ARGUMENTS**

Follow the `flutter-bug-investigation` skill exactly:
1. Load `.claude/project-conventions.md` and the relevant `lib/features/<feature>/`,
   `lib/providers/`, or `lib/services/`.
2. Restate the bug (screen, the book in play, action, settings, platform, expected vs actual).
   Ask if unclear.
3. Trace the full flow (widget → provider/controller → service → Hive/PDF/TTS) and delegate to the
   right specialist agent(s): `rendering-investigator` (page-curl / PDF render / tints),
   `read-aloud-auditor` (TTS / OCR / text), `state-sync-tracer` (stale shelf / resume / cross-provider
   state), `platform-parity-investigator` (Android-vs-iOS), `ui-investigator` (visual/interaction).
   Run in parallel if the bug spans areas.
4. Confirm root cause from their evidence — do NOT propose code before this.
5. Output the report using the headings: Bug Summary / Code Flow Analysis / Root Cause /
   Impact Analysis / Proposed Fix / Regression / Validation Checklist.
6. Offer to scaffold fix + tests after I approve the root cause.
