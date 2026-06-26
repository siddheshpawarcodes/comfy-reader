import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Severity of a log record, ordered low → high.
enum LogLevel { debug, info, warning, error }

/// App-wide logging facade.
///
/// Routes through `dart:developer`'s [developer.log] so records surface in the
/// DevTools "Logging" view carrying their level, subsystem [name], and (for
/// failures) the [Object] error plus [StackTrace] — none of which `debugPrint`
/// preserves.
///
/// Release behavior: `debug`/`info` records are dropped (no console spam, no
/// cost), while `warning`/`error` still flow through so an attached log
/// collector or a future crash reporter can pick them up — wire one in via
/// [onRecord].
abstract final class AppLog {
  /// `dart:developer` level values (loosely RFC 5424): FINE/INFO/WARNING/SEVERE.
  static const Map<LogLevel, int> _levelValue = <LogLevel, int>{
    LogLevel.debug: 500,
    LogLevel.info: 800,
    LogLevel.warning: 900,
    LogLevel.error: 1000,
  };

  /// Optional sink for log records — point this at Crashlytics/Sentry from
  /// `main()` when crash reporting is added (filter by [level] there). Invoked
  /// for every record that isn't dropped by the release gate; never throws back
  /// into the caller.
  static void Function(
    LogLevel level,
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  })? onRecord;

  /// Fine-grained diagnostic noise; dropped in release builds.
  static void debug(String message, {String? name}) =>
      _log(LogLevel.debug, message, name: name);

  /// Notable but expected lifecycle events; dropped in release builds.
  static void info(String message, {String? name}) =>
      _log(LogLevel.info, message, name: name);

  /// A recoverable problem — kept in release builds.
  static void warning(
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(LogLevel.warning, message,
          name: name, error: error, stackTrace: stackTrace);

  /// A failure worth investigating — kept in release builds.
  static void error(
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(LogLevel.error, message,
          name: name, error: error, stackTrace: stackTrace);

  static void _log(
    LogLevel level,
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Drop debug/info noise from release builds; keep warning/error so they can
    // reach a collector.
    if (kReleaseMode && level.index < LogLevel.warning.index) return;

    developer.log(
      message,
      name: name ?? 'comfy_reader',
      level: _levelValue[level]!,
      error: error,
      stackTrace: stackTrace,
    );

    final sink = onRecord;
    if (sink != null) {
      try {
        sink(level, message, name: name, error: error, stackTrace: stackTrace);
      } catch (_) {
        // A failing log sink must never break the app.
      }
    }
  }
}
