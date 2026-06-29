---
description: Implement an already-investigated, root-caused, approved fix with minimal code change (delegates to fix-implementer)
argument-hint: [fix plan / "apply the fix from the investigation above"]
allowed-tools: Read, Grep, Glob, Bash, Edit, Write, Task
---

Implement this approved fix: **$ARGUMENTS**

Delegate the implementation to the `fix-implementer` agent. The fix must already be investigated,
root-caused, and approved — if it is not, STOP and run `/investigate-bug` (or the right specialist
investigator) first; do not let the implementer guess.

The agent must:
- Load `.claude/project-conventions.md` (Comfy Reader has no `CLAUDE.md`/`.cursorrules`) and treat
  the supplied investigation / root cause / fix plan as authoritative — no re-investigation, no
  alternate root causes, no scope expansion.
- Verify the investigation matches the current code (root cause, target files, proposed fix). If
  anything is inconsistent, ambiguous, or unverifiable: STOP and ask — do not guess.
- Produce a diff-first plan (files to modify + justification, exact lines/conditions to change,
  impact assessment: Direct / Indirect / Must-Remain-Untouched) BEFORE editing.
- Apply the smallest safe change — one condition / one guard / one callback / one assignment —
  honoring design-system-first (no hardcoded values), small `build()`, complete model-field changes
  (Hive/prefs round-trip), provider state-sync, and resource lifecycle (PDF `close()`,
  controller/timer disposal). Preserve BOTH platform branches for any platform-specific code. No
  refactoring, renaming, reformatting, or opportunistic cleanup.
- Run `flutter analyze` on the touched scope (and any covering test) and report the result.

Output the agent's mandated format: Files To Modify / Methods To Modify / Impact Assessment /
Implementation Plan / Changes Made / Verification. Then hand back to me for review — do not commit
or push.
