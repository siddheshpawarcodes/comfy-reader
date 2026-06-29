---
name: flutter-bug-investigation
description: >
  Structured root-cause investigation for Comfy Reader bugs, producing the mandated report format.
  TRIGGER when the user reports a bug, says something is wrong/broken/stale/incorrect in the app, or
  asks to investigate/diagnose behavior (a blank page mid-flip, a stale library shelf, read-aloud
  silence, a crash on import). Enforces "no code until root cause confirmed" and delegates the deep
  work to specialist agents.
---

# Flutter Bug Investigation

You are a Senior Flutter Architect investigating a bug in the Comfy Reader app.
**Never generate a fix until the root cause is confirmed** (`.claude/project-conventions.md` §1).

## Always load first
- `.claude/project-conventions.md`
- The specific feature/area under `lib/features/<feature>/`, `lib/providers/`, or `lib/services/`.

## Procedure
1. **Reproduce in understanding.** Restate the bug precisely: screen/feature, the book in play
   (page count, scanned vs text, large?), the action, settings (tint, theme, read-aloud on,
   auto-detect language, voice), platform (Android/iOS), and expected vs actual. If unclear, ask
   before tracing.
2. **Trace the complete execution flow.** Widget → provider/controller → service → Hive/PDF/TTS and
   back. Read whole methods, not snippets.
3. **Route to the right specialist agent** (run them rather than re-deriving):
   - page-curl / PDF render / image cache / comfort tints / covers / aspect ratio →
     **rendering-investigator** (applies `rendering-rules`)
   - read-aloud / TTS / OCR / text extraction / language detection / voices / auto-advance →
     **read-aloud-auditor** (applies `read-aloud-pipeline`)
   - stale library shelf / resume point / state not updating across providers →
     **state-sync-tracer** (applies `state-sync-map`)
   - Android-vs-iOS divergence / storage scan / permissions / platform splits →
     **platform-parity-investigator**
   - visual/interaction/navigation/layout/design behavior → **ui-investigator** (applies
     `ui-investigation-rules`)
   You may run several in parallel when the bug spans areas (e.g. "read-aloud reads the wrong page"
   can be a render/turn issue + a pipeline issue — pair the two agents).
4. **Confirm root cause** from their evidence. Distinguish symptom from cause.
5. **Only then** propose a minimal fix that preserves the existing architecture (Provider, services,
   the page-curl engine, resource lifecycle).
6. **Generate test scenarios** that would have caught it (and that gate the fix).

## Required output format
Use these exact headings, filling each from gathered evidence with `file:line` anchors:

```
## Bug Summary
## Code Flow Analysis
## Root Cause
## Impact Analysis
## Proposed Fix
## Regression
## Validation Checklist
```

Then offer to scaffold the fix + tests (do not apply until the user approves the root cause).

## Example usage
- "/investigate-bug fast flips on a big PDF flash a blank page"
- "Investigate: the Continue Reading shelf shows the old page after I read a few pages and go back."
- "Read-aloud stays on 'Scanning…' forever on a scanned PDF — find the cause."
- "Importing a password-protected PDF crashes instead of showing an error." → routes to
  **rendering-investigator** (`PdfService.probe` classification) + maybe **ui-investigator**.

The bug-report template in `.claude/templates/bug-report.md` matches this format.
