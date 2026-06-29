# Manager Task · <task-slug>

> Coordination record maintained by the `flutter-manager` skill. **Precise, pointer-based.**
> Summarize conclusions here; link to the artifacts the specialist skills own — do not paste full
> agent output. Update after every phase, then refresh `.claude/manager/index.md`.

- **Request (verbatim):** <what the user asked, including scope>
- **Classification:** <bug | rendering | read-aloud | sync | platform | ui | feature | regression | release> · <sub-area>
- **Status:** <Open | Awaiting approval | In progress | Blocked | Done> · **Phase:** <1 Investigate | 2 Confirm | 3 Present | 4 Approval | 5 Implement | 6 Regression | 7 Verify>
- **Opened:** <YYYY-MM-DD> · **Updated:** <YYYY-MM-DD>

## Routing decision
Why this set of agents/skills (and which ran in parallel). Note any deliberately *excluded* route.

## Agents dispatched
| Agent / skill | Phase | 1-line conclusion | Evidence / artifact link |
|---|---|---|---|
| <e.g. rendering-investigator> | Investigate | <conclusion> | <file:line or artifact path> |

## Root cause / findings
Symptom vs cause, with `file:line` anchors. For features: link the approved spec instead.

## Decisions locked
- <decision> — <why> — <date>

## Approval
- **Gate:** <root cause approved? scope approved? build/deploy approved?> · **By:** <user> · **On:** <date>

## Linked artifacts
- Spec: `.claude/requirements/<...>.md`
- Implementation context: `.claude/implementation/<feature>/implementation-context.md`
- Release: `.project_context/<...>.md`
- Report/template: `.claude/templates/<...>` output

## Pending / Next action
The single next step, and any approval required before it. (This is the resume contract.)
