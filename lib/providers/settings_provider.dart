import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/enums.dart';
import '../services/settings_service.dart';

/// App-wide reactive settings. Drives theme + reader behavior; persists on
/// every change.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._service) : _settings = _service.load();

  final SettingsService _service;
  AppSettings _settings;

  AppSettings get settings => _settings;

  AppThemeMode get themeMode => _settings.themeMode;
  Locale get locale => Locale(_settings.localeCode);
  bool get soundEnabled => _settings.soundEnabled;
  double get soundVolume => _settings.soundVolume;
  bool get hapticsEnabled => _settings.hapticsEnabled;
  PageTint get pageTint => _settings.pageTint;
  bool get keepScreenOn => _settings.keepScreenOn;
  double get speechRate => _settings.speechRate;
  bool get autoDetectLanguage => _settings.autoDetectLanguage;
  String get devanagariLanguage => _settings.devanagariLanguage;
  Map<String, String> get voiceByLanguage => _settings.voiceByLanguage;
  bool get readScannedBooks => _settings.readScannedBooks;

  /// Maps the app theme mode to Flutter's [ThemeMode].
  ThemeMode get flutterThemeMode => switch (_settings.themeMode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.day => ThemeMode.light,
        AppThemeMode.night => ThemeMode.dark,
      };

  Future<void> _update(AppSettings next) async {
    if (next == _settings) return;
    _settings = next;
    notifyListeners();
    await _service.save(next);
  }

  Future<void> setThemeMode(AppThemeMode mode) =>
      _update(_settings.copyWith(themeMode: mode));

  /// Sets the app UI language. Persisted; [MaterialApp] rebuilds in the new
  /// locale immediately (no restart).
  Future<void> setLocale(Locale locale) =>
      _update(_settings.copyWith(localeCode: locale.languageCode));

  Future<void> setSoundEnabled(bool value) =>
      _update(_settings.copyWith(soundEnabled: value));

  Future<void> setSoundVolume(double value) =>
      _update(_settings.copyWith(soundVolume: value.clamp(0.0, 1.0)));

  Future<void> setHaptics(bool value) =>
      _update(_settings.copyWith(hapticsEnabled: value));

  Future<void> setPageTint(PageTint tint) =>
      _update(_settings.copyWith(pageTint: tint));

  Future<void> setKeepScreenOn(bool value) =>
      _update(_settings.copyWith(keepScreenOn: value));

  Future<void> setSpeechRate(double value) =>
      _update(_settings.copyWith(speechRate: value.clamp(0.0, 1.0)));

  Future<void> setAutoDetectLanguage(bool value) =>
      _update(_settings.copyWith(autoDetectLanguage: value));

  Future<void> setReadScannedBooks(bool value) =>
      _update(_settings.copyWith(readScannedBooks: value));

  Future<void> setDevanagariLanguage(String locale) =>
      _update(_settings.copyWith(devanagariLanguage: locale));

  /// Sets (or, with [voiceName] null, clears → auto-pick) the preferred voice
  /// for a language. Stored as a new map so equality/persistence trigger.
  Future<void> setVoiceForLanguage(String locale, String? voiceName) {
    final next = Map<String, String>.from(_settings.voiceByLanguage);
    if (voiceName == null) {
      next.remove(locale);
    } else {
      next[locale] = voiceName;
    }
    return _update(_settings.copyWith(voiceByLanguage: next));
  }
}
