import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/read_aloud_languages.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/dimens.dart';
import '../../../providers/read_aloud_controller.dart';
import '../../../providers/settings_provider.dart';

/// Slim read-aloud control surface inside the reader chrome, shown only while
/// read-aloud is active. Status line + play/pause + stop, with a speed slider.
/// Inherits the overlay's white-on-gradient styling from [ReaderOverlay].
class ReadAloudBar extends StatelessWidget {
  const ReadAloudBar({super.key});

  @override
  Widget build(BuildContext context) {
    final readAloud = context.watch<ReadAloudController>();
    if (!readAloud.isActive) return const SizedBox.shrink();

    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimens.space2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.headphones_rounded, size: 18),
              Dimens.space2.horizontalSpace,
              Expanded(
                child: Text(
                  readAloud.statusLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.white),
                ),
              ),
              IconButton(
                tooltip: 'Reading language',
                icon: Icon(
                  Icons.translate_rounded,
                  color: readAloud.forcedLocale != null
                      ? theme.colorScheme.tertiary
                      : null,
                ),
                onPressed: () => _pickLanguage(context, readAloud),
              ),
              IconButton(
                tooltip: readAloud.isPlaying ? l10n.pause : l10n.play,
                icon: Icon(
                  readAloud.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                ),
                onPressed: readAloud.toggle,
              ),
              IconButton(
                tooltip: l10n.stopReading,
                icon: const Icon(Icons.stop_rounded),
                onPressed: readAloud.stop,
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.slow_motion_video_rounded, size: 18),
              Expanded(
                child: Semantics(
                  label: l10n.readAloudSpeed,
                  child: Slider(
                    value: settings.speechRate,
                    divisions: 10,
                    label: '${(settings.speechRate * 100).round()}%',
                    onChanged: (v) {
                      // Persist the preference and apply it to the live engine.
                      context.read<SettingsProvider>().setSpeechRate(v);
                      readAloud.setRate(v);
                    },
                  ),
                ),
              ),
              const Icon(Icons.speed_rounded, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  /// Opens the "what language is this text" sheet and applies the pick as a
  /// one-off override for this reading session (not persisted).
  Future<void> _pickLanguage(
    BuildContext context,
    ReadAloudController readAloud,
  ) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (context) => _LanguagePickerSheet(selected: readAloud.forcedLocale),
    );
    // `''` means "Auto-detect"; `null` means the sheet was dismissed untouched.
    if (result == null) return;
    readAloud.setForcedLocale(result.isEmpty ? null : result);
  }
}

/// Bottom sheet listing "Auto-detect" plus every read-aloud language, so the
/// user can tell read-aloud what the current book's text actually is when
/// detection guesses wrong (e.g. mixed-script or short pages).
class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet({required this.selected});

  final String? selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = selected ?? '';
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimens.space4,
              0,
              Dimens.space4,
              Dimens.space2,
            ),
            child: Text('This text is in…', style: theme.textTheme.titleMedium),
          ),
          CheckboxListTile(
            value: current == '',
            title: const Text('Auto-detect'),
            subtitle: const Text('Choose the voice from each page’s script'),
            onChanged: (_) => Navigator.of(context).pop(''),
          ),
          for (final lang in readAloudLanguages)
            CheckboxListTile(
              value: current == lang.locale,
              title: Text(lang.name),
              onChanged: (_) => Navigator.of(context).pop(lang.locale),
            ),
        ],
      ),
    );
  }
}
