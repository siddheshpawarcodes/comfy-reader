# Read-aloud: reconstruct missing spaces between glued words (pending)

**Status:** Pending — not yet implemented.
**Area:** Read-aloud text extraction (`PdfService.extractPageText`).

## Context

The user reported that read-aloud text extracted from PDFs sometimes reads garbled: words/matras
get joined incorrectly instead of joined at the word level, and links get read aloud character by
character.

## What's already done (2026-07-02)

Shipped in `lib/core/utils/speech_text_normalizer.dart` (shared by `PdfService.extractPageText`
and `OcrService`):
- Strips `http(s)://` and `www.`-prefixed links before speech.
- Repairs "letter-spaced" runs: when a PDF's font metrics (or OCR) cause every glyph to extract
  with a stray space around it, words get read one letter/matra at a time (e.g. Devanagari
  `न म स ् त े` instead of `नमस्ते`). Any run of 3+ consecutive single-character tokens is glued
  back into one word.
- Covered by `test/speech_text_normalizer_test.dart`.

## What's still pending

The fix above only repairs text that has **extra, spurious spaces**. It does not handle the
opposite failure: text that is **genuinely missing a space** where two separate words/cells were
extracted with zero separator (e.g. two table columns or two PDF text runs glued together into one
nonsense word, like `PriceItem`). That case wasn't confirmed to exist yet in real content the user
hit — only diagnosed as a theoretical gap.

## Proposed approach (not started)

`pdfrx`'s raw `loadText()` (`lib/services/pdf_service.dart`) already returns per-character bounding
boxes (`PdfPageRawText.charRects`) alongside `fullText`. To detect a truly-missing space:
1. Walk consecutive characters in `fullText` using their `charRects`.
2. If two adjacent characters are on the same line (vertical overlap) but the horizontal gap
   between `charRects[i].right` and `charRects[i+1].left` exceeds a threshold relative to normal
   character advance width, insert a space.
3. Needs a real garbled PDF sample to tune the threshold safely — too aggressive risks introducing
   *new* mid-word splits (regression of the bug this enhancement fixes).

## Trigger to pick this up

Reopen when the user hits/reports a case of two real words glued together with **no space at
all** (as opposed to the letter-spacing issue, which is already fixed).
