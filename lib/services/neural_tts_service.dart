import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

import '../core/utils/app_log.dart';
import '../core/utils/app_paths.dart';

/// A downloadable, on-device neural voice (a sherpa-onnx VITS model). Used to
/// give Indian languages a natural voice the OS engine lacks — most importantly
/// Marathi, which most devices can't speak at all.
@immutable
class NeuralVoice {
  const NeuralVoice({
    required this.id,
    required this.locale,
    required this.name,
    required this.attribution,
    this.modelFile = 'model.onnx',
    this.tokensFile = 'tokens.txt',
    this.lexiconFile = 'lexicon.txt',
    this.dataDirName = 'espeak-ng-data',
    this.dictDirName = 'dict',
  });

  /// Folder name under `neural_voices/` (also the download id).
  final String id;

  /// BCP-47 locale this voice speaks (e.g. `mr-IN`).
  final String locale;
  final String name;

  /// Required CC-BY attribution string, surfaced in the licenses screen.
  final String attribution;

  // File/dir names inside the voice folder; only those present are used.
  final String modelFile;
  final String tokensFile;
  final String lexiconFile;
  final String dataDirName;
  final String dictDirName;

  String get languageSubtag => _subtag(locale);
}

String _subtag(String locale) => locale.toLowerCase().split(RegExp('[-_]')).first;

/// Neural voices the app knows about. Download URLs/sizes are added once a
/// converted model is hosted (see `tool/neural_voices/README.md`); until then a
/// voice is usable only when side-loaded into `neural_voices/<id>/`.
abstract final class NeuralVoiceCatalog {
  static const List<NeuralVoice> all = [
    NeuralVoice(
      id: 'ai4bharat-mr',
      locale: 'mr-IN',
      name: 'Marathi (AI4Bharat)',
      attribution: 'AI4Bharat vits_rasa_13, CC-BY-4.0',
    ),
    NeuralVoice(
      id: 'ai4bharat-hi',
      locale: 'hi-IN',
      name: 'Hindi (AI4Bharat)',
      attribution: 'AI4Bharat vits_rasa_13, CC-BY-4.0',
    ),
  ];

  static NeuralVoice? forLocale(String locale) {
    final sub = _subtag(locale);
    for (final v in all) {
      if (v.languageSubtag == sub) return v;
    }
    return null;
  }
}

/// Runs neural voices via sherpa-onnx, generating audio on-device and playing it
/// through an [AudioPlayer]. Mirrors [TtsService]'s callback shape
/// ([onComplete]/[onError]) so the read-aloud controller can drive either engine
/// uniformly.
///
/// This slice supports loading a (side-loaded) voice and speaking — enough to
/// preview a converted model on real hardware. Download management and full
/// controller routing build on top of it.
class NeuralTtsService {
  NeuralTtsService._();
  static final NeuralTtsService instance = NeuralTtsService._();

  bool _bindingsReady = false;
  bool _playerWired = false;
  sherpa.OfflineTts? _tts;
  String? _loadedVoiceId;

  final AudioPlayer _player = AudioPlayer();
  Directory? _tempDir;

  /// Bumped on stop/new utterance to discard a generation that's been superseded
  /// (generate is slow; the page may have moved on by the time it returns).
  int _utterance = 0;

  /// sherpa speed multiplier (1.0 ≈ normal); mapped from our 0–1 rate.
  double _speed = 1.0;

  /// Fired when playback of an utterance finishes — drives chunk/page advance.
  VoidCallback? onComplete;

  /// Fired on generation/playback error so the controller can recover.
  void Function(dynamic message)? onError;

  Directory get _root => Directory('${AppPaths.support.path}/neural_voices');
  Directory voiceDir(NeuralVoice v) => Directory('${_root.path}/${v.id}');

  /// True when the model file for [v] is present on disk.
  bool isInstalled(NeuralVoice v) =>
      File('${voiceDir(v).path}/${v.modelFile}').existsSync();

  /// The installed neural voice for [locale], or null if none is downloaded.
  NeuralVoice? installedVoiceFor(String locale) {
    final v = NeuralVoiceCatalog.forLocale(locale);
    if (v == null) return null;
    return isInstalled(v) ? v : null;
  }

  bool get isReady => _tts != null;

  /// Maps our 0–1 speech rate (0.5 ≈ normal) to sherpa's speed multiplier.
  void setRate(double rate) => _speed = (rate * 2).clamp(0.5, 2.0);

  /// Loads [v] into the engine (idempotent per voice). Returns false if the
  /// model isn't installed or the engine can't initialize.
  Future<bool> loadVoice(NeuralVoice v) async {
    if (_loadedVoiceId == v.id && _tts != null) return true;
    _ensureBindings();
    if (!_bindingsReady) return false;

    final dir = voiceDir(v).path;
    if (!File('$dir/${v.modelFile}').existsSync()) return false;
    try {
      _tts?.free();
      // Pass only the frontend files that exist (lexicon vs espeak data vs dict).
      String pathIf(String name, {bool isDir = false}) {
        final p = '$dir/$name';
        final exists = isDir ? Directory(p).existsSync() : File(p).existsSync();
        return exists ? p : '';
      }

      _tts = sherpa.OfflineTts(sherpa.OfflineTtsConfig(
        model: sherpa.OfflineTtsModelConfig(
          vits: sherpa.OfflineTtsVitsModelConfig(
            model: '$dir/${v.modelFile}',
            tokens: '$dir/${v.tokensFile}',
            lexicon: pathIf(v.lexiconFile),
            dataDir: pathIf(v.dataDirName, isDir: true),
            dictDir: pathIf(v.dictDirName, isDir: true),
          ),
          numThreads: 2,
        ),
      ));
      _loadedVoiceId = v.id;
      return true;
    } catch (e, st) {
      AppLog.warning('loadVoice(${v.id}) failed',
          name: 'NeuralTtsService', error: e, stackTrace: st);
      return false;
    }
  }

  /// Generates [text] and plays it. Fire-and-forget: completion arrives via
  /// [onComplete].
  Future<void> speak(String text) async {
    final tts = _tts;
    if (tts == null || text.isEmpty) return;
    final token = ++_utterance;
    try {
      // generate() is a blocking native call (~1s for a sentence). Acceptable
      // per-chunk; a future optimization is to run it off the platform thread.
      final audio = tts.generate(text: text, sid: 0, speed: _speed);
      if (token != _utterance) return; // superseded by stop()/next chunk

      final dir = _tempDir ??= await Directory.systemTemp.createTemp('comfy_ntts_');
      final path = '${dir.path}/u_$token.wav';
      final ok = sherpa.writeWave(
        filename: path,
        samples: audio.samples,
        sampleRate: audio.sampleRate,
      );
      if (!ok) {
        onError?.call('writeWave failed');
        return;
      }
      if (token != _utterance) return;
      await _player.stop();
      await _player.play(DeviceFileSource(path));
    } catch (e, st) {
      AppLog.warning('speak failed',
          name: 'NeuralTtsService', error: e, stackTrace: st);
      onError?.call(e);
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (_) {/* no-op */}
  }

  Future<void> stop() async {
    _utterance++; // invalidate any in-flight generation
    try {
      await _player.stop();
    } catch (_) {/* no-op */}
  }

  void _ensureBindings() {
    if (_bindingsReady) return;
    try {
      sherpa.initBindings();
      _bindingsReady = true;
    } catch (e, st) {
      AppLog.warning('initBindings failed',
          name: 'NeuralTtsService', error: e, stackTrace: st);
      return;
    }
    if (!_playerWired) {
      _player.onPlayerComplete.listen((_) => onComplete?.call());
      _playerWired = true;
    }
  }

  Future<void> dispose() async {
    _utterance++;
    _tts?.free();
    _tts = null;
    _loadedVoiceId = null;
    await _player.dispose();
  }
}
