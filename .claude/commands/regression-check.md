---
description: Pre-PR regression gate — blast radius, project review checklist, required checks
argument-hint: [optional: base branch, default main]
allowed-tools: Read, Grep, Glob, Bash, Task
---

Run a regression review of the current diff (base: ${ARGUMENTS:-main}).

Delegate to the `regression-risk-reviewer` agent. It must:
- `git diff` against the base, map each changed file to high-risk modules + regression-prone
  workflows (`.claude/project-conventions.md` §4): reading (open→render→flip→resume), the page-curl
  engine, the read-aloud pipeline, library scan/permissions, settings/theme/tints,
  persistence/models, platform splits.
- Run the project review checklist (no-hardcoded-values / design-system, model-field completeness +
  Hive/prefs round-trip, provider state-sync incl. `ReaderProvider`→`LibraryProvider` propagation,
  `build()` small, controller/timer disposal, resource lifecycle (PDF `close()`, image-cache cap,
  `Semaphore(3)`), page-curl/read-aloud preservation, both-platforms-correct) with PASS/FAIL +
  evidence.
- List required checks (`flutter analyze`, `flutter test`) and workflow-specific manual smoke steps
  (flip a large + a scanned PDF, resume, toggle each tint, read-aloud a text + scanned page,
  import + Android device-scan).
- Return GO / GO-WITH-CONDITIONS / NO-GO. Use `.claude/templates/pr-regression-checklist.md`.
