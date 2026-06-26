import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/durations.dart';
import '../../../core/theme/dimens.dart';
import '../../../models/enums.dart';
import '../../../providers/read_aloud_controller.dart';
import '../../../providers/reader_provider.dart';
import '../../../providers/settings_provider.dart';
import 'book_curl_view.dart';
import 'page_scrubber.dart';
import 'read_aloud_bar.dart';

/// Toggled reader chrome: a top bar (back, title, bookmark) and a bottom bar
/// (scrubber/Go-To, prev/next, brightness, tint, sound). Fades in/out with
/// [ReaderProvider.overlayVisible].
class ReaderOverlay extends StatelessWidget {
  const ReaderOverlay({
    super.key,
    required this.controller,
    required this.onBack,
    required this.onShowBookmarks,
    required this.brightness,
    required this.onBrightnessChanged,
  });

  final BookCurlController controller;
  final VoidCallback onBack;
  final VoidCallback onShowBookmarks;
  final double brightness;
  final ValueChanged<double> onBrightnessChanged;

  @override
  Widget build(BuildContext context) {
    final reader = context.watch<ReaderProvider>();
    final visible = reader.overlayVisible;
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: AppDurations.fast,
        child: Column(
          children: [
            _TopBar(onBack: onBack, onShowBookmarks: onShowBookmarks),
            const Spacer(),
            _BottomBar(
              controller: controller,
              brightness: brightness,
              onBrightnessChanged: onBrightnessChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack, required this.onShowBookmarks});

  final VoidCallback onBack;
  final VoidCallback onShowBookmarks;

  @override
  Widget build(BuildContext context) {
    final reader = context.watch<ReaderProvider>();
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.55),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back to library',
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              reader.book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
          ),
          IconButton(
            tooltip: 'Bookmarks',
            icon: const Icon(Icons.bookmarks_outlined, color: Colors.white),
            onPressed: onShowBookmarks,
          ),
          IconButton(
            tooltip: 'Bookmark this page',
            icon: Icon(
              reader.isCurrentBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: reader.isCurrentBookmarked
                  ? theme.colorScheme.tertiary
                  : Colors.white,
            ),
            onPressed: reader.toggleBookmark,
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.controller,
    required this.brightness,
    required this.onBrightnessChanged,
  });

  final BookCurlController controller;
  final double brightness;
  final ValueChanged<double> onBrightnessChanged;

  IconData _tintIcon(PageTint tint) => switch (tint) {
        PageTint.paper => Icons.wb_sunny_outlined,
        PageTint.sepia => Icons.coffee_rounded,
        PageTint.night => Icons.nightlight_round,
      };

  @override
  Widget build(BuildContext context) {
    final reader = context.watch<ReaderProvider>();
    final settings = context.watch<SettingsProvider>();
    return Container(
      padding: EdgeInsets.fromLTRB(
        Dimens.space4,
        Dimens.space3,
        Dimens.space4,
        MediaQuery.of(context).padding.bottom + Dimens.space2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.65),
            Colors.transparent,
          ],
        ),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.white),
        child: IconTheme.merge(
          data: const IconThemeData(color: Colors.white),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ReadAloudBar(),
              PageScrubber(
                book: reader.book,
                currentPage: reader.currentPage,
                onJump: (page) {
                  controller.jumpTo(page);
                  reader.onPageChanged(page);
                },
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Previous page',
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: controller.previous,
                  ),
                  const Icon(Icons.brightness_low_rounded, size: 18),
                  Expanded(
                    child: Semantics(
                      label: 'Screen brightness',
                      child: Slider(
                        value: brightness.clamp(0.0, 1.0),
                        onChanged: onBrightnessChanged,
                      ),
                    ),
                  ),
                  const Icon(Icons.brightness_high_rounded, size: 18),
                  IconButton(
                    tooltip: 'Next page',
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: controller.next,
                  ),
                ],
              ),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: Dimens.space4,
                children: [
                  TextButton.icon(
                    onPressed: reader.cycleTint,
                    icon: Icon(_tintIcon(reader.tint)),
                    label: Text(reader.tint.name),
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                  ),
                  Builder(builder: (context) {
                    final readAloud = context.watch<ReadAloudController>();
                    return IconButton(
                      tooltip: readAloud.isActive
                          ? (readAloud.isPlaying
                              ? 'Pause reading'
                              : 'Resume reading')
                          : 'Read aloud',
                      icon: Icon(
                        !readAloud.isActive
                            ? Icons.headphones_rounded
                            : (readAloud.isPlaying
                                ? Icons.pause_circle_rounded
                                : Icons.play_circle_rounded),
                      ),
                      onPressed: readAloud.toggle,
                    );
                  }),
                  IconButton(
                    tooltip: 'Page-turn sound',
                    icon: Icon(settings.soundEnabled
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded),
                    onPressed: () =>
                        settings.setSoundEnabled(!settings.soundEnabled),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
