import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../core/utils/app_log.dart';

/// Thin boundary over the OS-native text-to-speech engine (offline, no API
/// keys). Mirrors [AudioService]: a singleton initialized once in `main()`.
///
/// Orchestration (chunking, page auto-advance) lives in `ReadAloudController`;
/// this class only owns the platform channel and forwards engine events to
/// whatever callbacks the active controller has bound via [onComplete] /
/// [onError]. Callbacks are nullable so a disposed controller can unbind.
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  /// Fired when the current utterance finishes — drives chunk/page advance.
  VoidCallback? onComplete;

  /// Fired on engine error so the controller can recover (skip / surface).
  void Function(dynamic message)? onError;

  /// Preloads the engine and wires the event handlers once. Safe to call again.
  Future<void> init() async {
    if (_ready) return;
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5); // engine "normal"; overridden per-session
      // Route engine events through stable indirection so the per-session
      // controller can bind/unbind without re-registering platform handlers.
      _tts.setCompletionHandler(() => onComplete?.call());
      _tts.setErrorHandler((msg) => onError?.call(msg));
      _ready = true;
    } catch (e, st) {
      AppLog.warning('init failed', name: 'TtsService', error: e, stackTrace: st);
    }
  }

  bool get isReady => _ready;

  /// Speaks [text]. Fire-and-forget: completion arrives via [onComplete].
  Future<void> speak(String text) async {
    if (!_ready || text.isEmpty) return;
    try {
      await _tts.speak(text);
    } catch (e, st) {
      AppLog.warning('speak failed', name: 'TtsService', error: e, stackTrace: st);
    }
  }

  Future<void> pause() async {
    if (!_ready) return;
    try {
      await _tts.pause();
    } catch (e, st) {
      AppLog.warning('pause failed', name: 'TtsService', error: e, stackTrace: st);
    }
  }

  Future<void> stop() async {
    if (!_ready) return;
    try {
      await _tts.stop();
    } catch (e, st) {
      AppLog.warning('stop failed', name: 'TtsService', error: e, stackTrace: st);
    }
  }

  /// Sets speech rate in [0.0, 1.0] (slowest → fastest); 0.5 ≈ normal.
  Future<void> setRate(double rate) async {
    if (!_ready) return;
    try {
      await _tts.setSpeechRate(rate.clamp(0.0, 1.0));
    } catch (e, st) {
      AppLog.warning('setRate failed', name: 'TtsService', error: e, stackTrace: st);
    }
  }
}
