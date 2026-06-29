---
description: Implement a small, targeted UI fix — typography / icons / layout / styling (delegates to ui-fixer)
argument-hint: [widget/symptom, e.g. "book title clips on long titles" or book_card.dart]
allowed-tools: Read, Grep, Glob, Bash, Edit, Write, Task
---

Implement this UI fix: **$ARGUMENTS**

Apply the `ui-investigation-rules` skill and delegate the implementation to the `ui-fixer` agent.

The agent must:
- Load `.claude/project-conventions.md` (§1 rules, §2 architecture, §4 high-risk files) and the
  `ui-investigation-rules` skill checklists before touching code.
- Confirm the visual root cause (which widget, which value, which source, with `file:line`). If the
  root cause is not obvious from reading the widget + its style source, or the issue turns out to
  involve behavior/logic — STOP and hand off to `ui-investigator` first. Never edit on a guess.
- Make the smallest behavior-preserving change, design-system first: prefer an existing
  `AppColors`/`AppTypography`/`Dimens`/`asset_paths` value, then theme (`ComfyColors`), then a
  `lib/shared/widgets/` component, then a small local `.sp`/`.w`/`.h`/`EdgeInsets` adjustment; a new
  value only as a last resort, placed in the design-system source.
- Map the impact radius (shared tokens ripple to all consumers + both day/night themes + the reader
  tints) and preserve all behavior, state flow, navigation, interactions, controller/timer
  lifecycle, accessibility, and responsive (portrait) behavior.
- Run `flutter analyze` on the changed scope (and any covering widget test) and report the result.

Escalate, don't guess: page-curl/PDF render/tint geometry → `rendering-investigator`;
read-aloud/TTS/OCR → `read-aloud-auditor`; Android-vs-iOS → `platform-parity-investigator`;
cross-provider staleness → `state-sync-tracer`. If the "UI fix" needs any of that logic, surface it
and stop — it is no longer a pure UI fix.

Output the agent's exact headings: Issue / Root Cause / Files Modified / Changes Made /
Risk Assessment / Verification. Hand back for review — do not commit or push.
