import 'package:flutter/foundation.dart';

import 'enums.dart';

/// User-configurable app settings. Persisted to SharedPreferences as JSON.
class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.localeCode = 'en',
    this.soundEnabled = true,
    this.soundVolume = 0.7,
    this.hapticsEnabled = true,
    this.pageTint = PageTint.paper,
    this.keepScreenOn = true,
    this.speechRate = 0.5,
    this.autoDetectLanguage = true,
    this.devanagariLanguage = 'hi-IN',
    this.voiceByLanguage = const <String, String>{},
    this.readScannedBooks = true,
  });

  final AppThemeMode themeMode;

  /// Language for the app's UI text — a [Locale] languageCode (e.g. `'en'`,
  /// `'hi'`). Distinct from the read-aloud spoken language; this only controls
  /// the interface. Drives [MaterialApp.locale].
  final String localeCode;

  final bool soundEnabled;

  /// Page-turn sound volume in [0, 1].
  final double soundVolume;
  final bool hapticsEnabled;
  final PageTint pageTint;
  final bool keepScreenOn;

  /// Read-aloud speech rate in [0, 1] (slowest → fastest); 0.5 ≈ normal.
  final double speechRate;

  /// When true, read-aloud picks the spoken language from each page's script
  /// (so Hindi/Tamil/etc. pages use the right voice instead of English).
  final bool autoDetectLanguage;

  /// Which language Devanagari pages are read as — Hindi (`hi-IN`) or Marathi
  /// (`mr-IN`). They share a script, so detection alone can't tell them apart.
  final String devanagariLanguage;

  /// Per-language voice override: BCP-47 locale → engine voice name. Absent
  /// entries fall back to the best installed offline voice for that locale.
  final Map<String, String> voiceByLanguage;

  /// When true, read-aloud OCRs pages that have no text layer (scanned books)
  /// so they can still be read. Only runs on empty pages, so text PDFs are
  /// unaffected.
  final bool readScannedBooks;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? localeCode,
    bool? soundEnabled,
    double? soundVolume,
    bool? hapticsEnabled,
    PageTint? pageTint,
    bool? keepScreenOn,
    double? speechRate,
    bool? autoDetectLanguage,
    String? devanagariLanguage,
    Map<String, String>? voiceByLanguage,
    bool? readScannedBooks,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      pageTint: pageTint ?? this.pageTint,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      speechRate: speechRate ?? this.speechRate,
      autoDetectLanguage: autoDetectLanguage ?? this.autoDetectLanguage,
      devanagariLanguage: devanagariLanguage ?? this.devanagariLanguage,
      voiceByLanguage: voiceByLanguage ?? this.voiceByLanguage,
      readScannedBooks: readScannedBooks ?? this.readScannedBooks,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'themeMode': themeMode.name,
      'localeCode': localeCode,
      'soundEnabled': soundEnabled,
      'soundVolume': soundVolume,
      'hapticsEnabled': hapticsEnabled,
      'pageTint': pageTint.name,
      'keepScreenOn': keepScreenOn,
      'speechRate': speechRate,
      'autoDetectLanguage': autoDetectLanguage,
      'devanagariLanguage': devanagariLanguage,
      'voiceByLanguage': voiceByLanguage,
      'readScannedBooks': readScannedBooks,
    };
  }

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    return AppSettings(
      themeMode: _enumByName(
        AppThemeMode.values,
        map['themeMode'] as String?,
        AppThemeMode.system,
      ),
      localeCode: map['localeCode'] as String? ?? 'en',
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      soundVolume: (map['soundVolume'] as num?)?.toDouble() ?? 0.7,
      hapticsEnabled: map['hapticsEnabled'] as bool? ?? true,
      pageTint: _enumByName(
        PageTint.values,
        map['pageTint'] as String?,
        PageTint.paper,
      ),
      keepScreenOn: map['keepScreenOn'] as bool? ?? true,
      speechRate: (map['speechRate'] as num?)?.toDouble() ?? 0.5,
      autoDetectLanguage: map['autoDetectLanguage'] as bool? ?? true,
      devanagariLanguage: map['devanagariLanguage'] as String? ?? 'hi-IN',
      voiceByLanguage: _stringMap(map['voiceByLanguage']),
      readScannedBooks: map['readScannedBooks'] as bool? ?? true,
    );
  }

  /// Coerces a persisted JSON object back into a `Map<String, String>`,
  /// dropping any malformed entries.
  static Map<String, String> _stringMap(Object? raw) {
    if (raw is! Map) return const <String, String>{};
    final out = <String, String>{};
    raw.forEach((k, v) {
      if (k is String && v is String) out[k] = v;
    });
    return out;
  }

  static T _enumByName<T extends Enum>(
    List<T> values,
    String? name,
    T fallback,
  ) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return fallback;
  }

  @override
  bool operator ==(Object other) {
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.localeCode == localeCode &&
        other.soundEnabled == soundEnabled &&
        other.soundVolume == soundVolume &&
        other.hapticsEnabled == hapticsEnabled &&
        other.pageTint == pageTint &&
        other.keepScreenOn == keepScreenOn &&
        other.speechRate == speechRate &&
        other.autoDetectLanguage == autoDetectLanguage &&
        other.devanagariLanguage == devanagariLanguage &&
        mapEquals(other.voiceByLanguage, voiceByLanguage) &&
        other.readScannedBooks == readScannedBooks;
  }

  @override
  int get hashCode => Object.hash(
        themeMode,
        localeCode,
        soundEnabled,
        soundVolume,
        hapticsEnabled,
        pageTint,
        keepScreenOn,
        speechRate,
        autoDetectLanguage,
        devanagariLanguage,
        Object.hashAllUnordered(
          voiceByLanguage.entries.map((e) => Object.hash(e.key, e.value)),
        ),
        readScannedBooks,
      );
}
