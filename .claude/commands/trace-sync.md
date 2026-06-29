---
description: Trace cross-provider state flow and find stale/desync/race hazards
argument-hint: [data field, screen, or "why is X stale"]
allowed-tools: Read, Grep, Glob, Bash, Task
---

Trace provider state synchronization for: **$ARGUMENTS**

Use the `state-sync-map` skill and delegate to the `state-sync-tracer` agent. It must:
- Build the propagation graph for the data field (which provider writes it, which
  `Consumer`/`context.watch`/`addListener` reacts, which downstream provider/service it calls).
- Check the hazards: un-awaited Hive/`SettingsService` persistence (incl. the unawaited
  `updateProgress` in `ReaderProvider.dispose`), missing `ReaderProvider` → `LibraryProvider`
  propagation (`updateProgress`/`markOpened`), missing/duplicate `notifyListeners`, and the
  `ReadAloudController` ↔ `ReaderProvider` listener re-entrancy / `_extractToken` invalidation.
- Label each finding "observed in code" vs "theoretically possible" and give the user-visible symptom
  (stale shelf, wrong resume page, double-speak).

Hand off to `rendering-investigator` if the cause is the page-curl/PDF render loop, or to
`read-aloud-auditor` if it's the TTS pipeline rather than cross-provider state.
