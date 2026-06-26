import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'dimens.dart';

/// Brand colors that don't map onto Material's [ColorScheme]. Read via
/// `Theme.of(context).extension<ComfyColors>()!`.
@immutable
class ComfyColors extends ThemeExtension<ComfyColors> {
  const ComfyColors({
    required this.gold,
    required this.sage,
    required this.readingPaper,
    required this.readingPaperText,
    required this.readingSepia,
    required this.readingNight,
    required this.readingNightText,
    required this.blankPage,
  });

  final Color gold;
  final Color sage;
  final Color readingPaper;
  final Color readingPaperText;
  final Color readingSepia;
  final Color readingNight;
  final Color readingNightText;
  final Color blankPage;

  static const ComfyColors day = ComfyColors(
    gold: AppColors.highlightGold,
    sage: AppColors.secondarySage,
    readingPaper: AppColors.readingPaper,
    readingPaperText: AppColors.readingPaperText,
    readingSepia: AppColors.readingSepia,
    readingNight: AppColors.readingNight,
    readingNightText: AppColors.readingNightText,
    blankPage: AppColors.blankPage,
  );

  static const ComfyColors night = ComfyColors(
    gold: AppColors.highlightGold,
    sage: AppColors.secondarySage,
    readingPaper: AppColors.readingPaper,
    readingPaperText: AppColors.readingPaperText,
    readingSepia: AppColors.readingSepia,
    readingNight: AppColors.readingNight,
    readingNightText: AppColors.readingNightText,
    blankPage: AppColors.blankPage,
  );

  @override
  ComfyColors copyWith({
    Color? gold,
    Color? sage,
    Color? readingPaper,
    Color? readingPaperText,
    Color? readingSepia,
    Color? readingNight,
    Color? readingNightText,
    Color? blankPage,
  }) {
    return ComfyColors(
      gold: gold ?? this.gold,
      sage: sage ?? this.sage,
      readingPaper: readingPaper ?? this.readingPaper,
      readingPaperText: readingPaperText ?? this.readingPaperText,
      readingSepia: readingSepia ?? this.readingSepia,
      readingNight: readingNight ?? this.readingNight,
      readingNightText: readingNightText ?? this.readingNightText,
      blankPage: blankPage ?? this.blankPage,
    );
  }

  @override
  ComfyColors lerp(ThemeExtension<ComfyColors>? other, double t) {
    if (other is! ComfyColors) return this;
    return ComfyColors(
      gold: Color.lerp(gold, other.gold, t)!,
      sage: Color.lerp(sage, other.sage, t)!,
      readingPaper: Color.lerp(readingPaper, other.readingPaper, t)!,
      readingPaperText:
          Color.lerp(readingPaperText, other.readingPaperText, t)!,
      readingSepia: Color.lerp(readingSepia, other.readingSepia, t)!,
      readingNight: Color.lerp(readingNight, other.readingNight, t)!,
      readingNightText:
          Color.lerp(readingNightText, other.readingNightText, t)!,
      blankPage: Color.lerp(blankPage, other.blankPage, t)!,
    );
  }
}

/// Builds the Day and Night [ThemeData] from the design tokens. Every screen
/// consumes this — no hardcoded styling in widgets.
abstract final class AppTheme {
  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.accentTerracotta,
      onPrimary: AppColors.daySurface,
      secondary: AppColors.secondarySage,
      onSecondary: AppColors.daySurface,
      tertiary: AppColors.highlightGold,
      onTertiary: AppColors.dayText,
      surface: AppColors.daySurface,
      onSurface: AppColors.dayText,
      error: Color(0xFFB3261E),
      onError: Color(0xFFFFFFFF),
    );
    return _base(
      scheme: scheme,
      background: AppColors.dayBackground,
      textColor: AppColors.dayText,
      comfy: ComfyColors.day,
    );
  }

  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.accentAmber,
      onPrimary: AppColors.nightBackground,
      secondary: AppColors.secondarySage,
      onSecondary: AppColors.nightBackground,
      tertiary: AppColors.highlightGold,
      onTertiary: AppColors.nightBackground,
      surface: AppColors.nightSurface,
      onSurface: AppColors.nightText,
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
    );
    return _base(
      scheme: scheme,
      background: AppColors.nightBackground,
      textColor: AppColors.nightText,
      comfy: ComfyColors.night,
    );
  }

  static ThemeData _base({
    required ColorScheme scheme,
    required Color background,
    required Color textColor,
    required ComfyColors comfy,
  }) {
    final textTheme = AppTypography.textTheme(textColor);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      fontFamily: 'Inter',
      extensions: <ThemeExtension<dynamic>>[comfy],
      appBarTheme: AppBarThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle:
            AppTypography.wordmark.copyWith(color: textColor, fontSize: 22),
        iconTheme: IconThemeData(color: textColor),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusCard),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusCard),
        ),
      ),
      // Flat bottom nav that blends with the warm background; the selected
      // destination is tinted with the accent (the divider is drawn by the
      // shell). Surface roles aren't customized on the hand-built ColorScheme,
      // so spell the colors out explicitly here.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected ? scheme.primary : textColor.withValues(alpha: 0.7),
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 26,
            color: selected ? scheme.primary : textColor.withValues(alpha: 0.7),
          );
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.primary.withValues(alpha: 0.24),
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
      ),
      iconTheme: IconThemeData(color: textColor),
      dividerColor: textColor.withValues(alpha: 0.1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.onSurface,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: scheme.surface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusSmall),
        ),
      ),
    );
  }
}
