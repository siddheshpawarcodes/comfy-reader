import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../core/constants/durations.dart';
import '../../../core/l10n/l10n_ext.dart';
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
/// [ReaderProvider.overlayVisible]. The `*ShowcaseKey`s anchor the first-run
/// feature tour onto the relevant controls.
class ReaderOverlay extends StatelessWidget {
  const ReaderOverlay({
    super.key,
    required this.controller,
    required this.onBack,
    required this.onShowBookmarks,
    required this.brightness,
    required this.onBrightnessChanged,
    required this.scrubberShowcaseKey,
    required this.readAloudShowcaseKey,
    required this.tintShowcaseKey,
    required this.brightnessShowcaseKey,
    required this.bookmarkShowcaseKey,
  });

  final BookCurlController controller;
  final VoidCallback onBack;
  final VoidCallback onShowBookmarks;
  final double brightness;
  final ValueChanged<double> onBrightnessChanged;
  final GlobalKey scrubberShowcaseKey;
  final GlobalKey readAloudShowcaseKey;
  final GlobalKey tintShowcaseKey;
  final GlobalKey brightnessShowcaseKey;
  final GlobalKey bookmarkShowcaseKey;

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
            _TopBar(
              onBack: onBack,
              onShowBookmarks: onShowBookmarks,
              bookmarkShowcaseKey: bookmarkShowcaseKey,
            ),
            const Spacer(),
            _BottomBar(
              controller: controller,
              brightness: brightness,
              onBrightnessChanged: onBrightnessChanged,
              scrubberShowcaseKey: scrubberShowcaseKey,
              readAloudShowcaseKey: readAloudShowcaseKey,
              tintShowcaseKey: tintShowcaseKey,
              brightnessShowcaseKey: brightnessShowcaseKey,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onBack,
    required this.onShowBookmarks,
    required this.bookmarkShowcaseKey,
  });

  final VoidCallback onBack;
  final VoidCallback onShowBookmarks;
  final GlobalKey bookmarkShowcaseKey;

  @override
  Widget build(BuildContext context) {
    final reader = context.watch<ReaderProvider>();
    final theme = Theme.of(context);
    final l10n = context.l10n;
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
            tooltip: l10n.backToLibrary,
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
            tooltip: l10n.bookmarksTooltip,
            icon: const Icon(Icons.bookmarks_outlined, color: Colors.white),
            onPressed: onShowBookmarks,
          ),
          Showcase(
            key: bookmarkShowcaseKey,
            title: l10n.tourBookmarkTitle,
            description: l10n.tourBookmarkBody,
            targetPadding: const EdgeInsets.all(6),
            child: IconButton(
              tooltip: l10n.bookmarkThisPage,
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
    required this.scrubberShowcaseKey,
    required this.readAloudShowcaseKey,
    required this.tintShowcaseKey,
    required this.brightnessShowcaseKey,
  });

  final BookCurlController controller;
  final double brightness;
  final ValueChanged<double> onBrightnessChanged;
  final GlobalKey scrubberShowcaseKey;
  final GlobalKey readAloudShowcaseKey;
  final GlobalKey tintShowcaseKey;
  final GlobalKey brightnessShowcaseKey;

  IconData _tintIcon(PageTint tint) => switch (tint) {
        PageTint.paper => Icons.wb_sunny_outlined,
        PageTint.sepia => Icons.coffee_rounded,
        PageTint.night => Icons.nightlight_round,
      };

  String _tintLabel(BuildContext context, PageTint tint) => switch (tint) {
        PageTint.paper => context.l10n.tintPaper,
        PageTint.sepia => context.l10n.tintSepia,
        PageTint.night => context.l10n.tintNight,
      };

  @override
  Widget build(BuildContext context) {
    final reader = context.watch<ReaderProvider>();
    final settings = context.watch<SettingsProvider>();
    final l10n = context.l10n;
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
              Showcase(
                key: scrubberShowcaseKey,
                title: l10n.tourScrubberTitle,
                description: l10n.tourScrubberBody,
                child: PageScrubber(
                  book: reader.book,
                  currentPage: reader.currentPage,
                  onJump: (page) {
                    controller.jumpTo(page);
                    reader.onPageChanged(page);
                  },
                ),
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: l10n.previousPage,
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: controller.previous,
                  ),
                  // Showcase the whole brightness group (icons + slider) — a
                  // wide, reliable highlight target rather than the thin slider.
                  Expanded(
                    child: Showcase(
                      key: brightnessShowcaseKey,
                      title: l10n.tourBrightnessTitle,
                      description: l10n.tourBrightnessBody,
                      targetPadding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.brightness_low_rounded, size: 18),
                          Expanded(
                            child: Semantics(
                              label: l10n.screenBrightness,
                              child: Slider(
                                value: brightness.clamp(0.0, 1.0),
                                onChanged: onBrightnessChanged,
                              ),
                            ),
                          ),
                          const Icon(Icons.brightness_high_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.nextPage,
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
                  Showcase(
                    key: tintShowcaseKey,
                    title: l10n.tourReaderTintTitle,
                    description: l10n.tourReaderTintBody,
                    child: TextButton.icon(
                      onPressed: reader.cycleTint,
                      icon: Icon(_tintIcon(reader.tint)),
                      label: Text(_tintLabel(context, reader.tint)),
                      style:
                          TextButton.styleFrom(foregroundColor: Colors.white),
                    ),
                  ),
                  Builder(builder: (context) {
                    final readAloud = context.watch<ReadAloudController>();
                    return Showcase(
                      key: readAloudShowcaseKey,
                      title: l10n.tourReadAloudTitle,
                      description: l10n.tourReadAloudBody,
                      child: IconButton(
                        tooltip: readAloud.isActive
                            ? (readAloud.isPlaying
                                ? l10n.pauseReading
                                : l10n.resumeReading)
                            : l10n.readAloud,
                        icon: Icon(
                          !readAloud.isActive
                              ? Icons.headphones_rounded
                              : (readAloud.isPlaying
                                  ? Icons.pause_circle_rounded
                                  : Icons.play_circle_rounded),
                        ),
                        onPressed: readAloud.toggle,
                      ),
                    );
                  }),
                  IconButton(
                    tooltip: l10n.pageTurnSound,
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
