import 'package:hive_ce/hive.dart';

import '../core/utils/app_log.dart';

/// Persistent, cross-session cache of OCR (and quality-repaired) page text.
///
/// OCR is the expensive path — it renders a ~2000px page image and runs ML Kit.
/// Once a page has been recognized we never want to pay for it again, even after
/// the app restarts, so results are stored in a Hive box keyed by the book's
/// stable id ([BookModel.id] = `sha1(filePath + fileSize)`) and page index.
///
/// The service is a thin wrapper over a single [Box]; [StorageService] opens the
/// box at startup and [bind]s it here. Tests bind a temporary box directly.
class OcrCacheService {
  OcrCacheService._();
  static final OcrCacheService instance = OcrCacheService._();

  /// Name of the Hive box (opened by [StorageService]).
  static const String boxName = 'ocr_cache';

  /// Bump when the stored record shape changes so stale records are ignored.
  static const int _schemaVersion = 1;

  /// Upper bound on cached pages. At ~1–4 KB of text per page this is a few MB;
  /// when exceeded, the oldest entries (by write timestamp) are evicted. Sized
  /// to comfortably hold several 500+ page books.
  static const int _maxEntries = 6000;

  Box<Map>? _box;

  /// Wires in the opened Hive box. Called once from [StorageService.init].
  void bind(Box<Map> box) => _box = box;

  /// True once [bind] has run; false in a context that never opened the box.
  bool get isReady => _box != null;

  static String _key(String bookId, int page) => '$bookId#$page';

  /// Cached text for ([bookId], [page]), or null on a miss / before [bind].
  String? get(String bookId, int page) {
    final box = _box;
    if (box == null) return null;
    final record = box.get(_key(bookId, page));
    if (record == null) return null;
    if (record['v'] != _schemaVersion) return null;
    final text = record['text'];
    return text is String ? text : null;
  }

  /// Stores [text] for ([bookId], [page]). No-op before [bind] or on failure —
  /// caching is best-effort and must never break playback. Empty text is stored
  /// too, so a page proven to have nothing readable is not re-OCR'd every visit.
  Future<void> put(String bookId, int page, String text) async {
    final box = _box;
    if (box == null) return;
    try {
      await box.put(_key(bookId, page), <String, dynamic>{
        'v': _schemaVersion,
        'text': text,
        'ts': DateTime.now().millisecondsSinceEpoch,
      });
      if (box.length > _maxEntries) await _evictOldest(box);
    } catch (e, st) {
      AppLog.warning('OCR cache put failed for $bookId#$page',
          name: 'OcrCacheService', error: e, stackTrace: st);
    }
  }

  /// Removes every cached page for [bookId] (call when a book is deleted).
  Future<void> clearBook(String bookId) async {
    final box = _box;
    if (box == null) return;
    final prefix = '$bookId#';
    final keys = box.keys
        .where((k) => k is String && k.startsWith(prefix))
        .toList(growable: false);
    if (keys.isNotEmpty) await box.deleteAll(keys);
  }

  /// Empties the whole cache (e.g. a "clear reading cache" settings action).
  Future<void> clearAll() async => _box?.clear();

  /// Number of cached pages (for diagnostics/tests).
  int get length => _box?.length ?? 0;

  /// Evicts the oldest ~10% of entries by write timestamp, so the trim amortizes
  /// instead of running on every insert once full.
  Future<void> _evictOldest(Box<Map> box) async {
    final entries = box.keys.map((k) {
      final ts = box.get(k)?['ts'];
      return MapEntry(k, ts is int ? ts : 0);
    }).toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final drop = (box.length - _maxEntries) + (_maxEntries ~/ 10);
    final victims = entries.take(drop).map((e) => e.key).toList(growable: false);
    if (victims.isNotEmpty) await box.deleteAll(victims);
  }
}
