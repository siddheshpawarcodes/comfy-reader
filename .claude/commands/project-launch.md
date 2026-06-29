---
description: Prepare / validate / gate a Flutter release through 7 phases with persistent .project_context state (Senior Release Engineer; approval-gated, never deploys on its own)
argument-hint: [optional: "resume", a phase/scope hint, or a target version/branch]
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task, TodoWrite, AskUserQuestion
---

Run the release-engineering workflow: **$ARGUMENTS**

Follow the `project-launch` skill exactly. In short:
1. Load `.claude/project-conventions.md` and the human docs `README.md`/`QA.md`/`plan.md` (no
   `CLAUDE.md`/`.cursorrules`), and any existing `.project_context/`. If a launch is already in
   progress, **resume — do not restart** (read `launch-status.md` → `launch-plan.md`, continue from
   the last incomplete phase).
2. **Phase 0 first:** capture git working-tree state and branch-vs-`main`. A release must come from a
   clean, intended tree — if it doesn't, stop and confirm release source + target version via
   `AskUserQuestion` before deep work.
3. Run the phases (Assessment → Readiness → Performance → Security → Platform → Checklist → Launch
   gate), persisting findings to the five `.project_context/` files and tracking progress with
   `TodoWrite`. Gather independent facts in parallel; write slow-command output to a log file and Read
   it back (never pipe `flutter test`/builds through `tail`/`head`). Call out the Comfy Reader
   release blockers: the **debug-signing placeholder** (must wire a real keystore) and the
   **`MANAGE_EXTERNAL_STORAGE`** Play sensitive-permission declaration; verify iOS ≥ 15.5 (OCR).
4. Delegate deep read-only analysis to specialist agents — `regression-risk-reviewer` (always, on the
   release diff), plus `rendering-investigator` / `read-aloud-auditor` / `state-sync-tracer` /
   `platform-parity-investigator` as the diff warrants.
5. **Never build or deploy without explicit approval.** `flutter build`, signing/version edits,
   uploads, and `git` writes are gated actions — present the plan, risks, and impact, then wait.
6. Report using the exact headings: Findings / Risks / Recommendations / Actions Performed /
   Pending Actions / Approval Required, with a High/Medium/Low confidence level on every major
   recommendation.
