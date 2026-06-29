// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appTitle => 'Comfy Reader';

  @override
  String get appTagline => 'ನಿಜವಾದ ಪುಸ್ತಕದಂತೆ ಓದಿ.';

  @override
  String get navLibrary => 'ಗ್ರಂಥಾಲಯ';

  @override
  String get navReading => 'ಓದುತ್ತಿರುವುದು';

  @override
  String get navSettings => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get close => 'ಮುಚ್ಚಿ';

  @override
  String get notNow => 'ಈಗ ಬೇಡ';

  @override
  String get continueLabel => 'ಮುಂದುವರಿಸಿ';

  @override
  String get open => 'ತೆರೆ';

  @override
  String get goBack => 'ಹಿಂದಕ್ಕೆ';

  @override
  String get libraryTitle => 'ಗ್ರಂಥಾಲಯ';

  @override
  String get searchTooltip => 'ಹುಡುಕಿ';

  @override
  String get closeSearchTooltip => 'ಹುಡುಕಾಟ ಮುಚ್ಚಿ';

  @override
  String get searchHint => 'ಶೀರ್ಷಿಕೆಗಳನ್ನು ಹುಡುಕಿ…';

  @override
  String get toggleLayoutTooltip => 'ವಿನ್ಯಾಸ ಬದಲಿಸಿ';

  @override
  String get dayTheme => 'ಹಗಲು ಥೀಮ್';

  @override
  String get nightTheme => 'ರಾತ್ರಿ ಥೀಮ್';

  @override
  String get sortRecent => 'ವಿಂಗಡಣೆ: ಇತ್ತೀಚಿನ';

  @override
  String get sortName => 'ವಿಂಗಡಣೆ: ಹೆಸರು';

  @override
  String get sortDateAdded => 'ವಿಂಗಡಣೆ: ಸೇರಿಸಿದ ದಿನಾಂಕ';

  @override
  String get noStorageAccess => 'ಸಂಗ್ರಹ ಪ್ರವೇಶ ಇಲ್ಲ — PDF ಸೇರಿಸಲು + ಒತ್ತಿ.';

  @override
  String get noNewBooks => 'ಹೊಸ ಪುಸ್ತಕಗಳು ಸಿಗಲಿಲ್ಲ';

  @override
  String foundBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಪುಸ್ತಕಗಳು ಸಿಕ್ಕವು',
      one: '1 ಪುಸ್ತಕ ಸಿಕ್ಕಿತು',
    );
    return '$_temp0';
  }

  @override
  String get emptyNoMatches => 'ಹೊಂದಾಣಿಕೆ ಇಲ್ಲ';

  @override
  String get emptyTryDifferent => 'ಬೇರೆ ಶೀರ್ಷಿಕೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get emptyNoBooks => 'ಇನ್ನೂ ಪುಸ್ತಕಗಳಿಲ್ಲ';

  @override
  String get emptyNoBooksBody =>
      'PDF ಸೇರಿಸಲು + ಒತ್ತಿ, ಅಥವಾ ನಿಮ್ಮ ಸಾಧನ ಸ್ಕ್ಯಾನ್ ಮಾಡಲು ಕೆಳಕ್ಕೆ ಎಳೆಯಿರಿ.';

  @override
  String get continueReadingTitle => 'ಓದುವುದನ್ನು ಮುಂದುವರಿಸಿ';

  @override
  String get nothingInProgress => 'ಯಾವುದೂ ನಡೆಯುತ್ತಿಲ್ಲ';

  @override
  String get nothingInProgressBody =>
      'ನಿಮ್ಮ ಗ್ರಂಥಾಲಯದಿಂದ ಒಂದು ಪುಸ್ತಕ ತೆರೆಯಿರಿ, ಅದು ಇಲ್ಲಿ ಕಾಣಿಸುತ್ತದೆ — ನೀವು ನಿಲ್ಲಿಸಿದಲ್ಲಿಂದ ಮುಂದುವರಿಸಬಹುದು.';

  @override
  String pageOfTotal(int current, int total) {
    return '$total ರಲ್ಲಿ $current ನೇ ಪುಟ';
  }

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String get details => 'ವಿವರಗಳು';

  @override
  String get removeFromLibrary => 'ಗ್ರಂಥಾಲಯದಿಂದ ತೆಗೆದುಹಾಕಿ';

  @override
  String get detailPages => 'ಪುಟಗಳು';

  @override
  String get detailSize => 'ಗಾತ್ರ';

  @override
  String get detailProgress => 'ಪ್ರಗತಿ';

  @override
  String get detailSource => 'ಮೂಲ';

  @override
  String get sourceImported => 'ಆಮದು ಮಾಡಲಾಗಿದೆ';

  @override
  String get sourceOnDevice => 'ಸಾಧನದಲ್ಲಿ';

  @override
  String get addPdf => 'PDF ಸೇರಿಸಿ';

  @override
  String addedBook(String title) {
    return '\"$title\" ಸೇರಿಸಲಾಗಿದೆ';
  }

  @override
  String get couldntImport => 'ಆ ಫೈಲ್ ಆಮದು ಮಾಡಲಾಗಲಿಲ್ಲ.';

  @override
  String get settingsTitle => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get appearance => 'ಗೋಚರಿಕೆ';

  @override
  String get themeSystem => 'ಸಿಸ್ಟಂ';

  @override
  String get themeDay => 'ಹಗಲು';

  @override
  String get themeNight => 'ರಾತ್ರಿ';

  @override
  String get reading => 'ಓದುವಿಕೆ';

  @override
  String get pageTurnSound => 'ಪುಟ ತಿರುಗಿಸುವ ಶಬ್ದ';

  @override
  String get pageTurnSoundSub => 'ಪ್ರತಿ ತಿರುಗಿಸುವಿಕೆಗೆ ಮೃದು ಶಬ್ದ ನುಡಿಸಿ';

  @override
  String get volume => 'ಧ್ವನಿ ಪ್ರಮಾಣ';

  @override
  String get haptics => 'ಸ್ಪರ್ಶ ಕಂಪನ';

  @override
  String get hapticsSub => 'ಪುಟ ತಿರುಗಿದ ಮೇಲೆ ಮೃದು ಕಂಪನ';

  @override
  String get keepScreenOn => 'ಪರದೆ ಆನ್ ಇರಿಸಿ';

  @override
  String get keepScreenOnSub => 'ಓದುವಾಗ ಪರದೆ ನಿದ್ರೆಗೆ ಹೋಗದಂತೆ ತಡೆಯಿರಿ';

  @override
  String get readAloudSpeed => 'ಓದಿ ಹೇಳುವ ವೇಗ';

  @override
  String get readAloudVoices => 'ಓದಿ ಹೇಳುವ ಧ್ವನಿಗಳು';

  @override
  String get readAloudVoicesSub => 'ಭಾಷೆಗಳು, ಧ್ವನಿ ಗುಣಮಟ್ಟ ಮತ್ತು ಡೌನ್‌ಲೋಡ್‌ಗಳು';

  @override
  String get defaultPageTint => 'ಡೀಫಾಲ್ಟ್ ಪುಟ ಬಣ್ಣ';

  @override
  String get tintPaper => 'ಕಾಗದ';

  @override
  String get tintSepia => 'ಸೆಪಿಯಾ';

  @override
  String get tintNight => 'ರಾತ್ರಿ';

  @override
  String get defaultPageTintNote =>
      'ಹೊಸ ಪುಸ್ತಕಗಳು ಈ ಬಣ್ಣದಲ್ಲಿ ತೆರೆಯುತ್ತವೆ. ರೀಡರ್‌ನಲ್ಲಿ ಪ್ರತಿ ಪುಸ್ತಕಕ್ಕೂ ಬದಲಿಸಬಹುದು.';

  @override
  String get librarySection => 'ಗ್ರಂಥಾಲಯ';

  @override
  String get rescanTitle => 'PDF ಗಳಿಗಾಗಿ ಸಾಧನ ಮರು-ಸ್ಕ್ಯಾನ್ ಮಾಡಿ';

  @override
  String get rescanSub =>
      'ಹೊಸ ಫೈಲ್‌ಗಳಿಗಾಗಿ ಡೌನ್‌ಲೋಡ್, ಡಾಕ್ಯುಮೆಂಟ್ಸ್ ಮತ್ತು ಬುಕ್ಸ್ ಹುಡುಕಿ';

  @override
  String get about => 'ಬಗ್ಗೆ';

  @override
  String get openSourceLicenses => 'ಮುಕ್ತ-ಮೂಲ ಪರವಾನಗಿಗಳು';

  @override
  String appVersion(String version) {
    return 'v$version';
  }

  @override
  String get appLanguage => 'ಆ್ಯಪ್ ಭಾಷೆ';

  @override
  String get appLanguageSub => 'ಆ್ಯಪ್ ಇಂಟರ್‌ಫೇಸ್‌ಗೆ ಭಾಷೆ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get chooseLanguage => 'ಭಾಷೆ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get takeTourAgain => 'ಮತ್ತೆ ಪ್ರವಾಸ ಮಾಡಿ';

  @override
  String get takeTourAgainSub => 'ವೈಶಿಷ್ಟ್ಯಗಳ ಮುಖ್ಯಾಂಶಗಳನ್ನು ಮತ್ತೆ ನೋಡಿ';

  @override
  String get backToLibrary => 'ಗ್ರಂಥಾಲಯಕ್ಕೆ ಹಿಂದಕ್ಕೆ';

  @override
  String get bookmarksTooltip => 'ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳು';

  @override
  String get bookmarkThisPage => 'ಈ ಪುಟ ಬುಕ್‌ಮಾರ್ಕ್ ಮಾಡಿ';

  @override
  String get previousPage => 'ಹಿಂದಿನ ಪುಟ';

  @override
  String get nextPage => 'ಮುಂದಿನ ಪುಟ';

  @override
  String get screenBrightness => 'ಪರದೆ ಪ್ರಕಾಶ';

  @override
  String get pauseReading => 'ಓದುವಿಕೆ ವಿರಾಮ';

  @override
  String get resumeReading => 'ಓದುವಿಕೆ ಮುಂದುವರಿಸಿ';

  @override
  String get readAloud => 'ಓದಿ ಹೇಳಿ';

  @override
  String get pause => 'ವಿರಾಮ';

  @override
  String get play => 'ನುಡಿಸಿ';

  @override
  String get stopReading => 'ಓದುವಿಕೆ ನಿಲ್ಲಿಸಿ';

  @override
  String get noBookmarks =>
      'ಇನ್ನೂ ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳಿಲ್ಲ. ಸೇರಿಸಲು ಬುಕ್‌ಮಾರ್ಕ್ ಐಕಾನ್ ಒತ್ತಿ.';

  @override
  String pageNumber(int page) {
    return 'ಪುಟ $page';
  }

  @override
  String get bookNotFound => 'ಪುಸ್ತಕ ಸಿಗಲಿಲ್ಲ';

  @override
  String get cantOpenBook => 'ಈ ಪುಸ್ತಕ ತೆರೆಯಲಾಗಲಿಲ್ಲ';

  @override
  String get somethingWentWrong => 'ಏನೋ ತಪ್ಪಾಯಿತು.';

  @override
  String get findPdfsTitle => 'ನಿಮ್ಮ ಸಾಧನದಲ್ಲಿ PDF ಗಳನ್ನು ಹುಡುಕಿ';

  @override
  String get storageAccessOff => 'ಸಂಗ್ರಹ ಪ್ರವೇಶ ಆಫ್ ಆಗಿದೆ';

  @override
  String get storageAccessOffBody =>
      'Comfy Reader ನಿಮ್ಮ ಸಾಧನದಲ್ಲಿ PDF ಗಳನ್ನು ಹುಡುಕಲು ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ — ಅಥವಾ ಕೈಯಿಂದ ಸೇರಿಸಲು + ಒತ್ತಿ.';

  @override
  String get openSettingsLabel => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆ';

  @override
  String get tourLibraryTitle => 'ನಿಮ್ಮ ಪುಸ್ತಕಗಳು';

  @override
  String get tourLibraryBody =>
      'ನೀವು ಆಮದು ಮಾಡಿದ ಮತ್ತು ಸ್ಕ್ಯಾನ್ ಮಾಡಿದ ಎಲ್ಲಾ PDF ಗಳು ಇಲ್ಲಿರುತ್ತವೆ.';

  @override
  String get tourReadingTitle => 'ಓದುವುದನ್ನು ಮುಂದುವರಿಸಿ';

  @override
  String get tourReadingBody =>
      'ನೀವು ಆರಂಭಿಸಿದ ಪುಸ್ತಕಗಳಿಗೆ, ನಿಲ್ಲಿಸಿದಲ್ಲಿಂದ ಹಿಂದಿರುಗಿ.';

  @override
  String get tourSettingsNavTitle => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get tourSettingsNavBody =>
      'ಥೀಮ್‌ಗಳು, ಭಾಷೆಗಳು, ಓದಿ ಹೇಳುವ ಧ್ವನಿಗಳು ಮತ್ತು ಇನ್ನಷ್ಟು.';

  @override
  String get tourSearchTitle => 'ಹುಡುಕಾಟ';

  @override
  String get tourSearchBody => 'ಶೀರ್ಷಿಕೆಯಿಂದ ಪುಸ್ತಕ ಹುಡುಕಿ.';

  @override
  String get tourLayoutTitle => 'ಗ್ರಿಡ್ ಅಥವಾ ಪಟ್ಟಿ';

  @override
  String get tourLayoutBody => 'ಗ್ರಿಡ್ ಮತ್ತು ಪಟ್ಟಿ ನೋಟಗಳ ನಡುವೆ ಬದಲಿಸಿ.';

  @override
  String get tourAddTitle => 'ಪುಸ್ತಕ ಸೇರಿಸಿ';

  @override
  String get tourAddBody => 'ಓದಲು ಆರಂಭಿಸಲು ನಿಮ್ಮ ಸಾಧನದಿಂದ PDF ಆಮದು ಮಾಡಿ.';

  @override
  String get tourThemeTitle => 'ಗೋಚರಿಕೆ';

  @override
  String get tourThemeBody => 'ಹಗಲು, ರಾತ್ರಿ ನಡುವೆ ಬದಲಿಸಿ ಅಥವಾ ಸಿಸ್ಟಂ ಅನುಸರಿಸಿ.';

  @override
  String get tourLanguageTitle => 'ಆ್ಯಪ್ ಭಾಷೆ';

  @override
  String get tourLanguageBody => 'ನಿಮ್ಮ ಇಷ್ಟದ ಭಾಷೆಯಲ್ಲಿ ಆ್ಯಪ್ ಇಂಟರ್‌ಫೇಸ್ ಓದಿ.';

  @override
  String get tourVoicesTitle => 'ಓದಿ ಹೇಳುವ ಧ್ವನಿಗಳು';

  @override
  String get tourVoicesBody =>
      'ಓದಿ ಹೇಳಲು ಧ್ವನಿಗಳನ್ನು ಆಯ್ಕೆಮಾಡಿ ಮತ್ತು ಭಾಷೆಗಳನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ.';

  @override
  String get tourTintTitle => 'ಆರಾಮ ಬಣ್ಣ';

  @override
  String get tourTintBody => 'ಹೊಸ ಪುಸ್ತಕಗಳಿಗೆ ಡೀಫಾಲ್ಟ್ ಕಾಗದ ಬಣ್ಣ ಹೊಂದಿಸಿ.';

  @override
  String get tourTapTitle => 'ನಿಯಂತ್ರಣಗಳನ್ನು ತೋರಿಸಿ';

  @override
  String get tourTapBody =>
      'ರೀಡರ್ ನಿಯಂತ್ರಣಗಳನ್ನು ತೋರಿಸಲು ಅಥವಾ ಮರೆಮಾಡಲು ಪುಟದ ಮಧ್ಯವನ್ನು ಒತ್ತಿ.';

  @override
  String get tourScrubberTitle => 'ಪುಟಕ್ಕೆ ಹಾರಿ';

  @override
  String get tourScrubberBody =>
      'ಯಾವುದೇ ಪುಟ ಮುನ್ನೋಟ ಕಂಡು ಅದಕ್ಕೆ ಹಾರಲು ಎಳೆಯಿರಿ.';

  @override
  String get tourReadAloudTitle => 'ಓದಿ ಹೇಳಿ';

  @override
  String get tourReadAloudBody => 'ಪುಸ್ತಕವನ್ನು ನಿಮಗೆ ಗಟ್ಟಿಯಾಗಿ ಓದಿ ಹೇಳಿಸಿ.';

  @override
  String get tourReaderTintTitle => 'ಆರಾಮ ಬಣ್ಣ';

  @override
  String get tourReaderTintBody =>
      'ಕಾಗದ, ಸೆಪಿಯಾ ಮತ್ತು ರಾತ್ರಿ ಬಣ್ಣಗಳ ನಡುವೆ ಬದಲಿಸಿ.';

  @override
  String get tourBrightnessTitle => 'ಪ್ರಕಾಶ';

  @override
  String get tourBrightnessBody => 'ಪುಸ್ತಕ ಬಿಡದೆ ಪರದೆ ಪ್ರಕಾಶ ಹೊಂದಿಸಿ.';

  @override
  String get tourBookmarkTitle => 'ಬುಕ್‌ಮಾರ್ಕ್';

  @override
  String get tourBookmarkBody => 'ನಿಮ್ಮ ಸ್ಥಳ ಉಳಿಸಿ ಮತ್ತೆ ಸುಲಭವಾಗಿ ಹುಡುಕಿ.';

  @override
  String get readScannedBooks => 'ಸ್ಕ್ಯಾನ್ ಮಾಡಿದ ಪುಸ್ತಕಗಳನ್ನು ಓದಿ';

  @override
  String get readScannedBooksSub =>
      'ಆಯ್ಕೆ ಮಾಡಬಹುದಾದ ಪಠ್ಯವಿಲ್ಲದ ಪುಟಗಳನ್ನು ಓದಲು ಸಾಧನ OCR ಬಳಸಿ';
}
