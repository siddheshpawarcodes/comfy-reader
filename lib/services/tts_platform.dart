import 'package:flutter/services.dart';

import '../core/utils/app_log.dart';

/// Bridges to native TTS actions that `flutter_tts` doesn't expose — currently
/// Android's "install voice data" / "TTS settings" intents, so users can
/// download additional offline Indian-language voices.
///
/// Every call is best-effort: it returns `false` (rather than throwing) when
/// the platform has no handler — notably on iOS, where there is no public API
/// to open the Voices screen, so the UI guides the user manually instead.
abstract final class TtsPlatform {
  static const MethodChannel _channel = MethodChannel('comfy_reader/tts');

  /// Prompts the system to download missing voice data, falling back to the
  /// TTS settings page. Returns whether something was launched.
  static Future<bool> installTtsData() => _invoke('installTtsData');

  /// Opens the system text-to-speech settings (engine + voice management).
  static Future<bool> openTtsSettings() => _invoke('openTtsSettings');

  static Future<bool> _invoke(String method) async {
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
    } on MissingPluginException {
      return false; // no native handler (e.g. iOS)
    } catch (e, st) {
      AppLog.warning('$method failed',
          name: 'TtsPlatform', error: e, stackTrace: st);
      return false;
    }
  }
}
