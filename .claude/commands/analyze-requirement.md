---
description: Turn a business requirement into a developer-ready implementation analysis before any code (delegates to requirement-analyst)
argument-hint: [requirement text / ticket id / path to spec or email]
allowed-tools: Read, Grep, Glob, Bash, WebFetch, WebSearch, Task
---

Analyze this requirement: **$ARGUMENTS**

Delegate the analysis to the `requirement-analyst` agent. This is analysis only — no code, no file
changes, no PRs, and never silently fill gaps.

The agent must:
- Load `.claude/project-conventions.md` (Comfy Reader has no `CLAUDE.md`/`.cursorrules`), then read
  the relevant `lib/features/<feature>/`, `lib/providers/`, `lib/services/` to ground the analysis
  in the real architecture.
- Restate the requirement in plain language, then enumerate explicit vs inferred functional
  requirements — labeling every inference and assumption explicitly.
- Assess Flutter impact: architecture, state (Provider/ChangeNotifier), models/persistence (Hive +
  SharedPreferences), navigation (go_router), and the high-risk modules it touches (page-curl, PDF
  render, read-aloud pipeline). No backend/l10n — say "local only" / "no API" rather than inventing
  one.
- Identify edge cases (missing/corrupt/protected PDF, scanned vs text, missing voice, permissions,
  large books/memory), risks, dependencies, QA considerations, missing/ambiguous information, rough
  effort, and a phased implementation roadmap.
- List all ambiguities and open questions explicitly and WAIT for my approval — do not assume a
  resolution and do not begin development.

After approval, the next step is `/implementation-engineer` (feature build) or `/fix-implementer` /
`/ui-fixer` (a small change) — not before.
