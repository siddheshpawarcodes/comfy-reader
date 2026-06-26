import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Resolves and caches the app's working directories. Call [init] once at
/// startup (before [StorageService.init]).
abstract final class AppPaths {
  static late final Directory support;
  static late final Directory documents;

  /// Imported PDFs are copied here so they persist (required on iOS sandbox).
  static late final Directory books;

  /// Generated cover images live here.
  static late final Directory covers;

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    support = await getApplicationSupportDirectory();
    documents = await getApplicationDocumentsDirectory();
    books = Directory('${documents.path}/books');
    covers = Directory('${support.path}/covers');
    await books.create(recursive: true);
    await covers.create(recursive: true);
    _initialized = true;
  }
}
