import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';

enum _SwipeKind { short, long, fast }

/// Coach-mark content for the reader tour: three looping mini-animations of a
/// finger swiping, each showing a distinct gesture and its outcome, so
/// first-time readers understand how page turns actually trigger instead of
/// guessing. Mirrors the real thresholds in `flip_book.dart` — a drag needs
/// to cover a chunk of the page width *or* be flicked fast to turn the page;
/// anything smaller and slower just springs back.
class SwipeGestureDemo extends StatelessWidget {
  const SwipeGestureDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.daySurface,
        borderRadius: BorderRadius.circular(Dimens.radiusCard),
        boxShadow: Dimens.softShadow,
      ),
      padding: const EdgeInsets.all(Dimens.space4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tourSwipeTitle,
            style: AppTypography.bookTitle.copyWith(color: AppColors.dayText),
          ),
          Dimens.space3.verticalSpace,
          _SwipeRow(kind: _SwipeKind.short, label: l10n.tourSwipeShortBody),
          Dimens.space2.verticalSpace,
          _SwipeRow(kind: _SwipeKind.long, label: l10n.tourSwipeLongBody),
          Dimens.space2.verticalSpace,
          _SwipeRow(kind: _SwipeKind.fast, label: l10n.tourSwipeFastBody),
        ],
      ),
    );
  }
}

class _SwipeRow extends StatelessWidget {
  const _SwipeRow({required this.kind, required this.label});

  final _SwipeKind kind;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 84.w, height: 32.h, child: _SwipeTrack(kind: kind)),
        Dimens.space3.horizontalSpace,
        Expanded(
          child: Text(
            label,
            style: AppTypography.caption
                .copyWith(color: AppColors.dayText.withValues(alpha: 0.85)),
          ),
        ),
      ],
    );
  }
}

/// A tiny looping animation: a finger travels along a track and, if the
/// gesture would turn the page, a page icon fades in at the end.
class _SwipeTrack extends StatefulWidget {
  const _SwipeTrack({required this.kind});

  final _SwipeKind kind;

  @override
  State<_SwipeTrack> createState() => _SwipeTrackState();
}

class _SwipeTrackState extends State<_SwipeTrack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const Map<_SwipeKind, Duration> _cycleDuration = {
    _SwipeKind.short: Duration(milliseconds: 1700),
    _SwipeKind.long: Duration(milliseconds: 2400),
    _SwipeKind.fast: Duration(milliseconds: 1700),
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _cycleDuration[widget.kind],
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Samples (drag fraction 0..1, finger opacity, outcome-icon opacity) at
  /// point [t] (0..1) in the loop. Each case fades the finger out just before
  /// it would jump back to the start, so the `repeat()` seam is invisible.
  (double, double, double) _sample(double t) {
    switch (widget.kind) {
      case _SwipeKind.short:
        // Small drag out, springs back, pauses at rest — page never turns.
        if (t < 0.22) {
          return (Curves.easeOut.transform(t / 0.22) * 0.32, 1, 0);
        } else if (t < 0.36) {
          return (0.32, 1, 0);
        } else if (t < 0.55) {
          final p = Curves.easeIn.transform((t - 0.36) / 0.19);
          return (0.32 * (1 - p), 1, 0);
        } else if (t < 0.92) {
          return (0, 1, 0);
        }
        return (0, 1 - (t - 0.92) / 0.08, 0);
      case _SwipeKind.long:
        // Slow, deliberate drag across most of the track, then it turns.
        if (t < 0.5) {
          final p = t / 0.5;
          return (p, 1, (p - 0.7).clamp(0.0, 0.3) / 0.3);
        } else if (t < 0.78) {
          return (1, 1, 1);
        }
        final p = (t - 0.78) / 0.22;
        return (1, 1 - p, 1 - p);
      case _SwipeKind.fast:
        // A quick flick that barely travels, yet still turns the page.
        if (t < 0.08) {
          return (Curves.easeOut.transform(t / 0.08) * 0.5, 1, 0);
        } else if (t < 0.34) {
          return (0.5, 1, 1);
        } else if (t < 0.52) {
          final p = (t - 0.34) / 0.18;
          return (0.5, 1 - p, 1 - p);
        }
        return (0, 0, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final (drag, fingerOpacity, outcomeOpacity) =
            _sample(_controller.value);
        return LayoutBuilder(
          builder: (context, constraints) {
            const iconSize = 18.0;
            final travel = (constraints.maxWidth - iconSize * 2)
                .clamp(0.0, double.infinity);
            final x = drag * travel;
            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: iconSize / 2),
                  decoration: BoxDecoration(
                    color: AppColors.dayText.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(Dimens.radiusPill),
                  ),
                ),
                Container(
                  height: 3,
                  width: x + iconSize,
                  margin: const EdgeInsets.only(left: iconSize / 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentTerracotta.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(Dimens.radiusPill),
                  ),
                ),
                Positioned(
                  left: x,
                  child: Opacity(
                    opacity: fingerOpacity,
                    child: const Icon(
                      Icons.touch_app_rounded,
                      size: iconSize,
                      color: AppColors.accentTerracotta,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Opacity(
                    opacity: outcomeOpacity,
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: iconSize * 0.85,
                      color: AppColors.secondarySage,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
