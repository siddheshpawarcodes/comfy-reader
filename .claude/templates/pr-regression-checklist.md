# PR Regression Checklist — <branch>

- Base: `main`  ·  Diff: `git diff main...HEAD`
- Changed files mapped to high-risk modules / workflows:

| changed file | high-risk module? | workflows it can affect |
|---|---|---|
|  |  |  |

## Project review checklist (PASS / FAIL / N-A + evidence)
- [ ] No hardcoded values: colors → `AppColors`/`ComfyColors`; styles → `AppTypography`; spacing → `Dimens`; assets → `asset_paths`; durations → `AppDurations`
- [ ] Model change touched constructor + `copyWith` + `toMap` + `fromMap` (+ `==`/`hashCode` where defined); Hive/prefs round-trip preserved
- [ ] Provider state-sync: `ReaderProvider` → `LibraryProvider` propagation; `notifyListeners` once per change; async persistence awaited where the next step depends on it
- [ ] `build()` has no logic/function defs; handlers are named methods
- [ ] Controllers & timers disposed (overlay timer, save debounce, `FlipbookController`, TTS callbacks unbound)
- [ ] Resource lifecycle: PDF docs `close()`d in `finally`; image-cache cap respected; cover renders via `Semaphore(3)`; no `getTemporaryDirectory()` for user data
- [ ] Page-curl changes preserve gesture/animation/snapshot/watchdog behavior
- [ ] Read-aloud changes preserve `_extractToken` guard, the state machine, offline-first voice pick
- [ ] Both Android and iOS branches correct (scan/permission/TTS/voice-install/OCR); no one-platform assumption

## Required checks
- [ ] `flutter analyze` clean
- [ ] `flutter test` green
- [ ] Specialist agents run as needed (rendering / read-aloud / sync / platform)

## Regression watchlist (ranked scenarios most likely to break)
1.
2.

## Verdict
- [ ] GO
- [ ] GO-WITH-CONDITIONS — conditions:
- [ ] NO-GO — blockers:
