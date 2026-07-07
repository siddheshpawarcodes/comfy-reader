import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('ta'),
    Locale('te'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Comfy Reader'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Read like it\'s a real book.'**
  String get appTagline;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get navReading;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @quitAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Quit Comfy Reader?'**
  String get quitAppTitle;

  /// No description provided for @quitAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the app?'**
  String get quitAppMessage;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @searchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTooltip;

  /// No description provided for @closeSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get closeSearchTooltip;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search titles…'**
  String get searchHint;

  /// No description provided for @toggleLayoutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Toggle layout'**
  String get toggleLayoutTooltip;

  /// No description provided for @dayTheme.
  ///
  /// In en, this message translates to:
  /// **'Day theme'**
  String get dayTheme;

  /// No description provided for @nightTheme.
  ///
  /// In en, this message translates to:
  /// **'Night theme'**
  String get nightTheme;

  /// No description provided for @sortRecent.
  ///
  /// In en, this message translates to:
  /// **'Sort: Recent'**
  String get sortRecent;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Sort: Name'**
  String get sortName;

  /// No description provided for @sortDateAdded.
  ///
  /// In en, this message translates to:
  /// **'Sort: Date added'**
  String get sortDateAdded;

  /// No description provided for @noStorageAccess.
  ///
  /// In en, this message translates to:
  /// **'No storage access — tap + to add PDFs.'**
  String get noStorageAccess;

  /// No description provided for @noNewBooks.
  ///
  /// In en, this message translates to:
  /// **'No new books found'**
  String get noNewBooks;

  /// Snackbar after a device scan finds new books
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Found 1 book} other{Found {count} books}}'**
  String foundBooks(int count);

  /// No description provided for @emptyNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get emptyNoMatches;

  /// No description provided for @emptyTryDifferent.
  ///
  /// In en, this message translates to:
  /// **'Try a different title.'**
  String get emptyTryDifferent;

  /// No description provided for @emptyNoBooks.
  ///
  /// In en, this message translates to:
  /// **'No books yet'**
  String get emptyNoBooks;

  /// No description provided for @emptyNoBooksBody.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a PDF, or pull down to scan your device.'**
  String get emptyNoBooksBody;

  /// No description provided for @continueReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get continueReadingTitle;

  /// No description provided for @nothingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Nothing in progress'**
  String get nothingInProgress;

  /// No description provided for @nothingInProgressBody.
  ///
  /// In en, this message translates to:
  /// **'Open a book from your Library and it will show up here so you can pick up right where you left off.'**
  String get nothingInProgressBody;

  /// Reading position label
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageOfTotal(int current, int total);

  /// A percentage value
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String percentValue(int percent);

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @removeFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Remove from library'**
  String get removeFromLibrary;

  /// No description provided for @detailPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get detailPages;

  /// No description provided for @detailSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get detailSize;

  /// No description provided for @detailProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get detailProgress;

  /// No description provided for @detailSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get detailSource;

  /// No description provided for @sourceImported.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get sourceImported;

  /// No description provided for @sourceOnDevice.
  ///
  /// In en, this message translates to:
  /// **'On device'**
  String get sourceOnDevice;

  /// No description provided for @addPdf.
  ///
  /// In en, this message translates to:
  /// **'Add PDF'**
  String get addPdf;

  /// Snackbar after importing a PDF
  ///
  /// In en, this message translates to:
  /// **'Added \"{title}\"'**
  String addedBook(String title);

  /// No description provided for @couldntImport.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t import that file.'**
  String get couldntImport;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get themeDay;

  /// No description provided for @themeNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get themeNight;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get reading;

  /// No description provided for @pageTurnSound.
  ///
  /// In en, this message translates to:
  /// **'Page-turn sound'**
  String get pageTurnSound;

  /// No description provided for @pageTurnSoundSub.
  ///
  /// In en, this message translates to:
  /// **'Play a soft flip sound on each turn'**
  String get pageTurnSoundSub;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get haptics;

  /// No description provided for @hapticsSub.
  ///
  /// In en, this message translates to:
  /// **'Gentle buzz on a completed page turn'**
  String get hapticsSub;

  /// No description provided for @keepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on'**
  String get keepScreenOn;

  /// No description provided for @keepScreenOnSub.
  ///
  /// In en, this message translates to:
  /// **'Prevent the screen sleeping while reading'**
  String get keepScreenOnSub;

  /// No description provided for @readAloudSpeed.
  ///
  /// In en, this message translates to:
  /// **'Read-aloud speed'**
  String get readAloudSpeed;

  /// No description provided for @readAloudVoices.
  ///
  /// In en, this message translates to:
  /// **'Read-aloud voices'**
  String get readAloudVoices;

  /// No description provided for @readAloudVoicesSub.
  ///
  /// In en, this message translates to:
  /// **'Languages, voice quality, and downloads'**
  String get readAloudVoicesSub;

  /// No description provided for @defaultPageTint.
  ///
  /// In en, this message translates to:
  /// **'Default page tint'**
  String get defaultPageTint;

  /// No description provided for @tintPaper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get tintPaper;

  /// No description provided for @tintSepia.
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get tintSepia;

  /// No description provided for @tintNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get tintNight;

  /// No description provided for @defaultPageTintNote.
  ///
  /// In en, this message translates to:
  /// **'New books open with this tint. You can still change it per book from the reader.'**
  String get defaultPageTintNote;

  /// No description provided for @librarySection.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get librarySection;

  /// No description provided for @rescanTitle.
  ///
  /// In en, this message translates to:
  /// **'Rescan device for PDFs'**
  String get rescanTitle;

  /// No description provided for @rescanSub.
  ///
  /// In en, this message translates to:
  /// **'Search Downloads, Documents, and Books for new files'**
  String get rescanSub;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get openSourceLicenses;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'v{version}'**
  String appVersion(String version);

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @appLanguageSub.
  ///
  /// In en, this message translates to:
  /// **'Choose the language for the app\'s interface'**
  String get appLanguageSub;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @takeTourAgain.
  ///
  /// In en, this message translates to:
  /// **'Take the tour again'**
  String get takeTourAgain;

  /// No description provided for @takeTourAgainSub.
  ///
  /// In en, this message translates to:
  /// **'Replay the feature highlights'**
  String get takeTourAgainSub;

  /// No description provided for @backToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Back to library'**
  String get backToLibrary;

  /// No description provided for @bookmarksTooltip.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarksTooltip;

  /// No description provided for @bookmarkThisPage.
  ///
  /// In en, this message translates to:
  /// **'Bookmark this page'**
  String get bookmarkThisPage;

  /// No description provided for @previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get previousPage;

  /// No description provided for @nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPage;

  /// No description provided for @screenBrightness.
  ///
  /// In en, this message translates to:
  /// **'Screen brightness'**
  String get screenBrightness;

  /// No description provided for @pauseReading.
  ///
  /// In en, this message translates to:
  /// **'Pause reading'**
  String get pauseReading;

  /// No description provided for @resumeReading.
  ///
  /// In en, this message translates to:
  /// **'Resume reading'**
  String get resumeReading;

  /// No description provided for @readAloud.
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get readAloud;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @stopReading.
  ///
  /// In en, this message translates to:
  /// **'Stop reading'**
  String get stopReading;

  /// No description provided for @noBookmarks.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet. Tap the bookmark icon to add one.'**
  String get noBookmarks;

  /// A single page label in the bookmarks list
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String pageNumber(int page);

  /// No description provided for @bookNotFound.
  ///
  /// In en, this message translates to:
  /// **'Book not found'**
  String get bookNotFound;

  /// No description provided for @cantOpenBook.
  ///
  /// In en, this message translates to:
  /// **'Can\'t open this book'**
  String get cantOpenBook;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// No description provided for @findPdfsTitle.
  ///
  /// In en, this message translates to:
  /// **'Find PDFs on your device'**
  String get findPdfsTitle;

  /// No description provided for @storageAccessOff.
  ///
  /// In en, this message translates to:
  /// **'Storage access is off'**
  String get storageAccessOff;

  /// No description provided for @storageAccessOffBody.
  ///
  /// In en, this message translates to:
  /// **'Open Settings to let Comfy Reader find PDFs on your device — or just tap + to add them manually.'**
  String get storageAccessOffBody;

  /// No description provided for @openSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettingsLabel;

  /// No description provided for @tourLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your books'**
  String get tourLibraryTitle;

  /// No description provided for @tourLibraryBody.
  ///
  /// In en, this message translates to:
  /// **'All your imported and scanned PDFs live here.'**
  String get tourLibraryBody;

  /// No description provided for @tourReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue reading'**
  String get tourReadingTitle;

  /// No description provided for @tourReadingBody.
  ///
  /// In en, this message translates to:
  /// **'Jump back into books you\'ve started, right where you left off.'**
  String get tourReadingBody;

  /// No description provided for @tourSettingsNavTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tourSettingsNavTitle;

  /// No description provided for @tourSettingsNavBody.
  ///
  /// In en, this message translates to:
  /// **'Themes, languages, read-aloud voices, and more.'**
  String get tourSettingsNavBody;

  /// No description provided for @tourSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tourSearchTitle;

  /// No description provided for @tourSearchBody.
  ///
  /// In en, this message translates to:
  /// **'Find a book by its title.'**
  String get tourSearchBody;

  /// No description provided for @tourLayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Grid or list'**
  String get tourLayoutTitle;

  /// No description provided for @tourLayoutBody.
  ///
  /// In en, this message translates to:
  /// **'Switch between grid and list views.'**
  String get tourLayoutBody;

  /// No description provided for @tourAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a book'**
  String get tourAddTitle;

  /// No description provided for @tourAddBody.
  ///
  /// In en, this message translates to:
  /// **'Import a PDF from your device to start reading.'**
  String get tourAddBody;

  /// No description provided for @tourThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get tourThemeTitle;

  /// No description provided for @tourThemeBody.
  ///
  /// In en, this message translates to:
  /// **'Switch between Day, Night, or follow your system.'**
  String get tourThemeBody;

  /// No description provided for @tourLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get tourLanguageTitle;

  /// No description provided for @tourLanguageBody.
  ///
  /// In en, this message translates to:
  /// **'Read the app\'s interface in your preferred language.'**
  String get tourLanguageBody;

  /// No description provided for @tourVoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Read-aloud voices'**
  String get tourVoicesTitle;

  /// No description provided for @tourVoicesBody.
  ///
  /// In en, this message translates to:
  /// **'Pick voices and download languages for read-aloud.'**
  String get tourVoicesBody;

  /// No description provided for @tourTintTitle.
  ///
  /// In en, this message translates to:
  /// **'Comfort tint'**
  String get tourTintTitle;

  /// No description provided for @tourTintBody.
  ///
  /// In en, this message translates to:
  /// **'Set the default paper tint for new books.'**
  String get tourTintBody;

  /// No description provided for @tourTapTitle.
  ///
  /// In en, this message translates to:
  /// **'Show the controls'**
  String get tourTapTitle;

  /// No description provided for @tourTapBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the middle of the page to show or hide the reader controls.'**
  String get tourTapBody;

  /// No description provided for @tourScrubberTitle.
  ///
  /// In en, this message translates to:
  /// **'Jump to a page'**
  String get tourScrubberTitle;

  /// No description provided for @tourScrubberBody.
  ///
  /// In en, this message translates to:
  /// **'Drag to preview and jump to any page.'**
  String get tourScrubberBody;

  /// No description provided for @tourReadAloudTitle.
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get tourReadAloudTitle;

  /// No description provided for @tourReadAloudBody.
  ///
  /// In en, this message translates to:
  /// **'Have the book read to you out loud.'**
  String get tourReadAloudBody;

  /// No description provided for @tourReaderTintTitle.
  ///
  /// In en, this message translates to:
  /// **'Comfort tint'**
  String get tourReaderTintTitle;

  /// No description provided for @tourReaderTintBody.
  ///
  /// In en, this message translates to:
  /// **'Cycle paper, sepia, and night tints.'**
  String get tourReaderTintBody;

  /// No description provided for @tourBrightnessTitle.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get tourBrightnessTitle;

  /// No description provided for @tourBrightnessBody.
  ///
  /// In en, this message translates to:
  /// **'Adjust screen brightness without leaving the book.'**
  String get tourBrightnessBody;

  /// No description provided for @tourBookmarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get tourBookmarkTitle;

  /// No description provided for @tourBookmarkBody.
  ///
  /// In en, this message translates to:
  /// **'Save your place and find it again later.'**
  String get tourBookmarkBody;

  /// No description provided for @tourSwipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Turning pages'**
  String get tourSwipeTitle;

  /// No description provided for @tourSwipeShortBody.
  ///
  /// In en, this message translates to:
  /// **'A short swipe springs back — the page stays put.'**
  String get tourSwipeShortBody;

  /// No description provided for @tourSwipeLongBody.
  ///
  /// In en, this message translates to:
  /// **'A long swipe turns the page.'**
  String get tourSwipeLongBody;

  /// No description provided for @tourSwipeFastBody.
  ///
  /// In en, this message translates to:
  /// **'A quick flick turns the page too.'**
  String get tourSwipeFastBody;

  /// Toggle: OCR scanned (image-only) PDF pages for read-aloud
  ///
  /// In en, this message translates to:
  /// **'Read scanned books'**
  String get readScannedBooks;

  /// No description provided for @readScannedBooksSub.
  ///
  /// In en, this message translates to:
  /// **'Use on-device OCR to read pages that have no selectable text'**
  String get readScannedBooksSub;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'bn',
    'en',
    'gu',
    'hi',
    'kn',
    'ml',
    'mr',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
