import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../core/utils/app_log.dart';
import '../core/utils/app_paths.dart';
import '../core/utils/semaphore.dart';
import '../models/book_model.dart';
import 'pdf_service.dart';
import 'storage_service.dart';

/// Owns the book lifecycle: import (picker), discover (Android scan), cover
/// generation, and persistence. UI state lives in `LibraryProvider`.
class LibraryService {
  LibraryService({
    StorageService? storage,
    PdfService pdf = const PdfService(),
  })  : _storage = storage ?? StorageService.instance,
        _pdf = pdf;

  final StorageService _storage;
  final PdfService _pdf;

  /// Bounds concurrent cover rendering so a burst of newly-visible library
  /// cards can't flood the native PDF renderer and stutter scrolling. ~3 keeps
  /// covers filling in quickly without monopolizing the renderer.
  static final Semaphore _coverThrottle = Semaphore(3);

  /// Common Android folders to scan for PDFs (recursively).
  static const List<String> _androidScanRoots = <String>[
    '/storage/emulated/0/Download',
    '/storage/emulated/0/Downloads',
    '/storage/emulated/0/Documents',
    '/storage/emulated/0/Books',
  ];

  List<BookModel> allBooks() => _storage.allBooks();

  /// Imports a PDF chosen from the system picker. Copies it into the app's
  /// books dir (so it persists, required on iOS), generates a cover, persists.
  /// Returns the book, or null if the user cancelled.
  Future<BookModel?> importFromPicker() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['pdf'],
    );
    final srcPath = result?.files.single.path;
    if (srcPath == null) return null;

    final src = File(srcPath);
    final size = await src.length();
    final destPath = await _uniqueDestPath(srcPath);
    await src.copy(destPath);

    final id = BookModel.computeId(destPath, size);
    final existing = _storage.book(id);
    if (existing != null) return existing;

    final pages = await _pdf.pageCount(destPath);
    var book = BookModel.create(
      filePath: destPath,
      fileSize: size,
      totalPages: pages,
      addedAt: DateTime.now(),
      isImported: true,
    );
    final cover = await _pdf.generateCover(book);
    if (cover != null) book = book.copyWith(coverImagePath: cover);
    await _storage.saveBook(book);
    return book;
  }

  /// Scans common device folders for PDFs (Android). Returns books newly added
  /// to the library. Covers are left null and generated lazily later. Caller
  /// must already hold storage permission. iOS returns [] (sandbox).
  Future<List<BookModel>> scanDevice() async {
    if (!Platform.isAndroid) return const <BookModel>[];
    final added = <BookModel>[];
    for (final root in _androidScanRoots) {
      final dir = Directory(root);
      if (!await dir.exists()) continue;
      try {
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is! File) continue;
          if (!entity.path.toLowerCase().endsWith('.pdf')) continue;
          final book = await _maybeIndex(entity);
          if (book != null) added.add(book);
        }
      } catch (e, st) {
        AppLog.warning('scanDevice failed under $root',
            name: 'LibraryService', error: e, stackTrace: st);
      }
    }
    return added;
  }

  /// Indexes a discovered file if not already known. No cover yet.
  Future<BookModel?> _maybeIndex(File file) async {
    try {
      final size = await file.length();
      final id = BookModel.computeId(file.path, size);
      if (_storage.book(id) != null) return null;
      final pages = await _pdf.pageCount(file.path);
      if (pages <= 0) return null;
      final book = BookModel.create(
        filePath: file.path,
        fileSize: size,
        totalPages: pages,
        addedAt: DateTime.now(),
        isImported: false,
      );
      await _storage.saveBook(book);
      return book;
    } catch (e, st) {
      AppLog.warning('_maybeIndex failed for ${file.path}',
          name: 'LibraryService', error: e, stackTrace: st);
      return null;
    }
  }

  /// Generates + persists a cover for [book] if missing. Returns the updated
  /// book (or the original if generation failed).
  Future<BookModel> ensureCover(BookModel book) async {
    if (book.coverImagePath != null) return book;
    // Throttle concurrent renders (Step 6.4) so scrolling stays smooth.
    final cover = await _coverThrottle.withPermit(() => _pdf.generateCover(book));
    if (cover == null) return book;
    final updated = book.copyWith(coverImagePath: cover);
    await _storage.saveBook(updated);
    return updated;
  }

  /// Updates the last-read page / progress / lastOpened and persists.
  Future<BookModel?> updateProgress(String id, int page) async {
    final book = _storage.book(id);
    if (book == null) return null;
    final updated = book.copyWith(
      lastReadPage: page,
      lastOpened: DateTime.now(),
    );
    await _storage.saveBook(updated);
    return updated;
  }

  /// Marks a book opened (updates lastOpened) without changing the page.
  Future<BookModel?> markOpened(String id) async {
    final book = _storage.book(id);
    if (book == null) return null;
    final updated = book.copyWith(lastOpened: DateTime.now());
    await _storage.saveBook(updated);
    return updated;
  }

  /// Removes a book from the library: deletes the Hive entry, its bookmarks,
  /// the cached cover, and (only if we imported a copy) the copied PDF.
  Future<void> removeBook(BookModel book) async {
    await _storage.deleteBook(book.id);
    await _storage.deleteBookmarksFor(book.id);
    final cover = book.coverImagePath;
    if (cover != null) {
      await _safeDelete(File(cover));
    }
    // Only delete the PDF if it lives in our books dir (imported copy).
    if (book.filePath.startsWith(AppPaths.books.path)) {
      await _safeDelete(File(book.filePath));
    }
  }

  Future<void> _safeDelete(File f) async {
    try {
      if (await f.exists()) await f.delete();
    } catch (e, st) {
      AppLog.warning('_safeDelete failed for ${f.path}',
          name: 'LibraryService', error: e, stackTrace: st);
    }
  }

  /// Returns a non-colliding path in the books dir for [srcPath]'s filename.
  Future<String> _uniqueDestPath(String srcPath) async {
    final name = srcPath.split('/').last;
    final dot = name.lastIndexOf('.');
    final base = dot == -1 ? name : name.substring(0, dot);
    final ext = dot == -1 ? '' : name.substring(dot);
    var candidate = '${AppPaths.books.path}/$name';
    var n = 1;
    while (await File(candidate).exists()) {
      candidate = '${AppPaths.books.path}/$base ($n)$ext';
      n++;
    }
    return candidate;
  }
}
