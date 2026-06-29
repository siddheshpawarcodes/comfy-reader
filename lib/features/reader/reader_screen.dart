import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../models/enums.dart';
import '../../providers/library_provider.dart';
import '../../providers/read_aloud_controller.dart';
import '../../providers/reader_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/audio_service.dart';
import '../../services/tour_service.dart';
import 'widgets/book_curl_view.dart';
import 'widgets/reader_overlay.dart';

/// The reading experience: immersive full-screen 3D page-curl over rasterized
/// PDF pages, with audio + haptic turns, overlay chrome, tint, brightness, and
/// resume.
class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key, required this.bookId});

  final String bookId;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with WidgetsBindingObserver {
  ReaderProvider? _reader;
  ReadAloudController? _readAloud;
  final BookCurlController _curl = BookCurlController();
  double _brightness = 0.5;
  bool _brightnessTouched = false;

  // Reader feature-tour coach-mark anchors.
  final _tourScrubberKey = GlobalKey();
  final _tourReadAloudKey = GlobalKey();
  final _tourTintKey = GlobalKey();
  final _tourBrightnessKey = GlobalKey();
  final _tourBookmarkKey = GlobalKey();
  bool _readerTourScheduled = false;

  /// On the first-ever reader open, reveal the controls and run the feature
  /// tour. Two post-frames: one so [toggleOverlay] makes the chrome visible,
  /// the next so the coach-mark targets are laid out before highlighting.
  void _maybeStartReaderTour(ReaderProvider reader) {
    if (_readerTourScheduled || TourService.instance.seen(TourService.reader)) {
      return;
    }
    _readerTourScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!reader.overlayVisible) reader.toggleOverlay();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        TourService.instance.markSeen(TourService.reader);
        ShowCaseWidget.of(context).startShowCase([
          _tourScrubberKey,
          _tourReadAloudKey,
          _tourTintKey,
          _tourBrightnessKey,
          _tourBookmarkKey,
        ]);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final library = context.read<LibraryProvider>();
    final settings = context.read<SettingsProvider>();
    final book = library.bookById(widget.bookId);
    if (book != null) {
      _reader = ReaderProvider(
        book: book,
        library: library,
        initialTint: settings.pageTint,
      );
      _readAloud = ReadAloudController(
        filePath: book.filePath,
        reader: _reader!,
        curl: _curl,
        initialRate: settings.speechRate,
        autoDetectLanguage: settings.autoDetectLanguage,
        devanagariLanguage: settings.devanagariLanguage,
        voiceByLanguage: settings.voiceByLanguage,
        readScannedBooks: settings.readScannedBooks,
      );
      library.markOpened(book.id);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      if (settings.keepScreenOn) WakelockPlus.enable();
      _initBrightness();
      // Validate the document; surfaces a friendly error if it can't be opened.
      _reader!.init();
    }
  }

  Future<void> _initBrightness() async {
    try {
      final b = await ScreenBrightness().application;
      if (mounted) setState(() => _brightness = b);
    } catch (_) {/* keep default */}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _reader?.saveNow();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WakelockPlus.disable();
    if (_brightnessTouched) {
      ScreenBrightness().resetApplicationScreenBrightness();
    }
    // Dispose read-aloud first so it unbinds its reader listener and stops TTS
    // before the reader itself goes away.
    _readAloud?.dispose();
    _reader?.dispose();
    super.dispose();
  }

  void _onBrightnessChanged(double v) {
    setState(() {
      _brightness = v;
      _brightnessTouched = true;
    });
    ScreenBrightness().setApplicationScreenBrightness(v);
  }

  void _onPageTurn(int page) {
    final reader = _reader!;
    if (page == reader.currentPage) return;
    reader.onPageChanged(page);
    final settings = context.read<SettingsProvider>();
    AudioService.instance.playPageTurn(
      enabled: settings.soundEnabled,
      volume: settings.soundVolume,
    );
    if (settings.hapticsEnabled) HapticFeedback.lightImpact();
  }

  // ---- Tint ----
  Color _bgColor(PageTint tint) => switch (tint) {
        PageTint.paper => AppColors.readingPaper,
        PageTint.sepia => AppColors.readingSepia,
        PageTint.night => AppColors.readingNight,
      };

  Widget _applyTint(Widget child, PageTint tint) {
    switch (tint) {
      case PageTint.paper:
        return ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Color(0xFFF7EFE0),
            BlendMode.multiply,
          ),
          child: child,
        );
      case PageTint.sepia:
        return ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Color(0xFFE9D6AE),
            BlendMode.multiply,
          ),
          child: child,
        );
      case PageTint.night:
        // Invert luminance: white page -> dark, dark text -> light.
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            -0.85, 0, 0, 0, 230, //
            0, -0.85, 0, 0, 222, //
            0, 0, -0.85, 0, 200, //
            0, 0, 0, 1, 0, //
          ]),
          child: child,
        );
    }
  }

  /// Hero flight: render the book cover image expanding from the library
  /// card's rounded tile to the full-screen reader (corners straightening).
  Widget _coverFlightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final reader = _reader!;
    final cover = reader.book.coverImagePath;
    final radius = Tween<double>(begin: Dimens.radiusSmall, end: 0)
        .chain(CurveTween(curve: Curves.easeOutCubic))
        .animate(animation);
    final hasCover = cover != null && File(cover).existsSync();
    return AnimatedBuilder(
      animation: radius,
      builder: (context, _) => ClipRRect(
        borderRadius: BorderRadius.circular(radius.value),
        child: hasCover
            ? Image.file(File(cover), fit: BoxFit.cover, gaplessPlayback: true)
            : ColoredBox(color: _bgColor(reader.tint)),
      ),
    );
  }

  /// Shown while probing the document: the cover (if any) under a soft spinner.
  Widget _coverLoadingView(ReaderProvider reader) {
    final cover = reader.book.coverImagePath;
    final hasCover = cover != null && File(cover).existsSync();
    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasCover)
          Image.file(File(cover), fit: BoxFit.cover, gaplessPlayback: true)
        else
          ColoredBox(color: _bgColor(reader.tint)),
        Center(
          child: SizedBox(
            width: 28.r,
            height: 28.r,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  /// Friendly, recoverable error when the document can't be opened (missing,
  /// password-protected, or corrupt).
  Widget _errorView(ReaderProvider reader) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Dimens.space6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Icon(
              Icons.menu_book_rounded,
              size: 56,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            Dimens.space4.verticalSpace,
            Text(
              l10n.cantOpenBook,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            Dimens.space2.verticalSpace,
            Text(
              reader.errorMessage ?? l10n.somethingWentWrong,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(l10n.goBack),
            ),
            Dimens.space4.verticalSpace,
          ],
        ),
      ),
    );
  }

  void _showBookmarks() {
    final reader = _reader!;
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListenableBuilder(
        listenable: reader,
        builder: (context, _) {
          final pages = reader.bookmarkedPages;
          if (pages.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(Dimens.space6),
              child: Text(l10n.noBookmarks),
            );
          }
          return ListView(
            shrinkWrap: true,
            children: [
              for (final p in pages)
                ListTile(
                  leading: const Icon(Icons.bookmark_rounded),
                  title: Text(l10n.pageNumber(p + 1)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _curl.jumpTo(p);
                    reader.onPageChanged(p);
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reader = _reader;
    if (reader == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(context.l10n.bookNotFound)),
      );
    }
    final mq = MediaQuery.of(context);
    final targetWidth =
        (mq.size.width * mq.devicePixelRatio).round().clamp(400, 1600);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ReaderProvider>.value(value: reader),
        ChangeNotifierProvider<ReadAloudController>.value(value: _readAloud!),
      ],
      child: Consumer<ReaderProvider>(
        builder: (context, reader, _) {
          if (reader.status == ReaderStatus.ready) {
            _maybeStartReaderTour(reader);
          }
          return Scaffold(
            backgroundColor: _bgColor(reader.tint),
            body: switch (reader.status) {
              ReaderStatus.error => _errorView(reader),
              // Keep the cover Hero present while probing so the cover→reader
              // flight still completes; the cover stays visible under a spinner.
              ReaderStatus.loading => Hero(
                  tag: 'cover_${reader.book.id}',
                  flightShuttleBuilder: _coverFlightShuttle,
                  child: _coverLoadingView(reader),
                ),
              ReaderStatus.ready => Stack(
                  children: [
                    Positioned.fill(
                      // Hero shares the tapped library cover into the reader;
                      // the shuttle shows the cover expanding to full screen so
                      // the in-flight frame isn't a blank/loading flipbook.
                      child: Hero(
                        tag: 'cover_${reader.book.id}',
                        flightShuttleBuilder: _coverFlightShuttle,
                        child: _applyTint(
                          BookCurlView(
                            controller: _curl,
                            bookId: reader.book.id,
                            filePath: reader.book.filePath,
                            pageCount: reader.totalPages,
                            initialPage: reader.currentPage,
                            targetWidth: targetWidth,
                            paperColor: Colors.white,
                            onPageChanged: _onPageTurn,
                            onCenterTap: reader.toggleOverlay,
                          ),
                          reader.tint,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: ReaderOverlay(
                        controller: _curl,
                        onBack: () => context.pop(),
                        onShowBookmarks: _showBookmarks,
                        brightness: _brightness,
                        onBrightnessChanged: _onBrightnessChanged,
                        scrubberShowcaseKey: _tourScrubberKey,
                        readAloudShowcaseKey: _tourReadAloudKey,
                        tintShowcaseKey: _tourTintKey,
                        brightnessShowcaseKey: _tourBrightnessKey,
                        bookmarkShowcaseKey: _tourBookmarkKey,
                      ),
                    ),
                  ],
                ),
            },
          );
        },
      ),
    );
  }
}
