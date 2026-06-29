/// Lightweight, offline script/language detection for read-aloud.
///
/// The OS TTS engine must be told which language a page is in, or it reads
/// non-Latin text with the wrong (usually English) voice — which is why Indian
/// languages came out garbled. We can't ship a full language classifier, but a
/// page's *script* is unambiguous from its Unicode code points, and for our
/// target languages script maps cleanly to a language.
///
/// The one ambiguity is Devanagari, shared by Hindi and Marathi; the caller
/// resolves that via a user preference (see [languageFor]).
library;

/// A script we can detect, with the TTS locale, display name, and ISO 639-3
/// code (the last is for the OCR phase) it maps to.
enum ReadingScript {
  latin('en-US', 'English', 'eng'),
  devanagari('hi-IN', 'Hindi', 'hin'), // also Marathi — see [languageFor]
  bengali('bn-IN', 'Bengali', 'ben'),
  gujarati('gu-IN', 'Gujarati', 'guj'),
  gurmukhi('pa-IN', 'Punjabi', 'pan'),
  oriya('or-IN', 'Odia', 'ori'),
  tamil('ta-IN', 'Tamil', 'tam'),
  telugu('te-IN', 'Telugu', 'tel'),
  kannada('kn-IN', 'Kannada', 'kan'),
  malayalam('ml-IN', 'Malayalam', 'mal'),
  unknown('en-US', 'Unknown', 'eng');

  const ReadingScript(this.defaultLanguage, this.label, this.iso639_3);

  /// BCP-47 tag to pass to `setLanguage` (e.g. `hi-IN`).
  final String defaultLanguage;

  /// Human-readable language name for settings UI.
  final String label;

  /// ISO 639-3 code — used to pick OCR traineddata in the OCR phase.
  final String iso639_3;
}

/// Detects the dominant script of [text] and resolves it to a TTS locale.
abstract final class LanguageDetector {
  /// Returns the script with the most letters in [text], ignoring digits,
  /// whitespace, and punctuation. [ReadingScript.unknown] if no letters match.
  static ReadingScript detect(String text) {
    final counts = <ReadingScript, int>{};
    for (final rune in text.runes) {
      final script = _scriptOf(rune);
      if (script == null) continue;
      counts[script] = (counts[script] ?? 0) + 1;
    }
    if (counts.isEmpty) return ReadingScript.unknown;
    return counts.entries
        .reduce((a, b) => b.value > a.value ? b : a)
        .key;
  }

  /// The BCP-47 locale to speak [script] in. Devanagari resolves to Marathi
  /// (`mr-IN`) when [devanagariIsMarathi] is set, otherwise Hindi.
  static String languageFor(
    ReadingScript script, {
    bool devanagariIsMarathi = false,
  }) {
    if (script == ReadingScript.devanagari && devanagariIsMarathi) {
      return 'mr-IN';
    }
    return script.defaultLanguage;
  }

  /// Maps a single code point to its script, or null for non-letters and
  /// scripts we don't target.
  static ReadingScript? _scriptOf(int r) {
    // Indic blocks (each is a contiguous 128-point range).
    if (r >= 0x0900 && r <= 0x097F) return ReadingScript.devanagari;
    if (r >= 0x0980 && r <= 0x09FF) return ReadingScript.bengali;
    if (r >= 0x0A00 && r <= 0x0A7F) return ReadingScript.gurmukhi;
    if (r >= 0x0A80 && r <= 0x0AFF) return ReadingScript.gujarati;
    if (r >= 0x0B00 && r <= 0x0B7F) return ReadingScript.oriya;
    if (r >= 0x0B80 && r <= 0x0BFF) return ReadingScript.tamil;
    if (r >= 0x0C00 && r <= 0x0C7F) return ReadingScript.telugu;
    if (r >= 0x0C80 && r <= 0x0CFF) return ReadingScript.kannada;
    if (r >= 0x0D00 && r <= 0x0D7F) return ReadingScript.malayalam;
    // Latin: A–Z, a–z, plus Latin-1 Supplement + Extended-A accents.
    if ((r >= 0x0041 && r <= 0x005A) ||
        (r >= 0x0061 && r <= 0x007A) ||
        (r >= 0x00C0 && r <= 0x024F)) {
      return ReadingScript.latin;
    }
    return null; // digits, punctuation, whitespace, symbols
  }
}
