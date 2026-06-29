---
description: Add a field to a model with full consistency (constructor/copyWith/toMap/fromMap/==)
argument-hint: ModelName fieldName Type
allowed-tools: Read, Grep, Glob, Edit, Bash
---

Add a model field: **$ARGUMENTS**

Per `.claude/project-conventions.md` §4, a Comfy Reader model change (`BookModel`,
`BookmarkModel`, `AppSettings` in `lib/models/`) is **all-or-nothing** — touch every place and
verify:
1. **Property** declaration (final, correct nullability).
2. **Constructor** parameter (named; a default only if the model already uses one — e.g.
   `AppSettings` defaults).
3. **`toMap`** — write the field under a stable key, in a Hive/JSON-safe form (e.g. `DateTime` →
   `millisecondsSinceEpoch`, enums → `.name`, maps via the model's existing coercion).
4. **`fromMap`** — read the same key back, tolerant of an absent key (older stored data must still
   load — supply a sensible fallback, never crash).
5. **`copyWith`** — add the parameter and the `field ?? this.field` line.
6. **`==` / `hashCode`** — only the models that define them (e.g. `AppSettings`, which uses
   `mapEquals` for `voiceByLanguage`); add the field so equality/notify is correct. `BookModel`
   uses id-based identity — match the model's existing equality style, don't add `==` where there
   is none unless asked.

Then check downstream: does the provider that owns this model need to surface/persist it
(`SettingsProvider._update`, `LibraryProvider`, `StorageService`)? Confirm the **Hive /
SharedPreferences round-trip** still holds (write → read → equal). Run `flutter analyze` and the
relevant test (e.g. `language_detector_test.dart` covers `AppSettings` serialization). Report every
file touched and flag any stored-data compatibility concern.
