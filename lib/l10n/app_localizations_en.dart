// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Comfy Reader';

  @override
  String get appTagline => 'Read like it\'s a real book.';

  @override
  String get navLibrary => 'Library';

  @override
  String get navReading => 'Reading';

  @override
  String get navSettings => 'Settings';

  @override
  String get close => 'Close';

  @override
  String get notNow => 'Not now';

  @override
  String get continueLabel => 'Continue';

  @override
  String get open => 'Open';

  @override
  String get goBack => 'Go back';

  @override
  String get libraryTitle => 'Library';

  @override
  String get searchTooltip => 'Search';

  @override
  String get closeSearchTooltip => 'Close search';

  @override
  String get searchHint => 'Search titles…';

  @override
  String get toggleLayoutTooltip => 'Toggle layout';

  @override
  String get dayTheme => 'Day theme';

  @override
  String get nightTheme => 'Night theme';

  @override
  String get sortRecent => 'Sort: Recent';

  @override
  String get sortName => 'Sort: Name';

  @override
  String get sortDateAdded => 'Sort: Date added';

  @override
  String get noStorageAccess => 'No storage access — tap + to add PDFs.';

  @override
  String get noNewBooks => 'No new books found';

  @override
  String foundBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Found $count books',
      one: 'Found 1 book',
    );
    return '$_temp0';
  }

  @override
  String get emptyNoMatches => 'No matches';

  @override
  String get emptyTryDifferent => 'Try a different title.';

  @override
  String get emptyNoBooks => 'No books yet';

  @override
  String get emptyNoBooksBody =>
      'Tap + to add a PDF, or pull down to scan your device.';

  @override
  String get continueReadingTitle => 'Continue Reading';

  @override
  String get nothingInProgress => 'Nothing in progress';

  @override
  String get nothingInProgressBody =>
      'Open a book from your Library and it will show up here so you can pick up right where you left off.';

  @override
  String pageOfTotal(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String get details => 'Details';

  @override
  String get removeFromLibrary => 'Remove from library';

  @override
  String get detailPages => 'Pages';

  @override
  String get detailSize => 'Size';

  @override
  String get detailProgress => 'Progress';

  @override
  String get detailSource => 'Source';

  @override
  String get sourceImported => 'Imported';

  @override
  String get sourceOnDevice => 'On device';

  @override
  String get addPdf => 'Add PDF';

  @override
  String addedBook(String title) {
    return 'Added \"$title\"';
  }

  @override
  String get couldntImport => 'Couldn\'t import that file.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDay => 'Day';

  @override
  String get themeNight => 'Night';

  @override
  String get reading => 'Reading';

  @override
  String get pageTurnSound => 'Page-turn sound';

  @override
  String get pageTurnSoundSub => 'Play a soft flip sound on each turn';

  @override
  String get volume => 'Volume';

  @override
  String get haptics => 'Haptics';

  @override
  String get hapticsSub => 'Gentle buzz on a completed page turn';

  @override
  String get keepScreenOn => 'Keep screen on';

  @override
  String get keepScreenOnSub => 'Prevent the screen sleeping while reading';

  @override
  String get readAloudSpeed => 'Read-aloud speed';

  @override
  String get readAloudVoices => 'Read-aloud voices';

  @override
  String get readAloudVoicesSub => 'Languages, voice quality, and downloads';

  @override
  String get defaultPageTint => 'Default page tint';

  @override
  String get tintPaper => 'Paper';

  @override
  String get tintSepia => 'Sepia';

  @override
  String get tintNight => 'Night';

  @override
  String get defaultPageTintNote =>
      'New books open with this tint. You can still change it per book from the reader.';

  @override
  String get librarySection => 'Library';

  @override
  String get rescanTitle => 'Rescan device for PDFs';

  @override
  String get rescanSub =>
      'Search Downloads, Documents, and Books for new files';

  @override
  String get about => 'About';

  @override
  String get openSourceLicenses => 'Open-source licenses';

  @override
  String appVersion(String version) {
    return 'v$version';
  }

  @override
  String get appLanguage => 'App language';

  @override
  String get appLanguageSub => 'Choose the language for the app\'s interface';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get takeTourAgain => 'Take the tour again';

  @override
  String get takeTourAgainSub => 'Replay the feature highlights';

  @override
  String get backToLibrary => 'Back to library';

  @override
  String get bookmarksTooltip => 'Bookmarks';

  @override
  String get bookmarkThisPage => 'Bookmark this page';

  @override
  String get previousPage => 'Previous page';

  @override
  String get nextPage => 'Next page';

  @override
  String get screenBrightness => 'Screen brightness';

  @override
  String get pauseReading => 'Pause reading';

  @override
  String get resumeReading => 'Resume reading';

  @override
  String get readAloud => 'Read aloud';

  @override
  String get pause => 'Pause';

  @override
  String get play => 'Play';

  @override
  String get stopReading => 'Stop reading';

  @override
  String get noBookmarks =>
      'No bookmarks yet. Tap the bookmark icon to add one.';

  @override
  String pageNumber(int page) {
    return 'Page $page';
  }

  @override
  String get bookNotFound => 'Book not found';

  @override
  String get cantOpenBook => 'Can\'t open this book';

  @override
  String get somethingWentWrong => 'Something went wrong.';

  @override
  String get findPdfsTitle => 'Find PDFs on your device';

  @override
  String get storageAccessOff => 'Storage access is off';

  @override
  String get storageAccessOffBody =>
      'Open Settings to let Comfy Reader find PDFs on your device — or just tap + to add them manually.';

  @override
  String get openSettingsLabel => 'Open settings';

  @override
  String get tourLibraryTitle => 'Your books';

  @override
  String get tourLibraryBody => 'All your imported and scanned PDFs live here.';

  @override
  String get tourReadingTitle => 'Continue reading';

  @override
  String get tourReadingBody =>
      'Jump back into books you\'ve started, right where you left off.';

  @override
  String get tourSettingsNavTitle => 'Settings';

  @override
  String get tourSettingsNavBody =>
      'Themes, languages, read-aloud voices, and more.';

  @override
  String get tourSearchTitle => 'Search';

  @override
  String get tourSearchBody => 'Find a book by its title.';

  @override
  String get tourLayoutTitle => 'Grid or list';

  @override
  String get tourLayoutBody => 'Switch between grid and list views.';

  @override
  String get tourAddTitle => 'Add a book';

  @override
  String get tourAddBody => 'Import a PDF from your device to start reading.';

  @override
  String get tourThemeTitle => 'Appearance';

  @override
  String get tourThemeBody =>
      'Switch between Day, Night, or follow your system.';

  @override
  String get tourLanguageTitle => 'App language';

  @override
  String get tourLanguageBody =>
      'Read the app\'s interface in your preferred language.';

  @override
  String get tourVoicesTitle => 'Read-aloud voices';

  @override
  String get tourVoicesBody =>
      'Pick voices and download languages for read-aloud.';

  @override
  String get tourTintTitle => 'Comfort tint';

  @override
  String get tourTintBody => 'Set the default paper tint for new books.';

  @override
  String get tourTapTitle => 'Show the controls';

  @override
  String get tourTapBody =>
      'Tap the middle of the page to show or hide the reader controls.';

  @override
  String get tourScrubberTitle => 'Jump to a page';

  @override
  String get tourScrubberBody => 'Drag to preview and jump to any page.';

  @override
  String get tourReadAloudTitle => 'Read aloud';

  @override
  String get tourReadAloudBody => 'Have the book read to you out loud.';

  @override
  String get tourReaderTintTitle => 'Comfort tint';

  @override
  String get tourReaderTintBody => 'Cycle paper, sepia, and night tints.';

  @override
  String get tourBrightnessTitle => 'Brightness';

  @override
  String get tourBrightnessBody =>
      'Adjust screen brightness without leaving the book.';

  @override
  String get tourBookmarkTitle => 'Bookmark';

  @override
  String get tourBookmarkBody => 'Save your place and find it again later.';

  @override
  String get readScannedBooks => 'Read scanned books';

  @override
  String get readScannedBooksSub =>
      'Use on-device OCR to read pages that have no selectable text';
}
