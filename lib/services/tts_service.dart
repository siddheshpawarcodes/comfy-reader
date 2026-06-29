import 'dart:io' show InternetAddress, Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../core/utils/app_log.dart';

/// A single installed TTS voice, normalized from the engine's raw voice map.
@immutable
class TtsVoice {
  const TtsVoice({
    required this.name,
    required this.locale,
    required this.offline,
    required this.quality,
  });

  /// Engine-specific voice id (passed back to `setVoice`).
  final String name;

  /// BCP-47 locale this voice speaks (e.g. `hi-IN`).
  final String locale;

  /// True when the voice synthesizes on-device (no network needed).
  final bool offline;

  /// Relative quality 0–500 (higher is better); see [_qualityScore].
  final int quality;

  /// The selection key flutter_tts expects from `setVoice`.
  Map<String, String> get selector => {'name': name, 'locale': locale};

  /// The primary language subtag, lowercased (e.g. `hi` from `hi-IN`).
  String get languageSubtag => TtsService.languageSubtag(locale);
}

/// Thin boundary over the OS-native text-to-speech engine (offline, no API
/// keys). Mirrors [AudioService]: a singleton initialized once in `main()`.
///
/// Orchestration (chunking, page auto-advance) lives in `ReadAloudController`;
/// this class owns the platform channel, picks the best installed voice per
/// language, and forwards engine events to whatever callbacks the active
/// controller has bound via [onComplete] / [onError].
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  /// The language currently applied to the engine — avoids redundant
  /// `setLanguage`/`setVoice` calls when reading consecutive same-language pages.
  String? _currentLanguage;
  String? _currentVoiceName;

  /// Cached voice list (enumerating voices is comparatively expensive).
  List<TtsVoice>? _voicesCache;

  /// Cached connectivity probe (see [_isOnline]) — avoids a DNS lookup per page.
  DateTime? _onlineCheckedAt;
  bool _onlineCached = false;

  /// Fired when the current utterance finishes — drives chunk/page advance.
  VoidCallback? onComplete;

  /// Fired on engine error so the controller can recover (skip / surface).
  void Function(dynamic message)? onError;

  /// Preloads the engine and wires the event handlers once. Safe to call again.
  Future<void> init() async {
    if (_ready) return;
    try {
      // On Android, prefer Google's engine — it has by far the broadest offline
      // Indian-language voice coverage. Harmless/no-op on other platforms.
      if (Platform.isAndroid) {
        try {
          final engines = await _tts.getEngines;
          if (engines is List &&
              engines.contains('com.google.android.tts')) {
            await _tts.setEngine('com.google.android.tts');
          }
        } catch (_) {/* keep default engine */}
      }
      await _tts.setLanguage('en-US');
      _currentLanguage = 'en-US';
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

  /// Switches the engine to [locale] and selects the best voice for it: the
  /// caller's [preferredVoiceName] if still installed, else the highest-quality
  /// offline voice.
  ///
  /// When [locale] has **no offline voice** but [fallbackLocale] does, the
  /// fallback is used instead — e.g. Marathi (`mr-IN`) → Hindi (`hi-IN`): they
  /// share the Devanagari script, so a Hindi voice reads Marathi intelligibly,
  /// which beats a broken/absent Marathi voice. No-ops when nothing changed.
  Future<void> applyLanguage(
    String locale, {
    String? preferredVoiceName,
    String? fallbackLocale,
  }) async {
    if (!_ready) return;
    try {
      final all = await _voices();
      final localeCands =
          all.where((v) => v.languageSubtag == languageSubtag(locale)).toList();

      TtsVoice? chosen;
      var targetLocale = locale;

      // 0. Honor the user's explicit pick — if offline, or network + online.
      if (preferredVoiceName != null) {
        for (final v in localeCands) {
          if (v.name == preferredVoiceName) {
            if (v.offline || await _isOnline()) chosen = v;
            break;
          }
        }
      }
      // 1. Best offline voice for the requested locale (no network needed).
      chosen ??= _pickBest(localeCands, offlineOnly: true);
      // 2. No offline voice → fall back to a sibling locale's OFFLINE voice
      //    first (Marathi → Hindi: shared Devanagari reads intelligibly). This is
      //    preferred over a network voice because the device's network voices
      //    (e.g. Google's network Marathi) error out and spell characters.
      if (chosen == null && fallbackLocale != null) {
        final fb = _pickBest(
          all.where((v) => v.languageSubtag == languageSubtag(fallbackLocale)),
          offlineOnly: true,
        );
        if (fb != null) {
          chosen = fb;
          targetLocale = fallbackLocale;
        }
      }
      // 3. Still nothing offline (no fallback either) → use a network voice if
      //    online (the only option for languages with no offline voice and no
      //    sibling, e.g. Tamil on a device without Tamil data).
      if (chosen == null) {
        final net = _pickBest(localeCands, offlineOnly: false);
        if (net != null && await _isOnline()) chosen = net;
      }
      // 4. Last resort: any voice for the locale (let the engine try), else the
      //    engine default.
      chosen ??= _pickBest(localeCands, offlineOnly: false);

      if (targetLocale == _currentLanguage &&
          chosen?.name == _currentVoiceName) {
        return; // nothing changed since last page
      }

      await _tts.setLanguage(targetLocale);
      _currentLanguage = targetLocale;
      if (chosen != null) {
        await _tts.setVoice(chosen.selector);
        _currentVoiceName = chosen.name;
      } else {
        _currentVoiceName = null;
      }
      AppLog.info(
        'speak $locale${targetLocale != locale ? ' → $targetLocale (fallback)' : ''} '
        'voice=${chosen?.name ?? '(engine default)'} offline=${chosen?.offline}',
        name: 'TtsService',
      );
    } catch (e, st) {
      AppLog.warning('applyLanguage($locale) failed',
          name: 'TtsService', error: e, stackTrace: st);
    }
  }

  /// Best voice among [candidates] by quality (offline ranked highest via the
  /// score). With [offlineOnly], network voices are excluded entirely.
  static TtsVoice? _pickBest(
    Iterable<TtsVoice> candidates, {
    required bool offlineOnly,
  }) {
    TtsVoice? best;
    var bestScore = -1;
    for (final v in candidates) {
      if (offlineOnly && !v.offline) continue;
      final score = _qualityScore(v);
      if (score > bestScore) {
        bestScore = score;
        best = v;
      }
    }
    return best;
  }

  /// Cheap connectivity probe (cached ~10s) deciding whether a network-only
  /// voice is worth selecting. A DNS lookup is enough — if a host resolves, the
  /// engine's network voice can reach its server. Defaults to offline on error.
  Future<bool> _isOnline() async {
    final now = DateTime.now();
    final last = _onlineCheckedAt;
    if (last != null && now.difference(last) < const Duration(seconds: 10)) {
      return _onlineCached;
    }
    try {
      final res = await InternetAddress.lookup('one.one.one.one')
          .timeout(const Duration(seconds: 2));
      _onlineCached = res.isNotEmpty && res.first.rawAddress.isNotEmpty;
    } catch (_) {
      _onlineCached = false;
    }
    _onlineCheckedAt = now;
    return _onlineCached;
  }

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

  // ---- Enumeration (for the Voices settings screen) ----

  /// All installed voices, grouped/normalized. Cached after the first call;
  /// pass [refresh] to re-query after the user installs new voice data.
  Future<List<TtsVoice>> voices({bool refresh = false}) =>
      _voices(refresh: refresh);

  /// Installed voices for a given primary language subtag (e.g. `hi`), best
  /// first.
  Future<List<TtsVoice>> voicesForLanguage(String localeOrSubtag,
      {bool refresh = false}) async {
    final sub = languageSubtag(localeOrSubtag);
    final all = await _voices(refresh: refresh);
    final matches = all.where((v) => v.languageSubtag == sub).toList()
      ..sort((a, b) => _qualityScore(b).compareTo(_qualityScore(a)));
    return matches;
  }

  /// Whether the engine reports any support (installed or downloadable) for
  /// [locale]. Used to flag "needs download" in the UI.
  Future<bool> isLanguageAvailable(String locale) async {
    if (!_ready) return false;
    try {
      final res = await _tts.isLanguageAvailable(locale);
      return res == true;
    } catch (_) {
      return false;
    }
  }

  /// Drops the cached voice list so the next query re-reads from the engine
  /// (call after returning from the system "install voice data" flow).
  void invalidateVoices() => _voicesCache = null;

  // ---- Internals ----

  Future<List<TtsVoice>> _voices({bool refresh = false}) async {
    if (!refresh && _voicesCache != null) return _voicesCache!;
    if (!_ready) return const [];
    try {
      final raw = await _tts.getVoices;
      final list = <TtsVoice>[];
      if (raw is List) {
        for (final item in raw) {
          if (item is! Map) continue;
          final map = item.map((k, v) => MapEntry('$k', '$v'));
          final name = map['name'];
          final locale = map['locale'];
          if (name == null || locale == null || locale.isEmpty) continue;
          list.add(TtsVoice(
            name: name,
            locale: locale,
            offline: _isOffline(map),
            quality: _parseQuality(map['quality']),
          ));
        }
      }
      _voicesCache = list;
      return list;
    } catch (e, st) {
      AppLog.warning('getVoices failed',
          name: 'TtsService', error: e, stackTrace: st);
      return const [];
    }
  }

  /// Ranks a voice: offline voices win decisively (a robotic-but-present
  /// offline voice beats a network voice that silently fails offline), then by
  /// quality.
  static int _qualityScore(TtsVoice v) => (v.offline ? 1000 : 0) + v.quality;

  /// Whether a voice can synthesize **on-device right now**. Reads the Android
  /// `network_required` / `features` keys; iOS voices are always on-device (keys
  /// absent → true).
  ///
  /// Critically, a voice whose data isn't downloaded yet (`notInstalled`
  /// feature) is *listed* but can't actually speak — selecting it makes the
  /// engine spell out characters. Treat it as unusable so we fall back instead.
  static bool _isOffline(Map<String, String> map) {
    final features = map['features']?.toLowerCase() ?? '';
    if (features.contains('notinstalled')) return false;
    final networkRequired = map['network_required']?.toLowerCase();
    if (networkRequired == 'true' || networkRequired == '1') return false;
    if (features.contains('networksynthesis') &&
        !features.contains('embeddedsynthesis')) {
      return false;
    }
    return true;
  }

  /// Normalizes the engine's `quality` value (Android numeric 100–500, or iOS
  /// `default`/`enhanced`/`premium`) to a 0–500 scale.
  static int _parseQuality(String? raw) {
    if (raw == null) return 300;
    final n = int.tryParse(raw.trim());
    if (n != null) return n;
    switch (raw.toLowerCase()) {
      case 'premium':
      case 'very_high':
        return 500;
      case 'enhanced':
      case 'high':
        return 400;
      case 'normal':
      case 'default':
        return 300;
      case 'low':
        return 200;
      case 'very_low':
        return 100;
      default:
        return 300;
    }
  }

  /// The primary language subtag, lowercased: `hi-IN` → `hi`, `eng-USA` →
  /// `eng`. Splits on both `-` and `_` (engines use either).
  static String languageSubtag(String locale) =>
      locale.toLowerCase().split(RegExp('[-_]')).first;
}
