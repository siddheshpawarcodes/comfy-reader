# Bug Report — <short title>

> Matches the mandated format in the `flutter-bug-investigation` skill. Fill every section from
> evidence with `file:line` anchors. Do not propose code until Root Cause is confirmed.

## Bug Summary
- Reported behavior:
- Expected behavior:
- Screen / feature:
- Book in play (page count / scanned vs text / large?):
- Settings in play (tint / theme / read-aloud on / auto-detect language / voice):
- Platform (Android / iOS) + device & OS:
- Reproduction steps:

## Code Flow Analysis
- Entry point (widget): `lib/features/.../...dart:`
- Provider / controller: `lib/providers/...dart:`
- Service: `lib/services/...dart:`
- Storage / engine (Hive / PDFium-pdfx / pdfrx / flutter_tts / ML Kit):
- Full path the data takes (and where it goes wrong):

## Root Cause
- Confirmed cause (symptom vs cause distinguished):
- Evidence (excerpts + line refs; specialist agent findings):
- Platform status (if relevant): correct on Android / iOS / both / one broken

## Impact Analysis
- Affected inputs (book type / settings / platform):
- User consequence:
- Other features sharing this code:

## Proposed Fix
- Minimal change preserving the existing architecture (Provider / services / page-curl engine):
- Files to touch:
- Why this is the smallest correct fix:

## Regression
- High-risk workflows possibly affected (reading / read-aloud / library / settings):
- Project review-checklist items at risk:
- Mitigations:

## Validation Checklist
- [ ] Root cause confirmed before coding
- [ ] `flutter analyze` clean
- [ ] `flutter test` green (new tests added for this bug where feasible)
- [ ] Manual smoke of affected workflow(s) (`QA.md`)
- [ ] Both platforms checked (if platform-specific)
- [ ] Model / Hive / prefs round-trip intact (if persistence touched); PDF docs closed, controllers/timers disposed
