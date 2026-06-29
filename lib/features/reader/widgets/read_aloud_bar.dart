import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

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
}
