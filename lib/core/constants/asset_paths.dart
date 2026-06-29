/// Centralized asset path + font family constants.
abstract final class AssetPaths {
  // Audio (path is relative to the assets/ root, as audioplayers expects).
  static const String pageFlipSound = 'audio/page_flip.wav';

  // Images
  static const String splashLogo = 'assets/images/splash_logo.png';
  static const String appIcon = 'assets/images/app_icon.png';
  static const String emptyState = 'assets/images/empty_state.png';

  // Animations (optional Lottie)
  static const String splashAnimation = 'assets/animations/splash.json';
}

/// Bundled font family names (registered in pubspec.yaml). These are variable
/// fonts — select weights via `fontVariations: [FontVariation('wght', n)]`.
abstract final class AppFonts {
  static const String display = 'Fraunces'; // wordmark + section titles
  static const String bookTitle = 'Lora'; // book titles
  static const String ui = 'Inter'; // UI / body

  /// Fallback families for scripts the bundled Latin fonts don't cover
  /// (Devanagari, Bengali, Tamil, Telugu, Gujarati, Kannada, Malayalam). The
  /// OS supplies these Noto faces, so Indian-language UI text renders instead
  /// of tofu boxes. Applied via `fontFamilyFallback` on the theme and every
  /// [TextStyle] in AppTypography. Listing 'Noto Sans' last covers any other
  /// Latin/extended glyph the bundled fonts lack.
  static const List<String> fallback = <String>[
    'Noto Sans Devanagari',
    'Noto Sans Bengali',
    'Noto Sans Tamil',
    'Noto Sans Telugu',
    'Noto Sans Gujarati',
    'Noto Sans Kannada',
    'Noto Sans Malayalam',
    'Noto Sans',
  ];
}
