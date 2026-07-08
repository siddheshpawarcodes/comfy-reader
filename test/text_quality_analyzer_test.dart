import 'package:comfy_reader/services/text_quality_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const threshold = TextQualityAnalyzer.qualityThreshold;

  // The exact strings from the bug report.
  const cleanMarathi =
      'युनिकोडाचा वापर करून मराठीत अक्षरजुळणी शक्य आहे, परंतु सुलभ नाही.';
  const corruptMarathi =
      'युࣺनकोडाचा वापर करून मराठीत अक्षरजुळणी शѺ आहे, परंतु सुलभ नाहࣚ.';

  group('clean text scores high (no OCR)', () {
    test('clean Marathi is acceptable', () {
      final report = TextQualityAnalyzer.analyze(cleanMarathi);
      expect(report.score, greaterThanOrEqualTo(threshold));
      expect(report.isAcceptable(threshold), isTrue);
      expect(report.suspiciousCharacterPercentage, 0);
      expect(report.replacementCharacterCount, 0);
      expect(report.dominantScript, AnalyzedScript.devanagari);
      expect(report.devanagariPercentage, greaterThan(0.9));
    });

    test('plain English is perfect', () {
      final report = TextQualityAnalyzer.analyze(
        'The quick brown fox jumps over the lazy dog, again and again.',
      );
      expect(report.score, 1.0);
      expect(report.dominantScript, AnalyzedScript.latin);
    });

    test('bilingual Hindi + English is not false-positived', () {
      final report = TextQualityAnalyzer.analyze(
        'This chapter (अध्याय) explains युनिकोड and Unicode fonts in detail.',
      );
      expect(report.isAcceptable(threshold), isTrue);
      expect(report.suspiciousCharacterPercentage, 0);
    });

    test('a lone stray foreign glyph does not trip the gate', () {
      // One suspicious char in a long clean paragraph stays acceptable.
      final report = TextQualityAnalyzer.analyze(
        'मराठी भाषा ही भारतातील एक प्रमुख भाषा आहे आणि ती महाराष्ट्रात '
        'बोलली जाते Ѻ आणि तिचा वापर साहित्यात मोठ्या प्रमाणात केला जातो.',
      );
      expect(report.suspiciousCharacterPercentage, greaterThan(0));
      expect(report.isAcceptable(threshold), isTrue);
    });
  });

  group('corrupt text scores low (routes to OCR)', () {
    test('corrupt Marathi is below threshold', () {
      final report = TextQualityAnalyzer.analyze(corruptMarathi);
      expect(report.score, lessThan(threshold));
      expect(report.isAcceptable(threshold), isFalse);
      expect(report.suspiciousCharacterPercentage, greaterThan(0));
      expect(report.dominantScript, AnalyzedScript.devanagari);
    });

    test('corrupt scores strictly worse than clean', () {
      expect(
        TextQualityAnalyzer.calculateQualityScore(corruptMarathi),
        lessThan(TextQualityAnalyzer.calculateQualityScore(cleanMarathi)),
      );
    });

    test('each reported corruption glyph is flagged as suspicious', () {
      // ࣺ ࣚ Ѻ ߰ ي ؜ ۚ — Arabic/Syriac/N'Ko/Cyrillic blocks in Devanagari.
      const glyphs = ['ࣺ', 'ࣚ', 'Ѻ', '߰', 'ي', '؜', 'ۚ'];
      for (final g in glyphs) {
        final report = TextQualityAnalyzer.analyze(
          'मराठी भाषा$g मराठी भाषा मराठी भाषा',
        );
        expect(report.suspiciousCharacterPercentage, greaterThan(0),
            reason: 'glyph "$g" (U+${g.runes.first.toRadixString(16)}) '
                'should be suspicious');
      }
    });

    test('heavy foreign-block contamination scores near zero', () {
      final report = TextQualityAnalyzer.analyze(
        'شࣺاشࣚشѺش مराठी شࣺاشࣚشѺش भाषा شࣺاشࣚشѺش',
      );
      expect(report.score, lessThan(0.2));
    });

    test('replacement characters tank the score', () {
      final report = TextQualityAnalyzer.analyze(
        'This text has � several � broken � glyphs � here.',
      );
      expect(report.replacementCharacterCount, 4);
      expect(report.isAcceptable(threshold), isFalse);
    });
  });

  group('edge cases', () {
    test('empty / whitespace-only text is acceptable (nothing to repair)', () {
      expect(TextQualityAnalyzer.analyze('').isAcceptable(threshold), isTrue);
      expect(TextQualityAnalyzer.analyze('   \n\t ').score, 1.0);
      expect(TextQualityAnalyzer.analyze('').dominantScript, AnalyzedScript.none);
    });

    test('digits and punctuation only are acceptable', () {
      final report = TextQualityAnalyzer.analyze('12, 34. 56! (78) — 90?');
      expect(report.isAcceptable(threshold), isTrue);
    });

    test('too little text to judge is accepted (avoids needless OCR)', () {
      // Below the min-letters floor even a suspicious glyph is tolerated.
      final report = TextQualityAnalyzer.analyze('कॗ Ѻ');
      expect(report.isAcceptable(threshold), isTrue);
    });

    test('a whole-page legit non-target script (Arabic) is flagged', () {
      // The app targets English + Indic; sustained Arabic is out of domain and
      // the spec asks us to detect Arabic blocks.
      final report = TextQualityAnalyzer.analyze(
        'هذا نص عربي طويل جدا يحتوي على العديد من الكلمات والحروف المختلفة هنا',
      );
      expect(report.isAcceptable(threshold), isFalse);
    });

    test('threshold override: 0 disables the gate', () {
      final report = TextQualityAnalyzer.analyze(corruptMarathi);
      expect(report.isAcceptable(0), isTrue);
    });
  });
}
