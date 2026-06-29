---
description: Build a feature / enhancement / change end-to-end as a senior Flutter engineer — analyze, plan, implement step by step, and maintain a persistent implementation-context file (delegates to implementation-engineer)
argument-hint: [requirement text / ticket id / path to spec, or "continue <task-slug>"]
allowed-tools: Read, Grep, Glob, Bash, Edit, Write, Task
---

Implement this requirement: **$ARGUMENTS**

Delegate to the `implementation-engineer` agent. This is end-to-end feature/enhancement work:
analyze → plan → implement step by step → validate, while maintaining a persistent
implementation-context file. For requirement-only analysis (no code) use `/analyze-requirement`;
for a single already-investigated minimal bug fix use `/fix-implementer`.

The agent must:
- Load `.claude/project-conventions.md` first (no `CLAUDE.md`/`.cursorrules`), then read the relevant
  `lib/features/<feature>/` and any existing `.claude/requirements/` analysis or
  `.claude/implementation/<task-slug>/implementation-context.md` for this task.
- Investigate before planning: find and reuse the existing similar feature; for platform behavior,
  read BOTH the Android and iOS branches.
- Produce Requirement Analysis + Architecture Findings + Impact Analysis + a phased Implementation
  Plan (File · Purpose · Change Type · Risk · Platform note) **and WAIT for my approval before
  writing code** — unless I explicitly said to run autonomously. STOP and ask on any ambiguity,
  unconfirmable platform behavior, multiple viable approaches, or regression risk.
- Implement one logical change at a time honoring the Comfy Reader rules: design-system first
  (`AppColors`/`AppTypography`/`AppTheme`/`Dimens`/`asset_paths`/`AppDurations`, no hardcoded
  values; inline copy — no l10n), Provider/ChangeNotifier state, complete model-field changes +
  Hive/SharedPreferences round-trip, small `build()`, controller/timer disposal, reader→library
  propagation, resource lifecycle. No new architecture/patterns, no refactor/rename outside the
  requirement.
- Validate each change: `flutter analyze` (touched scope) and the relevant `flutter test` file(s);
  add/adjust tests per project conventions.
- Maintain `.claude/implementation/<task-slug>/implementation-context.md` (Requirement, Findings,
  Plan, Completed, Pending, Decisions, Risks, Blockers) and the `INDEX.md`, appending — never
  overwriting history.

Output the agent's mandated format (Requirement Understanding / Architecture Findings / Impact
Analysis / Implementation Plan / Current Task / Files To Modify / Validation Checklist / Context
File Updated). Then hand back to me for review — do not commit or push.
