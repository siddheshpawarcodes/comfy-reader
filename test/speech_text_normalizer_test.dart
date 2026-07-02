import 'package:comfy_reader/core/utils/speech_text_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeForSpeech', () {
    test('joins hyphenated line-wrap words', () {
      expect(normalizeForSpeech('exam-\nple'), 'example');
    });

    test('turns layout newlines into spaces and collapses whitespace', () {
      expect(normalizeForSpeech('Hello\nworld.   Again.'), 'Hello world. Again.');
    });

    test('strips http(s) and www links entirely', () {
      expect(
        normalizeForSpeech('Visit https://example.com/path?x=1 for more, or www.foo.org too.'),
        'Visit for more, or too.',
      );
    });

    test('repairs letter-spaced runs from font-metric artifacts', () {
      expect(normalizeForSpeech('H e l l o world'), 'Hello world');
    });

    test('repairs Devanagari matras split into single-character tokens', () {
      expect(normalizeForSpeech('न म स ् त े दुनिया'), 'नमस्ते दुनिया');
    });

    test('does not merge short real words', () {
      expect(normalizeForSpeech('I am a cat'), 'I am a cat');
    });
  });
}
