import 'package:flutter/material.dart';

/// Central color tokens for Comfy Reader's warm, cozy, paper-like brand.
///
/// Every screen consumes these via [AppTheme]/[ComfyColors] — never hardcode
/// colors in widgets.
abstract final class AppColors {
  // ---- Day theme (warm cream / paper) ----
  static const Color dayBackground = Color(0xFFF6EEE0);
  static const Color daySurface = Color(0xFFFFFBF3);
  static const Color dayText = Color(0xFF3A2E25); // espresso
  static const Color accentTerracotta = Color(0xFFC56A4E);
  static const Color secondarySage = Color(0xFF7C8C72);
  static const Color highlightGold = Color(0xFFD9A441);

  // Reading page tints (Day / paper + sepia)
  static const Color readingPaper = Color(0xFFF4ECD8);
  static const Color readingPaperText = Color(0xFF2B2117);
  static const Color readingSepia = Color(0xFFEADBBE);

  // ---- Night theme (warm dark) ----
  static const Color nightBackground = Color(0xFF1A1714);
  static const Color nightSurface = Color(0xFF241F1A);
  static const Color nightText = Color(0xFFE8DFD0);
  static const Color accentAmber = Color(0xFFE0A458);

  // Reading page tint (Night)
  static const Color readingNight = Color(0xFF141210);
  static const Color readingNightText = Color(0xFFC9BFAE);

  // ---- Shared neutrals ----
  static const Color shadowWarm = Color(0x33000000);
  static const Color blankPage = Color(0xFFDDD6C6);
}
