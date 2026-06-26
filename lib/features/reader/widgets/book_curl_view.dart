import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/durations.dart';
import '../../../flip_book/flip_book.dart';
import '../pdf_page_image_provider.dart';

/// Thin, swappable abstraction over the page-curl engine (vendored
/// [RealisticFlipbook]). Feeds it lazily-rendered PDF pages and exposes a
/// minimal controller for tap-zone turns and Go-To.
///
/// Gesture contract:
///   • Drag left/right   → curl the page (flipbook handles it)
///   • Single tap L/R/C  → previous page / next page / overlay (280ms delay
///                          so the first tap of a double-tap is never fired)
///   • Double-tap        → toggle 2× zoom at the tapped point; when zoomed,
///                          drag anywhere to pan; double-tap again to zoom out
class BookCurlView extends StatefulWidget {
  const BookCurlView({
    super.key,
    required this.controller,
    required this.bookId,
    required this.filePath,
    required this.pageCount,
    required this.initialPage,
    required this.targetWidth,
    required this.paperColor,
    required this.onPageChanged,
    required this.onCenterTap,
  });

  final BookCurlController controller;
  final String bookId;
  final String filePath;
  final int pageCount;
  final int initialPage; // 0-based
  final int targetWidth; // physical px for rendering
  final Color paperColor;
  final void Function(int page) onPageChanged; // 0-based
  final VoidCallback onCenterTap;

  @override
  State<BookCurlView> createState() => _BookCurlViewState();
}

class _BookCurlViewState extends State<BookCurlView> {
  late final List<FlipbookPage> _pages;

  // Single-tap is deferred 280 ms so the first tap of a double-tap doesn't
  // accidentally trigger page navigation.
  Timer? _singleTapTimer;
  Offset? _singleTapPosition;
  Offset? _doubleTapPosition;
  BoxConstraints? _lastConstraints;

  FlipbookController get _flip => widget.controller._flip;

  @override
  void initState() {
    super.initState();
    _pages = List<FlipbookPage>.generate(
      widget.pageCount,
      (i) => FlipbookPage(
        image: PdfPageImageProvider(
          bookId: widget.bookId,
          filePath: widget.filePath,
          pageIndex: i,
          targetWidth: widget.targetWidth,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _singleTapTimer?.cancel();
    super.dispose();
  }

  void _onFlipEnd(int publicPage) => widget.onPageChanged(publicPage - 1);

  // ---- Tap handling -------------------------------------------------------

  void _onTapUp(TapUpDetails d) {
    _singleTapPosition = d.localPosition;
    _singleTapTimer?.cancel();
    // Defer so the double-tap recogniser has time to cancel this if needed.
    _singleTapTimer = Timer(const Duration(milliseconds: 280), () {
      _singleTapTimer = null;
      final pos = _singleTapPosition;
      final c = _lastConstraints;
      if (pos == null || c == null || _flip.canZoomOut) return;
      _executeTap(pos, c);
    });
  }

  void _executeTap(Offset pos, BoxConstraints c) {
    final third = c.maxWidth / 3;
    if (pos.dx < third) {
      _flip.flipLeft();
    } else if (pos.dx > third * 2) {
      _flip.flipRight();
    } else {
      widget.onCenterTap();
    }
  }

  void _onDoubleTapDown(TapDownDetails d) {
    // Cancel the pending single-tap so the first tap of this double-tap is
    // swallowed instead of triggering navigation.
    _singleTapTimer?.cancel();
    _singleTapTimer = null;
    _doubleTapPosition = d.localPosition;
  }

  void _onDoubleTap() {
    // Also cancel any timer from the second onTapUp that fires before/after
    // onDoubleTap (ordering is not guaranteed by the recognizer).
    _singleTapTimer?.cancel();
    _singleTapTimer = null;
    if (_flip.canZoomOut) {
      _flip.zoomOut();
    } else {
      _flip.zoomIn(_doubleTapPosition);
    }
  }

  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _lastConstraints = constraints;
        return Stack(
          children: [
            // Fill the entire surface with paperColor so the ColorFilter
            // applied by the reader tints margins and page uniformly — no
            // visible letterbox bars around the PDF.
            Positioned.fill(child: ColoredBox(color: widget.paperColor)),
            RealisticFlipbook(
              pages: _pages,
              controller: _flip,
              singlePage: true,
              // Each PDF page is a full page, not a half of a physical
              // two-page spread. Disable spread-slide navigation so every
              // turn is a realistic page curl (_FlipState) instead of
              // alternating slide pans (_SlideState) and curls.
              singlePageSpreadNavigation: false,
              startPage: widget.initialPage + 1, // flipbook is 1-based
              paperColor: widget.paperColor,
              blankPageColor: widget.paperColor,
              flipDuration: AppDurations.pageCurl,
              perspective: 2400,
              nPolygons: 12,
              ambient: 0.45,
              gloss: 0.0,
              // Two zoom levels: 1× (overview) and 2× (fills screen height for
              // typical portrait PDFs). At 2× the flipbook enables drag-to-pan.
              zooms: const [1, 2],
              tapToFlip: false,
              clickToZoom: false,
              dragToFlip: true,
              dragToScroll: true,
              onFlipLeftEnd: _onFlipEnd,
              onFlipRightEnd: _onFlipEnd,
              loadingBuilder: (_) => Center(
                child: SizedBox(
                  width: 26.r,
                  height: 26.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            // Gesture overlay — translucent so page-curl drags pass through
            // to the flipbook underneath.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapUp: _onTapUp,
                onDoubleTapDown: _onDoubleTapDown,
                onDoubleTap: _onDoubleTap,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Minimal controller surface exposed to the reader (decouples the UI from the
/// underlying flipbook package). Owned by the parent and passed into
/// [BookCurlView].
class BookCurlController {
  final FlipbookController _flip = FlipbookController();

  void next() => _flip.flipRight();
  void previous() => _flip.flipLeft();
  void jumpTo(int page) => _flip.goToPage(page + 1); // 0-based -> 1-based
}
