import 'package:flutter/material.dart';

/// Caps the OS text-scale factor for its subtree.
///
/// Android accessibility font sizes go up to ~2x (and OEMs/Android 14 non-linear
/// scaling further); iOS Dynamic Type up to ~3.1x. Left unbounded, that scale
/// flows into the app's dense chrome (cards, bars, segmented buttons) and causes
/// RenderFlex overflows. This bounds it to a layout-safe range while still
/// honoring moderate increases. PDF page content isn't system-scaled, so reading
/// is unaffected.
class MaxTextScale extends StatelessWidget {
  const MaxTextScale({
    super.key,
    required this.child,
    this.max = 1.3,
    this.min = 0.8,
  });

  /// Upper bound on the effective text scale factor.
  final double max;

  /// Lower bound (prevents text shrinking to an unreadable size).
  final double min;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        textScaler: mq.textScaler.clamp(
          minScaleFactor: min,
          maxScaleFactor: max,
        ),
      ),
      child: child,
    );
  }
}
