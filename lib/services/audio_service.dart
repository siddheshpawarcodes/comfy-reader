import 'package:audioplayers/audioplayers.dart';

import '../core/constants/asset_paths.dart';
import '../core/utils/app_log.dart';

/// Low-latency page-turn sound. Preloaded once; replayed instantly on each
/// completed page turn (respecting the user's sound setting + volume).
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer(playerId: 'page_flip');
  bool _ready = false;

  /// Preloads the flip sound in low-latency mode. Call once at startup.
  Future<void> init() async {
    if (_ready) return;
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setPlayerMode(PlayerMode.lowLatency);
      await _player.setSource(AssetSource(AssetPaths.pageFlipSound));
      _ready = true;
    } catch (e, st) {
      AppLog.warning('init failed', name: 'AudioService', error: e, stackTrace: st);
    }
  }

  /// Plays the flip sound from the start if [enabled]. Non-blocking; failures
  /// are swallowed so a missing/unsupported asset never breaks page turns.
  Future<void> playPageTurn({
    required bool enabled,
    required double volume,
  }) async {
    if (!enabled || !_ready) return;
    try {
      await _player.setVolume(volume.clamp(0.0, 1.0));
      await _player.seek(Duration.zero);
      await _player.resume();
    } catch (e, st) {
      AppLog.warning('playPageTurn failed',
          name: 'AudioService', error: e, stackTrace: st);
    }
  }

  Future<void> dispose() => _player.dispose();
}
