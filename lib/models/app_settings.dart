import 'enums.dart';

/// User-configurable app settings. Persisted to SharedPreferences as JSON.
class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.soundEnabled = true,
    this.soundVolume = 0.7,
    this.hapticsEnabled = true,
    this.pageTint = PageTint.paper,
    this.keepScreenOn = true,
    this.speechRate = 0.5,
  });

  final AppThemeMode themeMode;
  final bool soundEnabled;

  /// Page-turn sound volume in [0, 1].
  final double soundVolume;
  final bool hapticsEnabled;
  final PageTint pageTint;
  final bool keepScreenOn;

  /// Read-aloud speech rate in [0, 1] (slowest → fastest); 0.5 ≈ normal.
  final double speechRate;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? soundEnabled,
    double? soundVolume,
    bool? hapticsEnabled,
    PageTint? pageTint,
    bool? keepScreenOn,
    double? speechRate,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      pageTint: pageTint ?? this.pageTint,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      speechRate: speechRate ?? this.speechRate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'themeMode': themeMode.name,
      'soundEnabled': soundEnabled,
      'soundVolume': soundVolume,
      'hapticsEnabled': hapticsEnabled,
      'pageTint': pageTint.name,
      'keepScreenOn': keepScreenOn,
      'speechRate': speechRate,
    };
  }

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    return AppSettings(
      themeMode: _enumByName(
        AppThemeMode.values,
        map['themeMode'] as String?,
        AppThemeMode.system,
      ),
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
    );
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
        other.soundEnabled == soundEnabled &&
        other.soundVolume == soundVolume &&
        other.hapticsEnabled == hapticsEnabled &&
        other.pageTint == pageTint &&
        other.keepScreenOn == keepScreenOn &&
        other.speechRate == speechRate;
  }

  @override
  int get hashCode => Object.hash(
        themeMode,
        soundEnabled,
        soundVolume,
        hapticsEnabled,
        pageTint,
        keepScreenOn,
        speechRate,
      );
}
