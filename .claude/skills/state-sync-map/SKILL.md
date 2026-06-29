---
name: state-sync-map
description: >
  Reference map of Comfy Reader's Provider/ChangeNotifier topology and the rules for keeping
  book/reader/settings state in sync. TRIGGER when adding or changing a provider, when wiring
  Consumer/Selector/context.read, when state appears stale across screens (the library shelf shows
  an old page, read-aloud speaks the wrong page), or when a change touches LibraryProvider,
  ReaderProvider, ReadAloudController, or SettingsProvider.
---

# State Synchronization Map

State desync across providers that own overlapping data is Comfy Reader's most common
non-rendering bug class. Use this map; for live diagnosis run **state-sync-tracer**.

## Topology
**App-wide** ([lib/app.dart](../../../lib/app.dart), `MultiProvider`):
- `SettingsProvider` — wraps `SettingsService`; owns `AppSettings`; **persists on every `_update`**.
- `LibraryProvider` — book list, view/sort/search, scanning; `loadFromStorage()` on create.

**Per-reader-session** (created in [reader_screen.dart](../../../lib/features/reader/reader_screen.dart)):
- `ReaderProvider` — current page, overlay, tint, bookmarks, status. **Holds a `LibraryProvider`
  reference** and writes progress back to it.
- `ReadAloudController` — TTS orchestration; **listens to `ReaderProvider`** and always speaks
  `currentPage`.
- `FlipbookController` — page-curl page index (the curl's own controller).

## Ownership overlap (the hazard)
`ReaderProvider` produces the page-progress / last-opened / bookmark facts that `LibraryProvider`
surfaces on the Library + Continue-Reading shelves (`inProgress`, `recents`, `updateProgress`,
`markOpened`). A reader change that doesn't reach `LibraryProvider` (and `StorageService`) shows up
as a **stale shelf or wrong resume point**. The final `updateProgress` in `ReaderProvider.dispose`
is **unawaited** — treat it as a smell, not a pattern to copy.

## Rules
1. **Propagate reader → library.** A page/bookmark change must call `library.updateProgress(...)`
   / `markOpened(...)` so the shelves reflect it. Bookmarks also persist via `StorageService`.
2. **Await persistence that the next step depends on.** Hive writes and `SettingsService.save()`
   are async; await before navigating away or reading the persisted value back.
3. **Notify discipline.** Mutate through provider methods, then `notifyListeners()` **once** per
   coherent change. Never notify inside `build`. Notify *after* an async write completes if the UI
   shows the result.
4. **Reactive vs one-off.** `Consumer`/`context.watch`/`context.select` for UI that must rebuild;
   `context.read` for one-off actions. Over-broad `watch` → excess rebuilds; missing `select` on a
   hot path → jank.
5. **Listener re-entrancy.** `ReadAloudController`'s reader-listener fires during auto-advance
   (`curl.next()` → reader update → listener). Guard against double-speak/skip and invalidate
   `_extractToken` on page change.
6. **Lifecycle.** Cancel timers (`_overlayTimer`, `_saveDebounce`) and unbind TTS callbacks in
   `dispose`; guard post-`await` `context` use with `context.mounted`; don't read a per-session
   provider after the reader is gone.

## When changing state code
1. Identify the data field and every provider/service that reads/writes it.
2. Trace write → `notifyListeners`/listener → downstream syncs (run **state-sync-tracer** for
   non-trivial cases).
3. Ensure reader→library propagation + awaited persistence + correct notify.
4. Have **regression-risk-reviewer** confirm before PR.

## Example usage
- "I'm adding a 'last read at' field write in ReaderProvider — what else must update?"
- "The Continue Reading shelf doesn't refresh after I read a few pages and go back."
