import 'dart:io';
import 'dart:ui' show Size;

import 'package:flutter/foundation.dart';
// pdfrx is used ONLY for text extraction (read-aloud). It collides with pdfx on
// `PdfDocument`/`PdfPage`, so it's prefixed; pdfx remains the renderer.
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import 'package:pdfx/pdfx.dart';

import '../core/utils/app_log.dart';
import '../core/utils/app_paths.dart';
import '../models/book_model.dart';

/// Outcome of probing whether a PDF can be opened for reading.
enum PdfOpenResult { ok, missing, protected, corrupt }

/// Result of [PdfService.probe]: whether the doc opened and (if ok) its pages.
@immutable
class PdfProbe {
  const PdfProbe(this.result, this.pages);

  final PdfOpenResult result;
  final int pages;

  bool get ok => result == PdfOpenResult.ok;
}

/// The single boundary for all PDF rasterization (swappable to `pdfrx`).
///
/// Documents are opened short-lived (open → render → close) to bound native
/// memory; the in-memory image cache (Reader, Phase 4) handles reuse.
class PdfService {
  const PdfService();

  /// Probes whether [path] can be opened for reading, distinguishing a missing
  /// file, a password-protected PDF (out of scope for v1), and a corrupt/
  /// unreadable one. Cheap (open → read count → close), no rendering.
  Future<PdfProbe> probe(String path) async {
    if (!await File(path).exists()) {
      return const PdfProbe(PdfOpenResult.missing, 0);
    }
    PdfDocument? doc;
    try {
      doc = await PdfDocument.openFile(path);
      final count = doc.pagesCount;
      if (count <= 0) return const PdfProbe(PdfOpenResult.corrupt, 0);
      return PdfProbe(PdfOpenResult.ok, count);
    } catch (e, st) {
      final msg = e.toString().toLowerCase();
      final protected = msg.contains('password') ||
          msg.contains('encrypt') ||
          msg.contains('security');
      AppLog.warning('probe failed for $path',
          name: 'PdfService', error: e, stackTrace: st);
      return PdfProbe(
        protected ? PdfOpenResult.protected : PdfOpenResult.corrupt,
        0,
      );
    } finally {
      await doc?.close();
    }
  }

  /// Number of pages, or 0 on failure.
  Future<int> pageCount(String path) async {
    PdfDocument? doc;
    try {
      doc = await PdfDocument.openFile(path);
      return doc.pagesCount;
    } catch (e, st) {
      AppLog.warning('pageCount failed for $path',
          name: 'PdfService', error: e, stackTrace: st);
      return 0;
    } finally {
      await doc?.close();
    }
  }

  /// Dimensions (in PDF points) of the first page — used as a flipbook size
  /// hint. Returns a sane default on failure.
  Future<Size> firstPageSize(String path) async {
    PdfDocument? doc;
    PdfPage? page;
    try {
      doc = await PdfDocument.openFile(path);
      page = await doc.getPage(1);
      return Size(page.width, page.height);
    } catch (e, st) {
      AppLog.warning('firstPageSize failed for $path',
          name: 'PdfService', error: e, stackTrace: st);
      return const Size(1000, 1414); // A-series-ish fallback
    } finally {
      await page?.close();
      await doc?.close();
    }
  }

  /// Renders [pageIndex] (0-based) to PNG bytes at [targetWidth] (logical px
  /// × DPR). Returns null on failure.
  Future<Uint8List?> renderPage(
    String path,
    int pageIndex, {
    required double targetWidth,
  }) async {
    PdfDocument? doc;
    PdfPage? page;
    try {
      doc = await PdfDocument.openFile(path);
      page = await doc.getPage(pageIndex + 1); // pdfx is 1-based
      final aspect = page.height / page.width;
      final width = targetWidth;
      final height = targetWidth * aspect;
      final image = await page.render(
        width: width,
        height: height,
        format: PdfPageImageFormat.png,
        backgroundColor: '#FFFFFF',
      );
      return image?.bytes;
    } catch (e, st) {
      AppLog.warning('renderPage($pageIndex) failed for $path',
          name: 'PdfService', error: e, stackTrace: st);
      return null;
    } finally {
      await page?.close();
      await doc?.close();
    }
  }

  /// Extracts the plain text of [pageIndex] (0-based) for read-aloud, using
  /// pdfrx (pdfx exposes no text layer). Returns an empty string when the page
  /// has no embedded text (e.g. a scanned image), or null on failure. Opened
  /// short-lived (open → read → dispose), matching [renderPage]'s discipline.
  Future<String?> extractPageText(String path, int pageIndex) async {
    pdfrx.PdfDocument? doc;
    try {
      doc = await pdfrx.PdfDocument.openFile(path);
      if (pageIndex < 0 || pageIndex >= doc.pages.length) return '';
      final raw = await doc.pages[pageIndex].loadText();
      return _normalizeForSpeech(raw?.fullText ?? '');
    } catch (e, st) {
      AppLog.warning('extractPageText($pageIndex) failed for $path',
          name: 'PdfService', error: e, stackTrace: st);
      return null;
    } finally {
      await doc?.dispose();
    }
  }

  /// Flattens a page's raw text into a clause that reads naturally aloud:
  /// stitches hyphenated line breaks, turns layout newlines into spaces, and
  /// collapses whitespace runs. Sentence punctuation is preserved so the
  /// read-aloud controller can still chunk on it.
  static String _normalizeForSpeech(String raw) {
    return raw
        .replaceAll('\r\n', '\n')
        .replaceAll(RegExp(r'-\n'), '') // join hyphenated wrap: "exam-\nple"
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Generates (or reuses) a cover for [book] from page 1. Returns the cover
  /// file path, or null on failure.
  Future<String?> generateCover(BookModel book, {double width = 600}) async {
    final file = File('${AppPaths.covers.path}/${book.id}.png');
    if (await file.exists()) return file.path;
    final bytes = await renderPage(book.filePath, 0, targetWidth: width);
    if (bytes == null) return null;
    try {
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e, st) {
      AppLog.warning('generateCover failed for ${book.id}',
          name: 'PdfService', error: e, stackTrace: st);
      return null;
    }
  }
}
