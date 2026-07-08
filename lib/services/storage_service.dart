import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/app_paths.dart';
import '../models/book_model.dart';
import '../models/bookmark_model.dart';
import 'ocr_cache_service.dart';

/// Centralized persistence: Hive boxes for books + bookmarks (stored as maps,
/// no codegen) and SharedPreferences for settings.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const String _booksBoxName = 'books';
  static const String _bookmarksBoxName = 'bookmarks';

  late final Box<Map> _booksBox;
  late final Box<Map> _bookmarksBox;
  late final SharedPreferences prefs;

  bool _initialized = false;

  /// Opens Hive boxes and SharedPreferences. Call once at startup, after
  /// [AppPaths.init].
  Future<void> init() async {
    if (_initialized) return;
    Hive.init(AppPaths.support.path);
    _booksBox = await Hive.openBox<Map>(_booksBoxName);
    _bookmarksBox = await Hive.openBox<Map>(_bookmarksBoxName);
    // Persistent OCR/quality-repair cache (see OcrCacheService). Opened here so
    // all Hive boxes share one owner; bound into the service for the pipeline.
    final ocrCacheBox = await Hive.openBox<Map>(OcrCacheService.boxName);
    OcrCacheService.instance.bind(ocrCacheBox);
    prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // ---- Books ----

  List<BookModel> allBooks() {
    return _booksBox.values
        .map((m) => BookModel.fromMap(m))
        .toList(growable: false);
  }

  BookModel? book(String id) {
    final map = _booksBox.get(id);
    return map == null ? null : BookModel.fromMap(map);
  }

  Future<void> saveBook(BookModel book) => _booksBox.put(book.id, book.toMap());

  Future<void> deleteBook(String id) async {
    await _booksBox.delete(id);
    // Reclaim the book's OCR cache; its pages can never be needed again.
    await OcrCacheService.instance.clearBook(id);
  }

  // ---- Bookmarks ----

  List<BookmarkModel> bookmarksFor(String bookId) {
    return _bookmarksBox.values
        .map((m) => BookmarkModel.fromMap(m))
        .where((b) => b.bookId == bookId)
        .toList(growable: false)
      ..sort((a, b) => a.pageIndex.compareTo(b.pageIndex));
  }

  bool isBookmarked(String bookId, int pageIndex) {
    return _bookmarksBox.containsKey(
      BookmarkModel.storageKey(bookId, pageIndex),
    );
  }

  Future<void> saveBookmark(BookmarkModel bookmark) {
    return _bookmarksBox.put(bookmark.key, bookmark.toMap());
  }

  Future<void> deleteBookmark(String bookId, int pageIndex) {
    return _bookmarksBox.delete(BookmarkModel.storageKey(bookId, pageIndex));
  }

  /// Removes all bookmarks for a book (used when removing the book).
  Future<void> deleteBookmarksFor(String bookId) async {
    final keys = _bookmarksBox.keys
        .where((k) => k is String && k.startsWith('$bookId:'))
        .toList();
    await _bookmarksBox.deleteAll(keys);
  }
}
