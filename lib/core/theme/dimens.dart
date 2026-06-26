import 'package:flutter/widgets.dart';

/// Spacing, radius, and shape tokens on an 8px scale.
abstract final class Dimens {
  // 8px spacing scale.
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;

  // Corner radii.
  static const double radiusSmall = 12;
  static const double radiusCard = 18;
  static const double radiusLarge = 24;
  static const double radiusPill = 999;

  // Book cover aspect (width / height) — a typical book page.
  static const double bookAspect = 3 / 4;

  // Soft warm card shadow.
  static const List<BoxShadow> softShadow = <BoxShadow>[
    BoxShadow(
      color: Color(0x1F3A2E25),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];
}
