// Unit tests for the foundation layer (models + theme + utils). Full widget/
// integration tests arrive with the screens in later phases.

import 'dart:async';

import 'package:comfy_reader/core/theme/app_theme.dart';
import 'package:comfy_reader/core/utils/semaphore.dart';
import 'package:comfy_reader/models/app_settings.dart';
import 'package:comfy_reader/models/book_model.dart';
import 'package:comfy_reader/models/enums.dart';
import 'package:comfy_reader/services/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BookModel round-trips through toMap/fromMap', () {
    final book = BookModel.create(
      filePath: '/books/My Great Read.pdf',
      fileSize: 12345,
      totalPages: 200,
      addedAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
    ).copyWith(lastReadPage: 49, coverImagePath: '/covers/x.png');

    final restored = BookModel.fromMap(book.toMap());

    expect(restored.id, book.id);
    expect(restored.title, 'My Great Read');
    expect(restored.totalPages, 200);
    expect(restored.lastReadPage, 49);
    expect(restored.coverImagePath, '/covers/x.png');
    expect(restored.progress, closeTo(50 / 200, 1e-9));
  });

  test('AppSettings round-trips and preserves enums', () {
    const settings = AppSettings(
      themeMode: AppThemeMode.night,
      soundEnabled: false,
      soundVolume: 0.4,
      pageTint: PageTint.sepia,
      speechRate: 0.8,
    );

    final restored = AppSettings.fromMap(settings.toMap());

    expect(restored, settings);
    expect(restored.pageTint, PageTint.sepia);
    expect(restored.themeMode, AppThemeMode.night);
    expect(restored.speechRate, 0.8);
  });

  test('AppTheme builds light and dark with the brand extension', () {
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
    expect(AppTheme.light.extension<ComfyColors>(), isNotNull);
    expect(AppTheme.dark.extension<ComfyColors>(), isNotNull);
  });

  test('PdfService.probe reports a missing file (no native render needed)', () async {
    const pdf = PdfService();
    final probe = await pdf.probe('/no/such/comfy_reader_missing.pdf');
    expect(probe.result, PdfOpenResult.missing);
    expect(probe.ok, isFalse);
    expect(probe.pages, 0);
  });

  test('Semaphore caps concurrency at its limit', () async {
    final sem = Semaphore(3);
    var running = 0;
    var peak = 0;
    final gates = <Completer<void>>[];

    Future<void> task() => sem.withPermit(() async {
          running++;
          if (running > peak) peak = running;
          final gate = Completer<void>();
          gates.add(gate);
          await gate.future; // hold the permit until released
          running--;
        });

    final tasks = List.generate(10, (_) => task());
    await Future<void>.delayed(Duration.zero); // let the first batch acquire

    expect(sem.active, 3); // only 3 permits granted up front
    expect(gates.length, 3);

    // Release started tasks in order; each release starts a queued one, and the
    // `gates` list grows as they do — so this drains all 10.
    for (var i = 0; i < gates.length; i++) {
      gates[i].complete();
      await Future<void>.delayed(Duration.zero);
    }
    await Future.wait(tasks);
    expect(peak, 3); // never ran more than 3 at once
    expect(sem.active, 0); // all permits released
  });
}
