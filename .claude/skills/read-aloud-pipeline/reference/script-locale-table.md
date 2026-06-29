# Script → Locale Reference (read-aloud language detection)

> Canonical mapping used by [language_detector.dart](../../../../lib/core/utils/language_detector.dart).
> `LanguageDetector.detect(text)` counts runes by Unicode block, picks the dominant
> `ReadingScript`, and `languageFor(script, devanagariIsMarathi)` resolves it to a BCP-47 locale
> passed to `TtsService.applyLanguage`. Verify exact ranges/values against the source — this is a
> reference, the code is the source of truth.

## ReadingScript → BCP-47 locale

| ReadingScript | Unicode block (approx) | BCP-47 locale | Notes |
|---|---|---|---|
| latin | U+0041–U+024F | (engine default / en-*) | English + most Latin scripts |
| devanagari | U+0900–U+097F | `hi-IN` **or** `mr-IN` | **ambiguous** — resolved by `devanagariLanguage` setting |
| bengali | U+0980–U+09FF | `bn-IN` | |
| gurmukhi | U+0A00–U+0A7F | `pa-IN` | Punjabi |
| gujarati | U+0A80–U+0AFF | `gu-IN` | |
| oriya | U+0B00–U+0B7F | `or-IN` | Odia |
| tamil | U+0B80–U+0BFF | `ta-IN` | |
| telugu | U+0C00–U+0C7F | `te-IN` | |
| kannada | U+0C80–U+0CFF | `kn-IN` | |
| malayalam | U+0D00–U+0D7F | `ml-IN` | |
| unknown | — | (no change / skip) | must not crash; degrade gracefully |

## Devanagari disambiguation
Hindi and Marathi share the Devanagari block, so script detection alone can't tell them apart. The
pipeline uses the user's `AppSettings.devanagariLanguage` (`hi-IN` / `mr-IN`) to pick. A test that
feeds Devanagari text must assert the chosen locale flips with that setting.

## Voice resolution (after locale)
`TtsService.applyLanguage(locale, preferredVoiceName)`:
1. If `voiceByLanguage[locale]` is set and still installed → use it.
2. Else pick the best **offline** voice for the language subtag (offline gets a large quality bonus).
3. Else fall back to the engine default for the locale and surface the install path (`TtsPlatform`)
   — never fail silently.

## Test cases this table drives
- A page per script → expected locale (incl. the Hindi/Marathi flip).
- Mixed-script page → dominant script wins; assert the count logic.
- Out-of-range / symbol-only / empty text → `unknown` → no crash, no wrong-voice playback.
