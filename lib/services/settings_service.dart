import 'dart:convert';

import '../models/app_settings.dart';
import 'storage_service.dart';

/// Reads/writes [AppSettings] as a single JSON string in SharedPreferences.
class SettingsService {
  SettingsService(this._storage);

  final StorageService _storage;
  static const String _key = 'app_settings';

  AppSettings load() {
    final raw = _storage.prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const AppSettings();
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AppSettings.fromMap(map);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> save(AppSettings settings) {
    return _storage.prefs.setString(_key, jsonEncode(settings.toMap()));
  }
}
