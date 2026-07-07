import 'package:flutter/foundation.dart';

import 'storage_service.dart';

/// Tracks which one-time feature tours (showcase coach-marks) the user has
/// already seen. Stored as standalone SharedPreferences flags, deliberately
/// kept out of [AppSettings] so transient onboarding state stays separate from
/// real user preferences.
class TourService {
  TourService._();
  static final TourService instance = TourService._();

  static const String _prefix = 'tour_seen_';

  // Tour ids.
  static const String home = 'home';
  static const String settings = 'settings';
  static const String reader = 'reader';

  bool seen(String tourId) =>
      StorageService.instance.prefs.getBool('$_prefix$tourId') ?? false;

  Future<void> markSeen(String tourId) =>
      StorageService.instance.prefs.setBool('$_prefix$tourId', true);

  /// Clears every tour flag so all tours replay — backs "Take the tour again".
  Future<void> resetAll() async {
    final prefs = StorageService.instance.prefs;
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  VoidCallback? _pendingOnFinish;

  /// Registers a one-shot callback for the next time a tour finishes. Call
  /// this immediately before `ShowCaseWidget.of(context).startShowCase(...)`
  /// so it pairs with that specific tour — the app uses a single app-wide
  /// [ShowCaseWidget], so only one tour is ever in flight at a time.
  void runOnNextFinish(VoidCallback callback) => _pendingOnFinish = callback;

  /// Wired to `ShowCaseWidget.onFinish`; fires whichever tour is pending.
  void handleFinish() {
    final callback = _pendingOnFinish;
    _pendingOnFinish = null;
    callback?.call();
  }
}
