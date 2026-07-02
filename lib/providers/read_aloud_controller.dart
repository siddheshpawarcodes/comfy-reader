import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../core/utils/app_log.dart';
import '../core/utils/language_detector.dart';
import '../features/reader/widgets/book_curl_view.dart';
import '../services/ocr_service.dart';
import '../services/pdf_service.dart';
import '../services/tts_service.dart';
import 'reader_provider.dart';

/// Read-aloud playback lifecycle.
enum ReadAloudState {
  /// Not reading; the playback bar is hidden.
  idle,

  /// Extracting the current page's text before speaking it.
  loading,

  /// Speaking.
  playing,

  /// Paused mid-page by the user.
  paused,

  /// Reached the end of the book.
  finished,

  /// The book has no readable text (likely scanned images).
  unavailable,
}

/// Orchestrates continuous text-to-speech over a book's pages.
///
/// Created per reader session (like [ReaderProvider]) and driven by one rule:
/// **always read [ReaderProvider.currentPage]**. The controller listens to the
/// reader, so both auto-advance (it calls [BookCurlController.next], which turns
/// the page and updates the reader) and manual turns/scrubs funnel through the
/// same path — reading simply follows whatever page is showing.
///
/// Text comes from [PdfService.extractPageText] (pdfrx); speech from
/// [TtsService] (flutter_tts). Long pages are spoken sentence-by-sentence so
/// pause/stop stay responsive and we sidestep the engine's per-utterance limit.
class ReadAloudController extends ChangeNotifier {
  ReadAloudController({
    required this.filePath,
    required this.reader,
    required this.curl,
    required double initialRate,
    this.autoDetectLanguage = true,
    this.devanagariLanguage = 'hi-IN',
    this.voiceByLanguage = const <String, String>{},
    this.readScannedBooks = true,
    PdfService? pdf,
    TtsService? tts,
    OcrService? ocr,
  })  : _pdf = pdf ?? const PdfService(),
        _tts = tts ?? TtsService.instance,
        _ocr = ocr ?? OcrService.instance {
    _tts.setRate(initialRate);
    _tts.onComplete = _onUtteranceComplete;
    _tts.onError = _onError;
    reader.addListener(_onReaderChanged);
  }

  final String filePath;
  final ReaderProvider reader;
  final BookCurlController curl;
  final PdfService _pdf;
  final TtsService _tts;
  final OcrService _ocr;

  /// Pick the spoken language from each page's script (vs. always English).
  final bool autoDetectLanguage;

  /// Which language Devanagari text is read as (`hi-IN` or `mr-IN`).
  final String devanagariLanguage;

  /// Per-language voice overrides (BCP-47 locale → voice name).
  final Map<String, String> voiceByLanguage;

  /// OCR pages with no text layer (scanned books) so they can still be read.
  final bool readScannedBooks;

  /// Debounce page-change reactions so scrubbing many pages doesn't stutter.
  static const Duration _pageSettle = Duration(milliseconds: 350);

  /// Engine cap is ~4000 chars/utterance; chunk well under it.
  static const int _maxChunkChars = 3500;

  /// Stop and report "no readable text" after this many empty pages with
  /// nothing yet spoken — avoids silently flipping a scanned book to the end.
  static const int _emptyPageGiveUp = 8;

  ReadAloudState _state = ReadAloudState.idle;

  /// One-off override for this session: when set, every page is read in this
  /// locale instead of the per-page auto-detected one. Not persisted — reset
  /// by picking "Auto-detect" again, or simply lost when the reader closes.
  String? _forcedLocale;
  List<String> _chunks = const [];
  int _chunkIndex = 0;
  int _speakingPage = -1;
  int _consecutiveEmpty = 0;
  bool _spokeAnything = false;

  /// True while OCR is running for the current page (a slower path) — drives a
  /// distinct "Scanning…" status.
  bool _ocrRunning = false;

  Timer? _pageDebounce;

  /// Guards against a stale text-extraction result winning a race when the
  /// page changes again mid-extract.
  int _extractToken = 0;

  // ---- Public state for the UI ----
  ReadAloudState get state => _state;
  bool get isPlaying => _state == ReadAloudState.playing;
  bool get isPaused => _state == ReadAloudState.paused;

  /// Whether the playback bar should be shown (anything but fully idle).
  bool get isActive => _state != ReadAloudState.idle;

  /// The session-override locale, or null when following auto-detection.
  String? get forcedLocale => _forcedLocale;

  /// User-facing status line for the playback bar.
  String get statusLabel => switch (_state) {
        ReadAloudState.idle => '',
        ReadAloudState.loading => _ocrRunning
            ? 'Scanning page ${_speakingPage + 1}…'
            : 'Preparing page ${_speakingPage + 1}…',
        ReadAloudState.playing => 'Reading page ${_speakingPage + 1}',
        ReadAloudState.paused => 'Paused · page ${_speakingPage + 1}',
        ReadAloudState.finished => 'Finished',
        ReadAloudState.unavailable => readScannedBooks
            ? "Couldn't read this book — the scanned text wasn't clear enough."
            : 'Scanned book — turn on “Read scanned books” in Settings to listen.',
      };

  // ---- Controls ----

  /// Start, or resume from pause.
  void play() {
    switch (_state) {
      case ReadAloudState.playing || ReadAloudState.loading:
        return;
      case ReadAloudState.paused:
        // If the user turned the page while paused, follow them; otherwise
        // resume the current sentence (flutter_tts has no reliable mid-utterance
        // resume, so we re-speak from the current chunk).
        if (reader.currentPage != _speakingPage || _chunks.isEmpty) {
          _speakPage(reader.currentPage);
        } else {
          _state = ReadAloudState.playing;
          notifyListeners();
          _tts.speak(_chunks[_chunkIndex]);
        }
      case ReadAloudState.idle ||
            ReadAloudState.finished ||
            ReadAloudState.unavailable:
        _consecutiveEmpty = 0;
        _spokeAnything = false;
        _speakPage(reader.currentPage);
    }
    WakelockPlus.enable(); // keep the screen alive while listening
  }

  void pause() {
    if (_state != ReadAloudState.playing && _state != ReadAloudState.loading) {
      return;
    }
    _pageDebounce?.cancel();
    _tts.pause();
    _state = ReadAloudState.paused;
    notifyListeners();
  }

  void stop() {
    _pageDebounce?.cancel();
    _extractToken++; // invalidate any in-flight extraction
    _tts.stop();
    _chunks = const [];
    _chunkIndex = 0;
    _speakingPage = -1;
    _ocrRunning = false;
    _state = ReadAloudState.idle;
    notifyListeners();
  }

  void toggle() => isPlaying ? pause() : play();

  /// Apply a new speech rate live (the slider also persists it via settings).
  void setRate(double rate) => _tts.setRate(rate);

  /// Forces every page to be read in [locale] instead of the auto-detected
  /// one; pass null to resume auto-detection. Re-applies immediately if a
  /// page is already loading, playing, or paused.
  void setForcedLocale(String? locale) {
    if (_forcedLocale == locale) return;
    _forcedLocale = locale;
    notifyListeners();
    if (_state == ReadAloudState.playing ||
        _state == ReadAloudState.paused ||
        _state == ReadAloudState.loading) {
      _speakPage(reader.currentPage);
    }
  }

  // ---- Orchestration ----

  void _onReaderChanged() {
    if (_state != ReadAloudState.playing && _state != ReadAloudState.loading) {
      return;
    }
    if (reader.currentPage == _speakingPage) return;
    // A turn (ours or the user's) landed on a new page — read it, debounced so
    // fast scrubbing doesn't trigger a burst of extractions.
    _pageDebounce?.cancel();
    _pageDebounce = Timer(_pageSettle, () => _speakPage(reader.currentPage));
  }

  Future<void> _speakPage(int page) async {
    _speakingPage = page;
    _state = ReadAloudState.loading;
    notifyListeners();

    final token = ++_extractToken;
    await _tts.stop(); // cancel any current utterance before the new page
    final text = await _pdf.extractPageText(filePath, page);

    if (token != _extractToken) return; // a newer page took over

    var body = (text ?? '').trim();
    // No embedded text → likely a scanned page. Fall back to OCR (slower) if the
    // user hasn't turned it off.
    if (body.isEmpty && readScannedBooks) {
      _ocrRunning = true;
      notifyListeners(); // surface the "Scanning…" status
      final recognized = await _ocr.recognizePage(filePath, page, pdf: _pdf);
      _ocrRunning = false;
      if (token != _extractToken) return; // page changed during OCR
      body = (recognized ?? '').trim();
    }
    if (body.isEmpty) {
      _handleEmptyPage();
      return;
    }

    _consecutiveEmpty = 0;
    _spokeAnything = true;
    _chunks = _chunkText(body);
    _chunkIndex = 0;
    if (_chunks.isEmpty) {
      _handleEmptyPage();
      return;
    }
    // Tell the engine which language this page is in (and the user's preferred
    // voice for it) before speaking — otherwise non-English pages are read with
    // an English voice and come out garbled. A forced session locale wins over
    // auto-detection outright (it's what the user told us the text is).
    if (_forcedLocale != null || autoDetectLanguage) {
      final locale = _forcedLocale ??
          LanguageDetector.languageFor(
            LanguageDetector.detect(body),
            devanagariIsMarathi: devanagariLanguage == 'mr-IN',
          );
      // Marathi shares Devanagari with Hindi; if the device has no offline
      // Marathi voice, read it with the Hindi voice rather than a broken one.
      final fallback = locale == 'mr-IN' ? 'hi-IN' : null;
      await _tts.applyLanguage(
        locale,
        preferredVoiceName: voiceByLanguage[locale],
        fallbackLocale: fallback,
      );
      if (token != _extractToken) return; // page changed while applying
    }
    _state = ReadAloudState.playing;
    notifyListeners();
    _tts.speak(_chunks[_chunkIndex]);
  }

  void _handleEmptyPage() {
    _consecutiveEmpty++;
    // Nothing readable anywhere so far and we've flipped through several pages →
    // it's a scanned book; stop instead of racing to the end in silence.
    if (!_spokeAnything && _consecutiveEmpty >= _emptyPageGiveUp) {
      _state = ReadAloudState.unavailable;
      notifyListeners();
      return;
    }
    _advance();
  }

  void _onUtteranceComplete() {
    if (_state != ReadAloudState.playing) return; // stray event after stop/pause
    _chunkIndex++;
    if (_chunkIndex < _chunks.length) {
      _tts.speak(_chunks[_chunkIndex]);
    } else {
      _advance();
    }
  }

  void _onError(dynamic message) {
    AppLog.warning('TTS error', name: 'ReadAloudController', error: message);
    if (_state == ReadAloudState.playing) _advance(); // skip the bad page/chunk
  }

  /// Move to the next page, or finish at the end of the book. Turning the page
  /// updates the reader, which re-enters [_onReaderChanged] → [_speakPage].
  void _advance() {
    if (reader.currentPage < reader.totalPages - 1) {
      curl.next();
    } else {
      _state = ReadAloudState.finished;
      notifyListeners();
    }
  }

  /// Splits page text into sentence-sized chunks, hard-splitting any run longer
  /// than [_maxChunkChars] (e.g. punctuation-free text) to respect engine limits.
  static List<String> _chunkText(String text) {
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    final chunks = <String>[];
    for (final raw in sentences) {
      final s = raw.trim();
      if (s.isEmpty) continue;
      if (s.length <= _maxChunkChars) {
        chunks.add(s);
      } else {
        for (var i = 0; i < s.length; i += _maxChunkChars) {
          chunks.add(s.substring(i, (i + _maxChunkChars).clamp(0, s.length)));
        }
      }
    }
    return chunks;
  }

  @override
  void dispose() {
    _pageDebounce?.cancel();
    reader.removeListener(_onReaderChanged);
    _tts.onComplete = null;
    _tts.onError = null;
    _tts.stop();
    super.dispose();
  }
}
