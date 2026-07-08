import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../core/utils/app_log.dart';
import '../core/utils/speech_text_normalizer.dart';
import 'ocr_cache_service.dart';
import 'pdf_service.dart';

/// On-device OCR fallback for read-aloud on scanned PDFs — pages that have no
/// embedded text layer (so [PdfService.extractPageText] returns empty).
///
/// Renders the page to an image and recognizes it with ML Kit (free, offline,
/// no API keys). Covers Latin (English) and Devanagari (Hindi/Marathi); the
/// other Indic scripts need a different engine (Tesseract) and are a later
/// addition. A singleton, mirroring [TtsService]/[AudioService].
class OcrService {
  OcrService._();
  static final OcrService instance = OcrService._();

  // ML Kit recognizers are per-script and hold native resources; created lazily
  // and reused across pages. The model for a script downloads on first use
  // (Play Services on Android, bundled on iOS).
  TextRecognizer? _latin;
  TextRecognizer? _devanagari;

  /// Persistent, cross-session cache (injectable for tests).
  OcrCacheService _persistentCache = OcrCacheService.instance;

  /// Overrides the persistent cache (tests bind a temporary box).
  @visibleForTesting
  set persistentCache(OcrCacheService cache) => _persistentCache = cache;

  /// Width (px) to render a page for OCR — high enough for accuracy, bounded to
  /// keep recognition fast and memory sane.
  static const double _renderWidth = 2000;

  /// L1 per-session cache of recognized page text (FIFO-bounded), keyed by
  /// `file#page`, so pause/resume or revisiting a page doesn't re-run OCR. The
  /// persistent [OcrCacheService] is the L2 cache that survives restarts.
  static const int _cacheCap = 64;
  final Map<String, String> _cache = {};

  /// Recognizes the text of [pageIndex] (0-based) in the PDF at [path]. Returns
  /// the text, `''` when nothing is found, or null on failure. [pdf] renders the
  /// page image. When [bookId] is given, results are read from and written to
  /// the persistent cache so a page is OCR'd at most once, ever.
  Future<String?> recognizePage(
    String path,
    int pageIndex, {
    required PdfService pdf,
    String? bookId,
  }) async {
    final key = '$path#$pageIndex';
    final cached = _cache[key];
    if (cached != null) return cached;

    // L2: persistent cache (survives restarts). Populate L1 on a hit.
    if (bookId != null) {
      final persisted = _persistentCache.get(bookId, pageIndex);
      if (persisted != null) {
        _put(key, persisted);
        return persisted;
      }
    }

    Directory? tempDir;
    try {
      final bytes =
          await pdf.renderPage(path, pageIndex, targetWidth: _renderWidth);
      if (bytes == null) return null;

      tempDir = await Directory.systemTemp.createTemp('comfy_ocr_');
      final file = File('${tempDir.path}/page.png');
      await _writeBytes(file, bytes);
      final input = InputImage.fromFilePath(file.path);

      // We can't know a scanned page's script before reading it, so run both
      // supported recognizers and keep the longer result — the wrong script
      // produces little or nothing.
      final latin = await _recognize(_latinRecognizer, input);
      final deva = await _recognize(_devanagariRecognizer, input);
      final best = deva.length >= latin.length ? deva : latin;

      final text = _normalize(best);
      _put(key, text);
      if (bookId != null) await _persistentCache.put(bookId, pageIndex, text);
      return text;
    } catch (e, st) {
      AppLog.warning('recognizePage($pageIndex) failed for $path',
          name: 'OcrService', error: e, stackTrace: st);
      return null;
    } finally {
      if (tempDir != null) {
        try {
          await tempDir.delete(recursive: true);
        } catch (_) {/* best-effort cleanup */}
      }
    }
  }

  TextRecognizer get _latinRecognizer =>
      _latin ??= TextRecognizer(script: TextRecognitionScript.latin);

  TextRecognizer get _devanagariRecognizer =>
      _devanagari ??= TextRecognizer(script: TextRecognitionScript.devanagiri);

  Future<String> _recognize(TextRecognizer recognizer, InputImage image) async {
    try {
      final result = await recognizer.processImage(image);
      return result.text;
    } catch (e) {
      // One script failing (e.g. its model is still downloading) shouldn't kill
      // the whole OCR attempt — the other script may still succeed.
      AppLog.warning('recognizer failed', name: 'OcrService', error: e);
      return '';
    }
  }

  Future<void> _writeBytes(File file, Uint8List bytes) =>
      file.writeAsBytes(bytes, flush: true);

  void _put(String key, String text) {
    if (_cache.length >= _cacheCap) _cache.remove(_cache.keys.first);
    _cache[key] = text;
  }

  /// Collapses OCR line breaks into speakable prose (shared with
  /// [PdfService.extractPageText] via [normalizeForSpeech]).
  static String _normalize(String raw) => normalizeForSpeech(raw);

  /// Frees native recognizer resources.
  Future<void> dispose() async {
    await _latin?.close();
    await _devanagari?.close();
    _latin = null;
    _devanagari = null;
  }
}
