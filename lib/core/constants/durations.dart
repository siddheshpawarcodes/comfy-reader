/// Motion / timing tokens. Keep animations in the 250–400ms cozy range.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration base = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);

  /// Total in-app animated splash duration.
  static const Duration splash = Duration(milliseconds: 3000);

  /// Reader overlay auto-hide delay after last interaction.
  static const Duration overlayAutoHide = Duration(seconds: 4);

  /// Debounce for persisting the last-read page.
  static const Duration resumeSaveDebounce = Duration(milliseconds: 600);

  /// Page-curl turn duration.
  static const Duration pageCurl = Duration(milliseconds: 800);
}
