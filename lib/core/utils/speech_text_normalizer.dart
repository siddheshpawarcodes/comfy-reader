/// Flattens raw extracted text (PDF text layer or OCR) into a clause that
/// reads naturally aloud: stitches hyphenated line breaks, turns layout
/// newlines into spaces, strips links, repairs words that font metrics or
/// OCR split into individual characters (common with justified text and
/// Indic matras), and collapses whitespace runs. Sentence punctuation is
/// preserved so the read-aloud controller can still chunk on it.
String normalizeForSpeech(String raw) {
  final cleaned = raw
      .replaceAll('\r\n', '\n')
      .replaceAll(RegExp(r'-\n'), '') // join hyphenated wrap: "exam-\nple"
      .replaceAll('\n', ' ')
      .replaceAll(_linkPattern, ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return _mergeLetterSpacedRuns(cleaned);
}

/// Matches http(s) and www.-prefixed links so they can be dropped before
/// speech: reading a URL aloud character-by-character is unusable.
final RegExp _linkPattern = RegExp(r'(?:https?://|www\.)\S+', caseSensitive: false);

/// Some PDFs (especially justified text and Indic scripts with matras) and
/// some OCR results extract with a stray space after every glyph, so words
/// read one letter at a time instead of as whole words. Any run of 3+
/// consecutive single-character "words" is almost never real text, so glue
/// it back into one word.
String _mergeLetterSpacedRuns(String text) {
  final tokens = text.split(' ');
  final out = StringBuffer();
  var i = 0;
  while (i < tokens.length) {
    var j = i;
    while (j < tokens.length && tokens[j].runes.length == 1) {
      j++;
    }
    if (out.isNotEmpty) out.write(' ');
    if (j - i >= 3) {
      out.write(tokens.sublist(i, j).join());
      i = j;
    } else {
      out.write(tokens[i]);
      i++;
    }
  }
  return out.toString();
}
