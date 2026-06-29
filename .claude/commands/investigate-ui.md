---
description: Investigate UI behavior / visual implementation of a screen, widget, interaction, or visual inconsistency (read-only, no fixes)
argument-hint: [screen/widget/symptom, e.g. "read-aloud bar stuck on Scanning" or reader_overlay.dart]
allowed-tools: Read, Grep, Glob, Bash, Task
---

Investigate this UI / visual issue: **$ARGUMENTS**

Apply the `ui-investigation-rules` skill and delegate the deep trace to the `ui-investigator` agent.
It must:
- Load `.claude/project-conventions.md` (§1 rules, §2 architecture, §4 high-risk files, §6 state
  sync) and the `ui-investigation-rules` skill checklists.
- Reconstruct the user journey, then trace widget hierarchy → state flow (Provider/ChangeNotifier →
  `Consumer`/`context.watch`/`Selector` → rebuild) → interactions → conditional rendering →
  navigation (`go_router`) → lifecycle (timers/controllers) → async, citing `file:line`.
- Run the visual audit against the design system: typography/`AppTypography`, icons/`asset_paths`,
  layout/`Dimens`+`flutter_screenutil`, colors/`AppColors`+`ComfyColors`, comfort tints, and flag
  design-system deviations (raw Material, hardcoded colors/sizes/styles). (No l10n — flag
  inconsistent inline copy + overflow, not missing keys.)
- Output: Scope / Files / User Flow / Widget Hierarchy / State Flow / Interaction Trace /
  Conditional Rendering Audit / Navigation & Lifecycle / Async Findings / Visual Audit /
  Accessibility / Performance / Hidden Dependencies / Root Cause Candidates (Evidence + Confidence) /
  Confidence Assessment / Recommended Verification Steps.

Escalate as needed: page-curl/PDF render/image-cache/tint geometry → `rendering-investigator`;
read-aloud/TTS/OCR behavior → `read-aloud-auditor`; Android-vs-iOS → `platform-parity-investigator`;
cross-provider staleness → `state-sync-tracer`.

Read-only. Do not propose fixes unless I explicitly ask.
