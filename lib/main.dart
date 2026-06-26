import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart' show pdfrxFlutterInitialize;

import 'app.dart';
import 'core/utils/app_log.dart';
import 'core/utils/app_paths.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';
import 'services/tts_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Funnel uncaught errors to one place. FlutterError.onError covers synchronous
  // framework/build errors; PlatformDispatcher.onError covers everything else
  // (async gaps, platform-channel callbacks) that would otherwise vanish. This
  // is the pair the Flutter docs recommend; both route through AppLog, so adding
  // a crash reporter later is a single AppLog.onRecord assignment here.
  final presentError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLog.error(
      details.summary.toString(),
      name: 'flutter',
      error: details.exception,
      stackTrace: details.stack,
    );
    presentError?.call(details); // preserve red screen / console dump in debug
  };
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    AppLog.error('Uncaught error', name: 'app', error: error, stackTrace: stack);
    return true; // handled — don't also crash the isolate
  };

  // Bound the decoded-image cache so a large (500+ page) PDF's pages evict
  // automatically — this IS the reader's LRU (Step 4.2/6.4). The flipbook keeps
  // the current page ±3 decoded (~7 live); covers + scrubber thumbnails add a
  // few more. Sizing math (worst case, max render width 1600px, ~3:4 → decoded
  // RGBA ≈ 1600×2133×4 ≈ 14 MB/page): 14 pages × ~14 MB ≈ 196 MB < 220 MB, so
  // the byte cap is the true bound and count gives headroom for thumbs/covers.
  // Far pages evict as you read; memory stays flat on huge PDFs. Re-profile on
  // a real device if adjusting (the x86 emulator's first render is unrepresentative).
  PaintingBinding.instance.imageCache
    ..maximumSize = 14
    ..maximumSizeBytes = 220 << 20; // ~220 MB

  // Portrait-only for v1 (landscape spread is a future stretch).
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  // pdfrx is used only for read-aloud text extraction (PdfService.extractPageText);
  // pdfx remains the renderer. Initialize its native engine once up front.
  pdfrxFlutterInitialize();

  // Initialize services before the first frame.
  await AppPaths.init();
  await StorageService.instance.init();
  await AudioService.instance.init();
  await TtsService.instance.init();

  runApp(const ComfyReaderApp());
}
