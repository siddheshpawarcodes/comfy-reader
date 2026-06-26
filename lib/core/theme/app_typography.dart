import 'package:flutter/material.dart';

import '../constants/asset_paths.dart';

/// Named text-style scale. Weights are applied via [FontVariation] because the
/// bundled fonts are variable. Colors are left null here and applied by
/// [AppTheme] via the [TextTheme] (so every screen inherits theme colors).
abstract final class AppTypography {
  static const List<FontVariation> _w400 = [FontVariation('wght', 400)];
  static const List<FontVariation> _w500 = [FontVariation('wght', 500)];
  static const List<FontVariation> _w600 = [FontVariation('wght', 600)];
  static const List<FontVariation> _w700 = [FontVariation('wght', 700)];

  /// App wordmark ("Comfy Reader").
  static const TextStyle wordmark = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    fontVariations: _w600,
    letterSpacing: 0.2,
  );

  /// Large display / hero headings.
  static const TextStyle displayLarge = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    fontVariations: _w700,
    height: 1.1,
  );

  /// Section titles ("Continue Reading", "Library").
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontVariations: _w600,
  );

  /// Book titles on cards / reader top bar.
  static const TextStyle bookTitle = TextStyle(
    fontFamily: AppFonts.bookTitle,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontVariations: _w600,
    height: 1.2,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: AppFonts.ui,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontVariations: _w400,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: AppFonts.ui,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontVariations: _w400,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: AppFonts.ui,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    fontVariations: _w500,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.ui,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontVariations: _w400,
    letterSpacing: 0.1,
  );

  /// Builds a Material [TextTheme] from the scale, tinted with [color].
  static TextTheme textTheme(Color color) {
    Color soft() => color.withValues(alpha: 0.7);
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: color),
      headlineSmall: sectionTitle.copyWith(color: color),
      titleLarge: wordmark.copyWith(color: color),
      titleMedium: bookTitle.copyWith(color: color),
      bodyLarge: bodyLarge.copyWith(color: color),
      bodyMedium: bodyMedium.copyWith(color: color),
      labelLarge: label.copyWith(color: color),
      bodySmall: caption.copyWith(color: soft()),
      labelSmall: caption.copyWith(color: soft()),
    );
  }
}
