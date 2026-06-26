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
  bool get soundEnabled => _settings.soundEnabled;
  double get soundVolume => _settings.soundVolume;
  bool get hapticsEnabled => _settings.hapticsEnabled;
  PageTint get pageTint => _settings.pageTint;
  bool get keepScreenOn => _settings.keepScreenOn;
  double get speechRate => _settings.speechRate;

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
}
