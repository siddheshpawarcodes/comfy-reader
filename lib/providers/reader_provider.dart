import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants/durations.dart';
import '../models/book_model.dart';
import '../models/bookmark_model.dart';
import '../models/enums.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';
import 'library_provider.dart';

/// Whether the book's document has been validated for reading.
enum ReaderStatus { loading, ready, error }

/// Per-book reader state: current page, overlay visibility, page tint, and
/// bookmarks. Persists reading position (debounced) and bookmarks.
class ReaderProvider extends ChangeNotifier {
  ReaderProvider({
    required this.book,
    required this.library,
    required PageTint initialTint,
    StorageService? storage,
    PdfService? pdf,
  })  : _storage = storage ?? StorageService.instance,
        _pdf = pdf ?? const PdfService(),
        _tint = initialTint,
        _currentPage = book.lastReadPage.clamp(0, _maxPage(book)) {
    _bookmarks
      ..clear()
      ..addAll(_storage.bookmarksFor(book.id).map((b) => b.pageIndex));
  }

  final BookModel book;
  final LibraryProvider library;
  final StorageService _storage;
  final PdfService _pdf;

  int _currentPage;
  bool _overlayVisible = false;
  PageTint _tint;
  final Set<int> _bookmarks = <int>{};
  Timer? _saveDebounce;

  // ---- Document open status ----
  ReaderStatus _status = ReaderStatus.loading;
  String? _errorMessage;
  int? _probedPages;

  ReaderStatus get status => _status;
  String? get errorMessage => _errorMessage;

  /// Probes the document before reading. On success, gates the flipbook in;
  /// on failure, surfaces a friendly error (missing / protected / corrupt).
  Future<void> init() async {
    final probe = await _pdf.probe(book.filePath);
    switch (probe.result) {
      case PdfOpenResult.ok:
        _probedPages = probe.pages;
        _currentPage = _currentPage.clamp(0, probe.pages - 1);
        _status = ReaderStatus.ready;
      case PdfOpenResult.missing:
        _errorMessage = 'This file has moved or been deleted.';
        _status = ReaderStatus.error;
      case PdfOpenResult.protected:
        _errorMessage =
            "This PDF is password-protected, which isn't supported yet.";
        _status = ReaderStatus.error;
      case PdfOpenResult.corrupt:
        _errorMessage = "This PDF appears to be damaged and can't be opened.";
        _status = ReaderStatus.error;
    }
    notifyListeners();
  }

  int get currentPage => _currentPage;
  int get totalPages => _probedPages ?? book.totalPages;
  bool get overlayVisible => _overlayVisible;
  PageTint get tint => _tint;
  double get progress =>
      totalPages <= 0 ? 0 : ((_currentPage + 1) / totalPages).clamp(0.0, 1.0);

  static int _maxPage(BookModel b) => b.totalPages > 0 ? b.totalPages - 1 : 0;

  // ---- Navigation ----
  void onPageChanged(int page) {
    if (page == _currentPage) return;
    _currentPage = page.clamp(0, _maxPage(book));
    notifyListeners();
    _scheduleSave();
  }

  // ---- Overlay (with auto-hide) ----
  Timer? _overlayTimer;
  bool _autoHideSuspended = false;

  void toggleOverlay() {
    _overlayVisible = !_overlayVisible;
    notifyListeners();
    _scheduleAutoHide();
  }

  /// Resets the auto-hide timer (call when the user interacts with the bars).
  void keepOverlayAlive() => _scheduleAutoHide();

  /// Suspends the auto-hide timer so the overlay stays visible no matter how
  /// long the user lingers — used while the coach-mark tour is pointing at
  /// controls inside it, so the bar it's highlighting can't vanish mid-tour.
  void suspendAutoHide() {
    _autoHideSuspended = true;
    _overlayTimer?.cancel();
  }

  /// Lifts the suspension and restarts the countdown fresh, as if the user
  /// had just interacted with the overlay.
  void resumeAutoHide() {
    _autoHideSuspended = false;
    _scheduleAutoHide();
  }

  void _scheduleAutoHide() {
    _overlayTimer?.cancel();
    if (!_overlayVisible || _autoHideSuspended) return;
    _overlayTimer = Timer(AppDurations.overlayAutoHide, () {
      _overlayVisible = false;
      notifyListeners();
    });
  }

  void hideOverlay() {
    _overlayTimer?.cancel();
    if (!_overlayVisible) return;
    _overlayVisible = false;
    notifyListeners();
  }

  // ---- Tint ----
  void setTint(PageTint tint) {
    if (tint == _tint) return;
    _tint = tint;
    notifyListeners();
  }

  void cycleTint() {
    const order = [PageTint.paper, PageTint.sepia, PageTint.night];
    setTint(order[(order.indexOf(_tint) + 1) % order.length]);
  }

  // ---- Bookmarks ----
  bool get isCurrentBookmarked => _bookmarks.contains(_currentPage);
  List<int> get bookmarkedPages => _bookmarks.toList()..sort();

  Future<void> toggleBookmark() async {
    if (_bookmarks.contains(_currentPage)) {
      _bookmarks.remove(_currentPage);
      await _storage.deleteBookmark(book.id, _currentPage);
    } else {
      _bookmarks.add(_currentPage);
      await _storage.saveBookmark(
        BookmarkModel(
          bookId: book.id,
          pageIndex: _currentPage,
          createdAt: DateTime.now(),
        ),
      );
    }
    notifyListeners();
  }

  // ---- Resume persistence ----
  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(AppDurations.resumeSaveDebounce, saveNow);
  }

  Future<void> saveNow() async {
    _saveDebounce?.cancel();
    await library.updateProgress(book.id, _currentPage);
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _overlayTimer?.cancel();
    // Fire-and-forget final save.
    unawaited(library.updateProgress(book.id, _currentPage));
    super.dispose();
  }
}
