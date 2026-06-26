import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/dimens.dart';
import '../../../models/book_model.dart';
import 'book_card.dart';

/// Responsive grid of [BookCard]s with a staggered entrance.
///
/// Cell height is computed (not a fixed aspect ratio) so it always reserves room
/// for the cover *plus* the title/meta/progress text at the current OS font
/// scale — otherwise the caption overflows the cell on large font settings.
class LibraryGrid extends StatelessWidget {
  const LibraryGrid({super.key, required this.books});

  /// Each tile targets this cross-axis extent; columns are derived from it.
  static const double _maxTileExtent = 190;

  final List<BookModel> books;

  @override
  Widget build(BuildContext context) {
    // Honor OS reduced-motion: skip the staggered entrance entirely.
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final theme = Theme.of(context);
    final textScaler = MediaQuery.textScalerOf(context);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        Dimens.space4,
        Dimens.space2,
        Dimens.space4,
        Dimens.space10,
      ),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final cross = constraints.crossAxisExtent;
          // Mirror SliverGridDelegateWithMaxCrossAxisExtent's column math so the
          // tile width (and thus cover height) matches the design.
          final columns = math.max(
            1,
            (cross / (_maxTileExtent + Dimens.space4)).ceil(),
          );
          final tileWidth =
              math.max(0.0, cross - Dimens.space4 * (columns - 1)) / columns;

          // Cover keeps its book aspect; text block + gaps are measured at the
          // live text scale. Progress bar height is always reserved (some cards
          // show it, some don't) so every cell is uniform and never overflows.
          final coverHeight = tileWidth / Dimens.bookAspect;
          final titleHeight = _textHeight(
            context,
            theme.textTheme.titleMedium,
            textScaler,
            maxLines: 2,
            maxWidth: tileWidth,
          );
          final metaHeight = _textHeight(
            context,
            theme.textTheme.bodySmall,
            textScaler,
            maxLines: 1,
            maxWidth: tileWidth,
          );
          final gaps = (Dimens.space2 + 2 + Dimens.space1).h;
          const progress = 3.0;
          final tileHeight =
              coverHeight + gaps + titleHeight + metaHeight + progress + 2;

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: Dimens.space5,
              crossAxisSpacing: Dimens.space4,
              mainAxisExtent: tileHeight,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final card = BookCard(book: books[i]);
                if (reduceMotion) return card;
                return card
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (40 * (i % 12)).ms)
                    .moveY(begin: 12, end: 0, curve: Curves.easeOut);
              },
              childCount: books.length,
            ),
          );
        },
      ),
    );
  }

  /// Laid-out height of [maxLines] lines of [style] at [scaler], wrapping at
  /// [maxWidth] — the real height the matching [Text] will occupy.
  static double _textHeight(
    BuildContext context,
    TextStyle? style,
    TextScaler scaler, {
    required int maxLines,
    required double maxWidth,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: List<String>.filled(maxLines, 'Ag').join('\n'),
        style: style,
      ),
      textDirection: Directionality.of(context),
      textScaler: scaler,
      maxLines: maxLines,
    )..layout(maxWidth: maxWidth);
    return painter.height;
  }
}
