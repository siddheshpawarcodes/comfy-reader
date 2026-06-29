import 'package:comfy_reader/core/utils/language_detector.dart';
import 'package:comfy_reader/models/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LanguageDetector.detect', () {
    test('plain English is Latin', () {
      expect(LanguageDetector.detect('Hello, world.'), ReadingScript.latin);
    });

    test('Hindi/Marathi text is Devanagari', () {
      expect(LanguageDetector.detect('नमस्ते दुनिया'), ReadingScript.devanagari);
    });

    test('Tamil, Telugu, Kannada, Malayalam scripts', () {
      expect(LanguageDetector.detect('வணக்கம்'), ReadingScript.tamil);
      expect(LanguageDetector.detect('నమస్కారం'), ReadingScript.telugu);
      expect(LanguageDetector.detect('ನಮಸ್ಕಾರ'), ReadingScript.kannada);
      expect(LanguageDetector.detect('നമസ്കാരം'), ReadingScript.malayalam);
    });

    test('picks the dominant script when mixed with a little English', () {
      // A mostly-Hindi line with an English page number shouldn't flip to Latin.
      expect(
        LanguageDetector.detect('यह एक लंबा हिंदी वाक्य है। p. 12'),
        ReadingScript.devanagari,
      );
    });

    test('digits/punctuation/whitespace only is unknown', () {
      expect(LanguageDetector.detect('  123 — 45.6 '), ReadingScript.unknown);
    });
  });

  group('LanguageDetector.languageFor', () {
    test('Devanagari resolves to Hindi by default, Marathi on request', () {
      expect(
        LanguageDetector.languageFor(ReadingScript.devanagari),
        'hi-IN',
      );
      expect(
        LanguageDetector.languageFor(ReadingScript.devanagari,
            devanagariIsMarathi: true),
        'mr-IN',
      );
    });

    test('non-Devanagari scripts ignore the Marathi flag', () {
      expect(
        LanguageDetector.languageFor(ReadingScript.tamil,
            devanagariIsMarathi: true),
        'ta-IN',
      );
    });
  });

  test('AppSettings round-trips the new read-aloud voice fields', () {
    const settings = AppSettings(
      autoDetectLanguage: false,
      devanagariLanguage: 'mr-IN',
      voiceByLanguage: {'hi-IN': 'hi-in-x-hia-local', 'ta-IN': 'ta-in-x-tac'},
    );

    final restored = AppSettings.fromMap(settings.toMap());

    expect(restored, settings);
    expect(restored.autoDetectLanguage, false);
    expect(restored.devanagariLanguage, 'mr-IN');
    expect(restored.voiceByLanguage['ta-IN'], 'ta-in-x-tac');
  });
}
