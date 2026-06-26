import 'package:flutter/foundation.dart';

import '../models/book_model.dart';
import '../models/enums.dart';
import '../services/library_service.dart';

/// Reactive library state: the book list, layout, sort, search, and scan
/// status. Delegates persistence to [LibraryService].
class LibraryProvider extends ChangeNotifier {
  LibraryProvider({LibraryService? service})
      : _service = service ?? LibraryService();

  final LibraryService _service;

  final List<BookModel> _books = <BookModel>[];
  LibraryView _view = LibraryView.grid;
  SortMode _sort = SortMode.recent;
  String _searchQuery = '';
  bool _isScanning = false;

  // ---- Getters ----
  List<BookModel> get books => List.unmodifiable(_books);
  LibraryView get view => _view;
  SortMode get sort => _sort;
  String get searchQuery => _searchQuery;
  bool get isScanning => _isScanning;
  bool get isEmpty => _books.isEmpty;

  /// Books filtered by [searchQuery] (title contains) and ordered by [sort].
  List<BookModel> get filteredSortedBooks {
    final q = _searchQuery.trim().toLowerCase();
    final list = q.isEmpty
        ? List<BookModel>.from(_books)
        : _books.where((b) => b.title.toLowerCase().contains(q)).toList();
    list.sort(_comparator);
    return list;
  }

  /// Every started book that's been opened, newest first. Powers the dedicated
  /// "Continue Reading" tab.
  List<BookModel> get inProgress {
    final started = _books
        .where((b) => b.lastOpened != null && b.hasStarted)
        .toList()
      ..sort((a, b) => b.lastOpened!.compareTo(a.lastOpened!));
    return List.unmodifiable(started);
  }

  /// The most recent slice of [inProgress] — used for compact "Continue
  /// Reading" rails.
  List<BookModel> get recents => inProgress.take(8).toList(growable: false);

  int Function(BookModel, BookModel) get _comparator => switch (_sort) {
        SortMode.name => (a, b) =>
            a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        SortMode.dateAdded => (a, b) => b.addedAt.compareTo(a.addedAt),
        SortMode.recent => (a, b) {
            final ao = a.lastOpened ?? a.addedAt;
            final bo = b.lastOpened ?? b.addedAt;
            return bo.compareTo(ao);
          },
      };

  // ---- Loading ----
  void loadFromStorage() {
    _books
      ..clear()
      ..addAll(_service.allBooks());
    notifyListeners();
  }

  // ---- Mutations ----
  void setView(LibraryView view) {
    if (view == _view) return;
    _view = view;
    notifyListeners();
  }

  void toggleView() =>
      setView(_view == LibraryView.grid ? LibraryView.list : LibraryView.grid);

  void setSort(SortMode sort) {
    if (sort == _sort) return;
    _sort = sort;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (query == _searchQuery) return;
    _searchQuery = query;
    notifyListeners();
  }

  /// Imports a PDF via the picker. Returns the new book (or null if cancelled).
  Future<BookModel?> importFromPicker() async {
    final book = await _service.importFromPicker();
    if (book != null) _upsert(book);
    return book;
  }

  /// Scans the device (Android) and merges discovered books.
  Future<int> scanDevice() async {
    _isScanning = true;
    notifyListeners();
    try {
      final added = await _service.scanDevice();
      for (final b in added) {
        _upsert(b);
      }
      return added.length;
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  /// Generates a cover for [book] if missing, updating the list in place.
  Future<void> ensureCover(BookModel book) async {
    if (book.coverImagePath != null) return;
    final updated = await _service.ensureCover(book);
    if (updated.coverImagePath != null) _upsert(updated);
  }

  Future<void> updateProgress(String id, int page) async {
    final updated = await _service.updateProgress(id, page);
    if (updated != null) _upsert(updated);
  }

  Future<void> markOpened(String id) async {
    final updated = await _service.markOpened(id);
    if (updated != null) _upsert(updated);
  }

  Future<void> removeBook(BookModel book) async {
    await _service.removeBook(book);
    _books.removeWhere((b) => b.id == book.id);
    notifyListeners();
  }

  BookModel? bookById(String id) {
    for (final b in _books) {
      if (b.id == id) return b;
    }
    return null;
  }

  void _upsert(BookModel book) {
    final i = _books.indexWhere((b) => b.id == book.id);
    if (i == -1) {
      _books.add(book);
    } else {
      _books[i] = book;
    }
    notifyListeners();
  }
}
