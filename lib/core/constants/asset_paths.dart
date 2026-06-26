/// Centralized asset path + font family constants.
abstract final class AssetPaths {
  // Audio (path is relative to the assets/ root, as audioplayers expects).
  static const String pageFlipSound = 'audio/page_flip.mp3';

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
}
