# Read-Aloud Test Matrix — <feature/change>

> Cover the pipeline stages touched (extract → OCR → detect → chunk → speak → advance), the language
> cases, the state machine, the race guards, and both platforms where they differ. Drop the
> resulting cases into `test/`. Reference:
> `.claude/skills/read-aloud-pipeline/reference/script-locale-table.md`.

## Pipeline / language cases
| # | page content | readScannedBooks | expected source | expected locale | expected outcome |
|---|---|---|---|---|---|
| 1 | text, English | n/a | pdfrx text layer | en-* / engine default | speaks |
| 2 | text, Hindi (Devanagari) | n/a | text layer | hi-IN (setting=Hindi) | speaks Hindi voice |
| 3 | text, Marathi (Devanagari) | n/a | text layer | mr-IN (setting=Marathi) | speaks Marathi voice |
| 4 | scanned (no text layer) | ON | OCR (longer of Latin/Devanagari) | per detected script | speaks |
| 5 | scanned (no text layer) | OFF | — | — | skipped; → `unavailable` after ~8 empty |
| 6 | mixed script | n/a | text layer | dominant script wins | speaks dominant |
| 7 | symbol-only / empty | n/a | — | unknown | no crash, no wrong-voice playback |

## State-machine cases
| # | action | from state | expected state |
|---|---|---|---|
| S1 | play | idle | loading → playing |
| S2 | pause / resume | playing | paused → resumes correct chunk |
| S3 | stop | playing | idle (full teardown, no orphan onComplete) |
| S4 | finish last page | playing | finished |
| S5 | fully-scanned book, OCR off | loading | unavailable (no spin) |

## Race / concurrency cases
- Page changes mid-extraction → `_extractToken` discards stale text, speaks the new page.
- Page changes mid-OCR → stale OCR result discarded.
- Auto-advance re-entrancy (`curl.next()` → reader update → listener) → no double-speak / no skip.
- Rapid play→stop → no orphan utterance fires `onComplete` into a dead controller.

## Voice cases
- Preferred voice set + installed → used.
- Preferred voice missing/uninstalled → best **offline** voice fallback + install path surfaced.
- Voice list invalidated after returning from the TTS-install screen (new voice appears).

## Platform cases
- Android (Google engine, intent install) vs iOS (system engine, manual install).
- OCR available (iOS 15.5+ / Play Services) vs unavailable → graceful.
