# Read-Aloud Improvement Plan

Status: proposal · Owner: TBD · Target app: **commercial** (affects voice licensing)

## Why

Three user complaints with the current read-aloud feature:

1. **Sounds like a mechanical bot** — robotic voice.
2. **Indian-language accents are not proper** — Hindi/Marathi/Tamil/etc. read badly or not at all.
3. **Doesn't work in some PDFs** — silent on scanned books.

All three trace to specific, fixable causes in the current implementation.

## Root cause (current code)

The pipeline is: `pdfrx` text-layer extraction → sentence chunking → `flutter_tts` → the phone's **OS-native TTS engine** (offline, no keys — a deliberate design choice).

| Complaint | Cause | Location |
|---|---|---|
| Robotic voice | Engine never selects a high-quality voice; uses the OS default. Never calls `getVoices`/`setVoice`. | `lib/services/tts_service.dart:30-32` |
| Bad Indian accents | Language is **hardcoded to `en-US`** and never changes. Non-English pages are read with a US-English voice → mangled/skipped. No language detection, no voice picker. | `lib/services/tts_service.dart:30`; `lib/models/app_settings.dart` (only stores `speechRate`) |
| Fails on some PDFs | Only reads the embedded **text layer**. Scanned PDFs (page images) have none → empty → after 8 blank pages → "unavailable". No OCR fallback. | `lib/services/pdf_service.dart:134-148`; `lib/providers/read_aloud_controller.dart:74,205-215` |

## Constraints (decided)

- **100% free, offline, open-source.** No paid/cloud APIs.
- **Users download voices/language data on demand.**
- **Commercial app** → cannot use non-commercial-licensed models (rules out MMS-TTS and the popular Piper Hindi voice, both CC-BY-NC).
- **Languages:** Hindi, English, South Indian (Tamil, Telugu, Kannada, Malayalam), other Indic (**Marathi**, Bengali, Gujarati, Punjabi, Odia, Assamese).

## Research summary — what's actually viable (free + offline + commercial)

### Voice engines

| Option | Indic coverage | Android | iOS | Commercial-safe? | Notes |
|---|---|---|---|---|---|
| **OS voices** via `flutter_tts` | ~8 Indic on Android (incl. Hindi, **Marathi**, Bengali, Tamil, Telugu, Kannada, Malayalam, Gujarati); **iOS = Hindi only** | ✅ good | ⚠️ Hindi only | ✅ (uses the user's installed OS voices) | Free, zero bundle, downloadable via OS. The hard ceiling is iOS. |
| **sherpa-onnx** + **AI4Bharat `vits_rasa_13`** | 13 Indic (incl. all target langs + Marathi) | ✅ | ✅ | ✅ **CC-BY-4.0** (attribution required) | Apache-2.0 neural runtime, official Flutter pkg, ONNX models downloadable per-language. **No official ONNX — we convert it ourselves.** Verify training-data terms before ship. |
| sherpa-onnx + **Piper** | Hindi, Telugu, Malayalam only | ✅ | ✅ | ⚠️ per-voice (Hindi voice is NC — avoid) | Lower effort but partial coverage. |
| sherpa-onnx + **Kokoro-82M** | Hindi (alpha) | ✅ | ✅ | ✅ Apache-2.0 | Hindi backup. |
| sherpa-onnx + **MMS-TTS** | all 11 | ✅ | ✅ | ❌ **CC-BY-NC** | Excluded (commercial app). |
| **eSpeak-NG** | all 11 | ✅ | — | ⚠️ GPLv3 | Robotic; last-resort intelligibility only. |

**Takeaway:** `flutter_tts` (done right) is the free baseline and is enough on Android. The genuinely natural, full-coverage, both-platform path is **sherpa-onnx + AI4Bharat `vits_rasa_13`** — it's also the only way to get **any** South-Indian or Marathi voice on iOS.

### OCR (for scanned PDFs)

| Option | Coverage | Android | iOS | License | Notes |
|---|---|---|---|---|---|
| **ML Kit Text Recognition** | Devanagari (**Hindi, Marathi**) + Latin (English) | ✅ | ✅ | free, on-device | Best accuracy + most reliable integration. |
| **Tesseract** (`flutter_tesseract_ocr`) | **all 12** incl. Tamil/Telugu/Kannada/Malayalam/Bengali/Gujarati/Punjabi/Odia/Assamese | ✅ | ⚠️ fragile (SwiftyTesseract unmaintained) | Apache-2.0 | Per-language `.traineddata` download, 1–15 MB each. Weaker on complex South-Indian scripts. |

**Takeaway:** hybrid — **ML Kit for Hindi/Marathi/English**, **Tesseract for the rest**, with per-language data downloaded on demand.

## Target architecture

```
ReadAloudController
   └─ TtsEngine (abstraction)
        ├─ OsTtsEngine        (flutter_tts; default; per-language voice selection)
        └─ NeuralTtsEngine    (sherpa-onnx; downloaded ONNX voices; iOS Indic + quality)
   └─ text source
        ├─ PdfService.extractPageText      (text layer; pdfrx)
        └─ OcrService (fallback when empty)
             ├─ MlKitOcr     (Devanagari + Latin)
             └─ TesseractOcr (other Indic; downloadable traineddata)
   └─ LanguageDetector (Unicode-block → script → BCP-47 + ISO-639-3)
   └─ AssetManager (download + cache neural voices and OCR traineddata)
```

Voice resolution per language (fallback chain): **selected neural voice (if downloaded) → best offline OS voice → any OS voice → prompt to download**. On iOS, default the South-Indian languages + Marathi to neural (no OS voice exists).

## Phased delivery

### Phase 1 — Fix the OS-voice path *(free, ships first; fixes complaints #1 and #2 on Android)*
- `TtsService`: drop the hardcoded `en-US`; add `setLanguageForText()` (detect script), `getVoices` → pick highest-`quality`, `network_required=false` voice → `setVoice`; on Android prefer the Google TTS engine via `getEngines`/`setEngine`.
- `ReadAloudController`: detect language per page (per chunk for mixed pages) and set it before speaking.
- `AppSettings`: add per-language preferred voice + chosen language.
- **Settings → Voices screen** (new): list languages, show installed/quality, an **Install voices** button that fires Android `INSTALL_TTS_DATA` / `TTS_SETTINGS` intents (via a small platform channel); on iOS, guidance to Settings → Accessibility → Spoken Content.
- `LanguageDetector` util (Unicode blocks: Devanagari = Hindi/**Marathi**, Tamil, Telugu, Kannada, Malayalam, Bengali, Gujarati, Gurmukhi, Odia).

*Deliver:* Indian languages actually get spoken on Android; voice quality jumps from default to best-installed.

### Phase 2 — OCR for scanned PDFs *(fixes complaint #3)*
**Status: ML Kit shipped (Hindi/Marathi/English). Tesseract (other Indic) pending.**
- ✅ `OcrService` (`lib/services/ocr_service.dart`): renders the page and runs ML
  Kit Latin + Devanagari recognizers, keeping the longer result; FIFO-cached per
  `file#page`. Free, offline, models download on demand.
- ✅ `ReadAloudController`: when `extractPageText` is empty and "Read scanned
  books" is on, it OCRs the page (status shows "Scanning…"), then language is
  detected from the OCR'd text so the right voice is used. The give-up path now
  tells the user whether OCR is on.
- ✅ `readScannedBooks` setting (default on) + Settings toggle. Requires iOS 15.5+
  (deployment target bumped).
- ⏳ **Tesseract engine** for Tamil/Telugu/Kannada/Malayalam/Bengali/Gujarati/
  Punjabi/Odia/Assamese scanned books — `flutter_tesseract_ocr` with per-language
  downloadable traineddata. Needs on-device validation (iOS SwiftyTesseract is
  fragile). Slot it behind the same `OcrService` as a second engine.

*Deliver:* scanned Hindi/Marathi/English books read aloud now; remaining Indic
scripts after the Tesseract addition.

### Phase 3 — Neural downloadable voices via sherpa-onnx *(fixes #1/#2 on iOS + raises quality everywhere)*
- Add `sherpa_onnx`; introduce the `TtsEngine` abstraction and `NeuralTtsEngine`.
- **Convert AI4Bharat `vits_rasa_13` to ONNX** (one-time tooling task; host the per-language model files for in-app download). Add Piper (Telugu/Malayalam) / Kokoro (Hindi) as lighter alternates where licensing is clean.
- `AssetManager`: per-language neural-voice download + cache; wire into the Voices screen.
- iOS: default South-Indian languages + Marathi to neural.
- Add an in-app **attribution/licenses** screen (CC-BY-4.0 requires it).

*Deliver:* natural voices on both platforms; full Indic coverage on iOS.

> **Scope note:** if your audience is mostly Android, **Phase 1 + 2 may be sufficient** (Android OS voices already cover Marathi, Hindi, and the South-Indian languages for free). Phase 3 is required mainly for iOS Indic support and a consistent, non-robotic voice across devices.

## Honest caveats
- **iOS** has no OS voice for any Indic language except Hindi — Phase 3 (neural) is the only free fix there.
- **Tesseract** South-Indian accuracy is mediocre (vowel-sign ordering); mis-OCR → mis-pronunciation. Test per language; ML Kit handles Marathi/Hindi well.
- **`vits_rasa_13` needs ONNX conversion** — the main engineering cost of Phase 3; budget for it and verify the model + training-data license before shipping a paid app.
- Each downloadable voice/OCR pack needs UX for download/progress/failure and storage management.

## Open questions
- Primary platform split (Android-heavy → Phase 3 optional)?
- Acceptable per-language download sizes (OS packs vary; neural ≈ 20–60 MB; Tesseract 1–15 MB)?
- Where to host the converted neural voice files for in-app download?
