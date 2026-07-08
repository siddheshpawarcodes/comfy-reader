import 'package:flutter/foundation.dart';

/// Diagnostic report produced by [TextQualityAnalyzer.analyze].
///
/// All ratios are in `[0, 1]`. [score] is the single number the pipeline gates
/// on; the individual metrics exist for logging, tuning, and tests.
@immutable
class TextQualityReport {
  const TextQualityReport({
    required this.score,
    required this.letterCount,
    required this.dominantScript,
    required this.dominantScriptPercentage,
    required this.devanagariPercentage,
    required this.suspiciousCharacterPercentage,
    required this.replacementCharacterCount,
    required this.malformedCombiningCount,
    required this.whitespaceRatio,
  });

  /// A page with no analyzable letters (blank, or pure punctuation/whitespace).
  /// Scored as perfect so it is never sent to OCR — there is nothing to repair.
  static const TextQualityReport empty = TextQualityReport(
    score: 1.0,
    letterCount: 0,
    dominantScript: AnalyzedScript.none,
    dominantScriptPercentage: 0,
    devanagariPercentage: 0,
    suspiciousCharacterPercentage: 0,
    replacementCharacterCount: 0,
    malformedCombiningCount: 0,
    whitespaceRatio: 0,
  );

  /// Overall quality in `[0, 1]`; `1.0` = clean, `0.0` = unusable.
  final double score;

  /// Number of letter-like runes analyzed (excludes digits/punctuation/space).
  final int letterCount;

  /// The dominant *target* script (Latin or one of the Indic scripts), or
  /// [AnalyzedScript.none] when the page has no target-language letters.
  final AnalyzedScript dominantScript;

  /// Fraction of letters belonging to [dominantScript].
  final double dominantScriptPercentage;

  /// Fraction of letters that are Devanagari (called out by name because it is
  /// the primary corruption target for Hindi/Marathi/Sanskrit).
  final double devanagariPercentage;

  /// Fraction of letters from out-of-domain, corruption-prone Unicode blocks
  /// (Arabic, Syriac, N'Ko, Cyrillic, Greek, presentation forms, private use,
  /// specials …) that are *not* the dominant script — the primary corruption
  /// signal for a broken `ToUnicode` CMap.
  final double suspiciousCharacterPercentage;

  /// Count of Unicode replacement characters (`U+FFFD`) and object-replacement
  /// characters (`U+FFFC`) — a hard sign the decoder gave up on a glyph.
  final int replacementCharacterCount;

  /// Count of Indic combining marks (matras/signs) that appear with no valid
  /// preceding base letter, or in over-long stacks — malformed Indic shaping.
  final int malformedCombiningCount;

  /// Fraction of the raw string (all runes) that is whitespace.
  final double whitespaceRatio;

  /// Whether this text is good enough to speak directly (no OCR fallback).
  bool isAcceptable(double threshold) => score >= threshold;

  @override
  String toString() => 'TextQualityReport('
      'score: ${score.toStringAsFixed(2)}, '
      'letters: $letterCount, '
      'dominant: ${dominantScript.name} '
      '${(dominantScriptPercentage * 100).toStringAsFixed(0)}%, '
      'suspicious: ${(suspiciousCharacterPercentage * 100).toStringAsFixed(1)}%, '
      'replacement: $replacementCharacterCount, '
      'malformedCombining: $malformedCombiningCount)';
}

/// The target scripts the analyzer distinguishes, plus a `none` sentinel.
enum AnalyzedScript {
  none,
  latin,
  devanagari,
  bengali,
  gurmukhi,
  gujarati,
  oriya,
  tamil,
  telugu,
  kannada,
  malayalam,
}

/// Scores the *quality* of text extracted from a PDF so the read-aloud pipeline
/// can decide whether to speak it or fall back to OCR.
///
/// The corruption we target comes from PDFs whose embedded CID fonts have a
/// broken or missing `ToUnicode` CMap: PDFium renders the glyphs correctly (the
/// page looks fine) but extraction maps glyph ids to the *wrong* Unicode code
/// points — typically scattered Arabic / Syriac / Cyrillic / N'Ko letters and
/// combining marks dropped into otherwise-correct Devanagari (e.g. `शѺ`, `नाहࣚ`).
///
/// The analysis is entirely **script-property based** — it reasons about which
/// Unicode blocks a page's letters fall into, never about specific characters.
/// There are no per-PDF replacement maps and nothing to maintain per document.
///
/// The rule set:
///  * A letter is *suspicious* when it comes from a corruption-prone, out-of-
///    domain block (Arabic, Syriac, N'Ko, Thaana, Cyrillic, Greek, Hebrew,
///    Armenian, presentation forms, private-use, specials) **and** that block
///    is not the page's dominant script. The second clause means a page that is
///    legitimately, wholly Arabic is *not* flagged (OCR could not improve it),
///    while a few Arabic glyphs inside a Devanagari page are.
///  * Latin and all ten target Indic scripts are in-domain and never suspicious,
///    so bilingual (e.g. Hindi + English) pages are not false-positived.
///  * Replacement characters (`U+FFFD`/`U+FFFC`) are counted directly.
///  * Indic combining marks with no base letter, or in stacks longer than
///    [_maxCombiningRun], count as malformed shaping.
///
/// The composite [calculateQualityScore] starts at `1.0` and subtracts weighted
/// penalties; clean text scores `1.0`, the corruption examples score well below
/// [qualityThreshold].
abstract final class TextQualityAnalyzer {
  /// Text scoring at or above this is spoken as-is; below it, the pipeline runs
  /// OCR and keeps whichever result scores higher.
  static const double qualityThreshold = 0.85;

  /// Below this many analyzable letters the signal is too thin to trust, so we
  /// accept the text rather than pay for OCR on a near-empty page.
  static const int _minLettersForVerdict = 12;

  /// Real Devanagari/Indic clusters rarely stack more than two dependent signs;
  /// a longer run is a shaping artifact.
  static const int _maxCombiningRun = 3;

  // Penalty weights. Each term is `clamp(metric * gain, 0, 1) * weight`; the
  // weighted penalties are summed and subtracted from 1.0. Tuned so that clean
  // native text stays at 1.0, a lone stray glyph barely dents the score, and a
  // few-percent scatter of foreign glyphs (the real corruption signature) drops
  // below [qualityThreshold].
  static const double _suspiciousGain = 8.0;
  static const double _suspiciousWeight = 0.85;
  static const double _replacementGain = 20.0;
  static const double _replacementWeight = 0.50;
  static const double _malformedGain = 4.0;
  static const double _malformedWeight = 0.25;

  /// Convenience wrapper returning only the composite score.
  static double calculateQualityScore(String text) => analyze(text).score;

  /// Whether [text] is good enough to speak without OCR, at the default
  /// [qualityThreshold] (or an override).
  static bool isAcceptable(String text, {double? threshold}) =>
      analyze(text).isAcceptable(threshold ?? qualityThreshold);

  /// Full analysis of [text]. Runs a single O(n) pass over the runes.
  static TextQualityReport analyze(String text) {
    if (text.trim().isEmpty) return TextQualityReport.empty;

    final counts = <AnalyzedScript, int>{};
    var totalRunes = 0;
    var whitespace = 0;
    var suspicious = 0; // corruption-prone, out-of-domain letters
    var replacement = 0; // U+FFFD / U+FFFC
    var deva = 0;
    var letters = 0; // in-domain letters + suspicious letters

    // Combining-mark tracking for malformed-shaping detection.
    var malformedCombining = 0;
    var combiningRun = 0;
    var hasBaseForCluster = false;

    for (final rune in text.runes) {
      totalRunes++;

      if (rune == 0xFFFD || rune == 0xFFFC) {
        replacement++;
        combiningRun = 0;
        hasBaseForCluster = false;
        continue;
      }
      if (_isWhitespace(rune)) {
        whitespace++;
        combiningRun = 0;
        hasBaseForCluster = false;
        continue;
      }

      final script = _targetScriptOf(rune);
      if (script != null) {
        // In-domain letter (Latin or a target Indic script).
        counts[script] = (counts[script] ?? 0) + 1;
        letters++;
        if (script == AnalyzedScript.devanagari) deva++;

        if (_isIndicCombiningMark(rune)) {
          combiningRun++;
          if (!hasBaseForCluster || combiningRun >= _maxCombiningRun) {
            malformedCombining++;
          }
        } else {
          combiningRun = 0;
          hasBaseForCluster = true; // a base consonant/vowel/Latin letter
        }
        continue;
      }

      if (_isSuspicious(rune)) {
        suspicious++;
        letters++;
        // A foreign combining mark landing mid-cluster is itself malformed
        // shaping; but it is already counted as suspicious, so only the
        // orphan-base bookkeeping needs resetting here.
        combiningRun = 0;
        hasBaseForCluster = false;
        continue;
      }

      // Digits, punctuation, symbols, emoji: ignored, but they break a cluster.
      combiningRun = 0;
      hasBaseForCluster = false;
    }

    if (letters < _minLettersForVerdict) {
      // Not enough signal — treat as acceptable, but still report the metrics.
      return TextQualityReport(
        score: 1.0,
        letterCount: letters,
        dominantScript: _dominant(counts),
        dominantScriptPercentage:
            letters == 0 ? 0 : (counts[_dominant(counts)] ?? 0) / letters,
        devanagariPercentage: letters == 0 ? 0 : deva / letters,
        suspiciousCharacterPercentage: letters == 0 ? 0 : suspicious / letters,
        replacementCharacterCount: replacement,
        malformedCombiningCount: malformedCombining,
        whitespaceRatio: totalRunes == 0 ? 0 : whitespace / totalRunes,
      );
    }

    final dominant = _dominant(counts);
    final suspiciousRatio = suspicious / letters;
    final replacementRatio = replacement / letters;
    final malformedRatio = malformedCombining / letters;

    final penalty = _term(suspiciousRatio, _suspiciousGain, _suspiciousWeight) +
        _term(replacementRatio, _replacementGain, _replacementWeight) +
        _term(malformedRatio, _malformedGain, _malformedWeight);

    final score = (1.0 - penalty).clamp(0.0, 1.0);

    return TextQualityReport(
      score: score,
      letterCount: letters,
      dominantScript: dominant,
      dominantScriptPercentage: (counts[dominant] ?? 0) / letters,
      devanagariPercentage: deva / letters,
      suspiciousCharacterPercentage: suspiciousRatio,
      replacementCharacterCount: replacement,
      malformedCombiningCount: malformedCombining,
      whitespaceRatio: totalRunes == 0 ? 0 : whitespace / totalRunes,
    );
  }

  static double _term(double metric, double gain, double weight) =>
      (metric * gain).clamp(0.0, 1.0) * weight;

  /// The most frequent in-domain script, or [AnalyzedScript.none].
  static AnalyzedScript _dominant(Map<AnalyzedScript, int> counts) {
    if (counts.isEmpty) return AnalyzedScript.none;
    return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }

  static bool _isWhitespace(int r) =>
      r == 0x20 || // space
      r == 0x09 || // tab
      r == 0x0A || // LF
      r == 0x0D || // CR
      r == 0xA0 || // NBSP
      r == 0x200B || // zero-width space
      (r >= 0x2000 && r <= 0x200A) || // en/em spaces
      r == 0x3000; // ideographic space

  /// Maps a rune to an in-domain script (Latin or a target Indic script), or
  /// null if it is not an in-domain letter. Each Indic block is a contiguous
  /// 128-point range; the ranges mirror [LanguageDetector] plus the Vedic
  /// Extensions used by Sanskrit.
  static AnalyzedScript? _targetScriptOf(int r) {
    if (r >= 0x0900 && r <= 0x097F) return AnalyzedScript.devanagari;
    if (r >= 0x0980 && r <= 0x09FF) return AnalyzedScript.bengali;
    if (r >= 0x0A00 && r <= 0x0A7F) return AnalyzedScript.gurmukhi;
    if (r >= 0x0A80 && r <= 0x0AFF) return AnalyzedScript.gujarati;
    if (r >= 0x0B00 && r <= 0x0B7F) return AnalyzedScript.oriya;
    if (r >= 0x0B80 && r <= 0x0BFF) return AnalyzedScript.tamil;
    if (r >= 0x0C00 && r <= 0x0C7F) return AnalyzedScript.telugu;
    if (r >= 0x0C80 && r <= 0x0CFF) return AnalyzedScript.kannada;
    if (r >= 0x0D00 && r <= 0x0D7F) return AnalyzedScript.malayalam;
    // Devanagari Extended + Vedic Extensions (Sanskrit accents/marks).
    if (r >= 0xA8E0 && r <= 0xA8FF) return AnalyzedScript.devanagari;
    if (r >= 0x1CD0 && r <= 0x1CFF) return AnalyzedScript.devanagari;
    // Latin: ASCII letters + Latin-1 Supplement + Extended-A/B accents.
    if ((r >= 0x0041 && r <= 0x005A) ||
        (r >= 0x0061 && r <= 0x007A) ||
        (r >= 0x00C0 && r <= 0x024F)) {
      return AnalyzedScript.latin;
    }
    return null;
  }

  /// Whether [r] is a letter/mark from a corruption-prone, out-of-domain block.
  /// These blocks essentially never appear in English + Indic content, but are
  /// exactly what a broken `ToUnicode` CMap emits.
  static bool _isSuspicious(int r) {
    return (r >= 0x0370 && r <= 0x03FF) || // Greek and Coptic
        (r >= 0x0400 && r <= 0x052F) || // Cyrillic (+ Supplement)
        (r >= 0x0530 && r <= 0x058F) || // Armenian
        (r >= 0x0590 && r <= 0x05FF) || // Hebrew
        (r >= 0x0600 && r <= 0x06FF) || // Arabic
        (r >= 0x0700 && r <= 0x074F) || // Syriac
        (r >= 0x0750 && r <= 0x077F) || // Arabic Supplement
        (r >= 0x0780 && r <= 0x07BF) || // Thaana
        (r >= 0x07C0 && r <= 0x07FF) || // N'Ko
        (r >= 0x0800 && r <= 0x083F) || // Samaritan
        (r >= 0x0840 && r <= 0x085F) || // Mandaic
        (r >= 0x0860 && r <= 0x086F) || // Syriac Supplement
        (r >= 0x0870 && r <= 0x089F) || // Arabic Extended-B
        (r >= 0x08A0 && r <= 0x08FF) || // Arabic Extended-A
        (r >= 0xFB00 && r <= 0xFB4F) || // Alphabetic Presentation Forms
        (r >= 0xFB50 && r <= 0xFDFF) || // Arabic Presentation Forms-A
        (r >= 0xFE70 && r <= 0xFEFF) || // Arabic Presentation Forms-B
        (r >= 0xE000 && r <= 0xF8FF) || // Private Use Area
        (r >= 0xFFF0 && r <= 0xFFFF); // Specials (excl. FFFD, handled above)
  }

  /// Whether [r] is a Devanagari/Indic *dependent* sign — a matra, virama,
  /// anusvara, candrabindu, nukta, etc. — i.e. a combining mark that must
  /// follow a base letter. Covers the sign sub-ranges of the target scripts.
  static bool _isIndicCombiningMark(int r) {
    // Devanagari: candrabindu/anusvara/visarga (0900-0903), signs & matras
    // (093A-094F), nukta/accents (0951-0957), pluta/vocalic (0962-0963).
    if ((r >= 0x0900 && r <= 0x0903) ||
        (r >= 0x093A && r <= 0x094F) ||
        (r >= 0x0951 && r <= 0x0957) ||
        (r >= 0x0962 && r <= 0x0963)) {
      return true;
    }
    // The other Indic blocks share the same relative sign layout: the
    // low 0x00-0x03 (bindus/visarga) and roughly 0x3A-0x4F (matras/virama)
    // offsets within each 128-point block are dependent signs.
    const bases = <int>[
      0x0980, // Bengali
      0x0A00, // Gurmukhi
      0x0A80, // Gujarati
      0x0B00, // Oriya
      0x0B80, // Tamil
      0x0C00, // Telugu
      0x0C80, // Kannada
      0x0D00, // Malayalam
    ];
    for (final base in bases) {
      if (r >= base && r <= base + 0x7F) {
        final off = r - base;
        return (off >= 0x00 && off <= 0x03) || (off >= 0x3A && off <= 0x4F);
      }
    }
    return false;
  }
}
