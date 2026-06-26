import 'package:flutter/material.dart';

import '../../core/constants/durations.dart';

/// Wraps a tappable child with a subtle scale-down press feedback. Honors the
/// OS reduced-motion setting (no scale when animations are disabled). Use for
/// cards/tiles so taps feel responsive without bespoke gesture code per widget.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.96,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Scale applied while pressed (1.0 = no shrink).
  final double pressedScale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final scale = (_pressed && !reduceMotion) ? widget.pressedScale : 1.0;
    return Semantics(
      // Announce the tile as a button to screen readers (the inner title/meta
      // text is still read as its label).
      button: widget.onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        child: AnimatedScale(
          scale: scale,
          duration: AppDurations.fast,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
