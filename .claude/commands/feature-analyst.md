---
description: Turn an incoming spec (PDF, Word/DOCX, images/mockups, text, ticket, email) into a developer-ready specification + phased roadmap artifact for /implementation-engineer (delegates to feature-analyst)
argument-hint: [path to PDF/DOCX/image/spec, or requirement text / ticket id]
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, WebFetch, WebSearch, Task
---

Analyze and specify this requirement: **$ARGUMENTS**

Delegate to the `feature-analyst` agent. This is the confident, multimodal front of the build
pipeline: ingest the source → understand it by scanning the codebase → write a single specification
+ roadmap artifact that `/implementation-engineer` will build. No production code, no tests, no PRs.

The agent must:
- Load `.claude/project-conventions.md` (no `CLAUDE.md`/`.cursorrules`), then check
  `.claude/requirements/` and `.claude/implementation/` for existing work to extend.
- Ingest the source in whatever form it arrives — Read PDFs page by page (`pages` ranges), look at
  images/mockups directly, convert Word/RTF docs first (`textutil -convert txt … ` on macOS, then
  Read), read text/ticket/email/notes; `WebFetch` any referenced URL. Never paraphrase a visual it
  didn't actually open; if a doc can't be converted, ask for a PDF export.
- **Resolve ambiguity itself first** — re-read the source, scan the real `lib/features/<feature>/`,
  `lib/providers/`, `lib/services/`, `lib/models/`, `lib/core/` for how the app already does the
  closest thing (cite `file:line`), check the knowledge base, and apply the Comfy Reader rules.
  State judgment calls as labeled assumptions with evidence. Escalate ONLY genuine blockers
  (self-contradiction, unverifiable platform behavior, materially different equal options, a missing
  required number/rule) — each with a recommended default.
- Ground the spec in the real architecture (UI/go_router, Provider/ChangeNotifier + cross-provider
  sync, models + full constructor/copyWith/toMap/fromMap/==, Hive/SharedPreferences, design-system
  tokens, the page-curl + read-aloud high-risk modules) and honor the Comfy Reader rules so the
  roadmap is already conformant. Flutter-first — never claim "works on both platforms" without
  reading both branches; flag MUST-VERIFY items for the engineer.
- Write the deliverable to `.claude/requirements/features/<task-slug>.md` (or bugs/enhancements),
  update `.claude/requirements/index.md`, and mark Status: Pending Approval. Write ONLY inside
  `.claude/requirements/` (and `.claude/implementation/` when extending) — never `lib/`, `test/`, or
  any production source, and never overwrite the engineer's implementation-context.

Output the agent's handoff block (Artifact path · Index updated · Confidence · MUST-VERIFY · Open
Questions with recommended defaults · NEXT STEP). After approval, the next step is
`/implementation-engineer <task-slug>` — it reads this spec from `.claude/requirements/` as its
starting requirement.
