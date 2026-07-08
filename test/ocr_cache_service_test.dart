import 'dart:io';

import 'package:comfy_reader/services/ocr_cache_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box<Map> box;
  late OcrCacheService cache;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ocr_cache_test_');
    Hive.init(tempDir.path);
    box = await Hive.openBox<Map>('ocr_cache_test');
    // A fresh service instance per test so state never leaks between cases.
    cache = OcrCacheService.instance;
    cache.bind(box);
    await box.clear();
  });

  tearDown(() async {
    await box.clear();
    await Hive.close();
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {/* best effort */}
  });

  test('miss returns null', () {
    expect(cache.get('book-a', 3), isNull);
  });

  test('put then get round-trips the text', () async {
    await cache.put('book-a', 3, 'recognized text');
    expect(cache.get('book-a', 3), 'recognized text');
  });

  test('keys are scoped by book id and page', () async {
    await cache.put('book-a', 0, 'A0');
    await cache.put('book-a', 1, 'A1');
    await cache.put('book-b', 0, 'B0');

    expect(cache.get('book-a', 0), 'A0');
    expect(cache.get('book-a', 1), 'A1');
    expect(cache.get('book-b', 0), 'B0');
    expect(cache.get('book-a', 2), isNull);
  });

  test('empty text is cached (a proven-blank page is not re-OCR\'d)', () async {
    await cache.put('book-a', 5, '');
    expect(cache.get('book-a', 5), '');
  });

  test('clearBook removes only that book', () async {
    await cache.put('book-a', 0, 'A0');
    await cache.put('book-a', 1, 'A1');
    await cache.put('book-b', 0, 'B0');

    await cache.clearBook('book-a');

    expect(cache.get('book-a', 0), isNull);
    expect(cache.get('book-a', 1), isNull);
    expect(cache.get('book-b', 0), 'B0');
  });

  test('clearAll empties the cache', () async {
    await cache.put('book-a', 0, 'A0');
    await cache.put('book-b', 0, 'B0');

    await cache.clearAll();

    expect(cache.length, 0);
    expect(cache.get('book-a', 0), isNull);
  });

  test('put overwrites an existing entry', () async {
    await cache.put('book-a', 0, 'old');
    await cache.put('book-a', 0, 'new');
    expect(cache.get('book-a', 0), 'new');
    expect(cache.length, 1);
  });

  test('is ready once bound', () {
    expect(cache.isReady, isTrue);
  });
}
