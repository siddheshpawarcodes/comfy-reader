// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get appTitle => 'Comfy Reader';

  @override
  String get appTagline => 'ഒരു യഥാർത്ഥ പുസ്തകം പോലെ വായിക്കൂ.';

  @override
  String get navLibrary => 'ലൈബ്രറി';

  @override
  String get navReading => 'വായന';

  @override
  String get navSettings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get close => 'അടയ്ക്കുക';

  @override
  String get notNow => 'ഇപ്പോൾ വേണ്ട';

  @override
  String get continueLabel => 'തുടരുക';

  @override
  String get open => 'തുറക്കുക';

  @override
  String get goBack => 'തിരികെ പോകുക';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Exit';

  @override
  String get quitAppTitle => 'Quit Comfy Reader?';

  @override
  String get quitAppMessage => 'Are you sure you want to close the app?';

  @override
  String get libraryTitle => 'ലൈബ്രറി';

  @override
  String get searchTooltip => 'തിരയുക';

  @override
  String get closeSearchTooltip => 'തിരയൽ അടയ്ക്കുക';

  @override
  String get searchHint => 'ശീർഷകങ്ങൾ തിരയുക…';

  @override
  String get toggleLayoutTooltip => 'ലേഔട്ട് മാറ്റുക';

  @override
  String get dayTheme => 'പകൽ തീം';

  @override
  String get nightTheme => 'രാത്രി തീം';

  @override
  String get sortRecent => 'ക്രമം: പുതിയത്';

  @override
  String get sortName => 'ക്രമം: പേര്';

  @override
  String get sortDateAdded => 'ക്രമം: ചേർത്ത തീയതി';

  @override
  String get noStorageAccess =>
      'സ്റ്റോറേജ് ആക്സസ് ഇല്ല — PDF ചേർക്കാൻ + അമർത്തുക.';

  @override
  String get noNewBooks => 'പുതിയ പുസ്തകങ്ങളൊന്നും ഇല്ല';

  @override
  String foundBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count പുസ്തകങ്ങൾ കണ്ടെത്തി',
      one: '1 പുസ്തകം കണ്ടെത്തി',
    );
    return '$_temp0';
  }

  @override
  String get emptyNoMatches => 'പൊരുത്തങ്ങളില്ല';

  @override
  String get emptyTryDifferent => 'മറ്റൊരു ശീർഷകം പരീക്ഷിക്കൂ.';

  @override
  String get emptyNoBooks => 'ഇതുവരെ പുസ്തകങ്ങളില്ല';

  @override
  String get emptyNoBooksBody =>
      'PDF ചേർക്കാൻ + അമർത്തുക, അല്ലെങ്കിൽ ഉപകരണം സ്കാൻ ചെയ്യാൻ താഴേക്ക് വലിക്കുക.';

  @override
  String get continueReadingTitle => 'വായന തുടരുക';

  @override
  String get nothingInProgress => 'ഒന്നും പുരോഗമിക്കുന്നില്ല';

  @override
  String get nothingInProgressBody =>
      'നിങ്ങളുടെ ലൈബ്രറിയിൽ നിന്ന് ഒരു പുസ്തകം തുറക്കൂ, അത് ഇവിടെ കാണിക്കും, അങ്ങനെ നിർത്തിയിടത്ത് നിന്ന് തുടരാം.';

  @override
  String pageOfTotal(int current, int total) {
    return 'പേജ് $current / $total';
  }

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String get details => 'വിശദാംശങ്ങൾ';

  @override
  String get removeFromLibrary => 'ലൈബ്രറിയിൽ നിന്ന് നീക്കുക';

  @override
  String get detailPages => 'പേജുകൾ';

  @override
  String get detailSize => 'വലുപ്പം';

  @override
  String get detailProgress => 'പുരോഗതി';

  @override
  String get detailSource => 'ഉറവിടം';

  @override
  String get sourceImported => 'ഇറക്കുമതി ചെയ്തത്';

  @override
  String get sourceOnDevice => 'ഉപകരണത്തിൽ';

  @override
  String get addPdf => 'PDF ചേർക്കുക';

  @override
  String addedBook(String title) {
    return '\"$title\" ചേർത്തു';
  }

  @override
  String get couldntImport => 'ആ ഫയൽ ഇറക്കുമതി ചെയ്യാനായില്ല.';

  @override
  String get settingsTitle => 'ക്രമീകരണങ്ങൾ';

  @override
  String get appearance => 'രൂപഭാവം';

  @override
  String get themeSystem => 'സിസ്റ്റം';

  @override
  String get themeDay => 'പകൽ';

  @override
  String get themeNight => 'രാത്രി';

  @override
  String get reading => 'വായന';

  @override
  String get pageTurnSound => 'പേജ് മറിക്കൽ ശബ്ദം';

  @override
  String get pageTurnSoundSub => 'ഓരോ മറിക്കലിലും മൃദുവായ ശബ്ദം';

  @override
  String get volume => 'ശബ്ദനില';

  @override
  String get haptics => 'സ്പന്ദനം';

  @override
  String get hapticsSub => 'പേജ് മറിക്കുമ്പോൾ ലഘു സ്പന്ദനം';

  @override
  String get keepScreenOn => 'സ്ക്രീൻ ഓണാക്കി വയ്ക്കുക';

  @override
  String get keepScreenOnSub => 'വായിക്കുമ്പോൾ സ്ക്രീൻ ഉറങ്ങാതിരിക്കാൻ';

  @override
  String get readAloudSpeed => 'ഉറക്കെ വായന വേഗത';

  @override
  String get readAloudVoices => 'ഉറക്കെ വായന ശബ്ദങ്ങൾ';

  @override
  String get readAloudVoicesSub => 'ഭാഷകൾ, ശബ്ദ നിലവാരം, ഡൗൺലോഡുകൾ';

  @override
  String get defaultPageTint => 'സ്ഥിര പേജ് നിറം';

  @override
  String get tintPaper => 'കടലാസ്';

  @override
  String get tintSepia => 'സെപിയ';

  @override
  String get tintNight => 'രാത്രി';

  @override
  String get defaultPageTintNote =>
      'പുതിയ പുസ്തകങ്ങൾ ഈ നിറത്തിൽ തുറക്കും. വായനക്കാരനിൽ ഓരോ പുസ്തകത്തിനും ഇത് മാറ്റാം.';

  @override
  String get librarySection => 'ലൈബ്രറി';

  @override
  String get rescanTitle => 'PDF-കൾക്കായി ഉപകരണം വീണ്ടും സ്കാൻ ചെയ്യുക';

  @override
  String get rescanSub =>
      'പുതിയ ഫയലുകൾക്കായി Downloads, Documents, Books തിരയുക';

  @override
  String get about => 'കുറിച്ച്';

  @override
  String get openSourceLicenses => 'ഓപ്പൺ-സോഴ്സ് ലൈസൻസുകൾ';

  @override
  String appVersion(String version) {
    return 'v$version';
  }

  @override
  String get appLanguage => 'ആപ്പ് ഭാഷ';

  @override
  String get appLanguageSub => 'ആപ്പ് ഇന്റർഫേസിന്റെ ഭാഷ തിരഞ്ഞെടുക്കുക';

  @override
  String get chooseLanguage => 'ഭാഷ തിരഞ്ഞെടുക്കുക';

  @override
  String get takeTourAgain => 'വീണ്ടും ടൂർ ചെയ്യുക';

  @override
  String get takeTourAgainSub => 'സവിശേഷതകൾ വീണ്ടും കാണുക';

  @override
  String get backToLibrary => 'ലൈബ്രറിയിലേക്ക് മടങ്ങുക';

  @override
  String get bookmarksTooltip => 'ബുക്ക്മാർക്കുകൾ';

  @override
  String get bookmarkThisPage => 'ഈ പേജ് ബുക്ക്മാർക്ക് ചെയ്യുക';

  @override
  String get previousPage => 'മുൻ പേജ്';

  @override
  String get nextPage => 'അടുത്ത പേജ്';

  @override
  String get screenBrightness => 'സ്ക്രീൻ തെളിച്ചം';

  @override
  String get pauseReading => 'വായന താൽക്കാലികമായി നിർത്തുക';

  @override
  String get resumeReading => 'വായന തുടരുക';

  @override
  String get readAloud => 'ഉറക്കെ വായിക്കുക';

  @override
  String get pause => 'താൽക്കാലികമായി നിർത്തുക';

  @override
  String get play => 'പ്ലേ ചെയ്യുക';

  @override
  String get stopReading => 'വായന നിർത്തുക';

  @override
  String get noBookmarks =>
      'ഇതുവരെ ബുക്ക്മാർക്കുകളില്ല. ചേർക്കാൻ ബുക്ക്മാർക്ക് ഐക്കൺ അമർത്തുക.';

  @override
  String pageNumber(int page) {
    return 'പേജ് $page';
  }

  @override
  String get bookNotFound => 'പുസ്തകം കണ്ടെത്തിയില്ല';

  @override
  String get cantOpenBook => 'ഈ പുസ്തകം തുറക്കാനാവില്ല';

  @override
  String get somethingWentWrong => 'എന്തോ കുഴപ്പം സംഭവിച്ചു.';

  @override
  String get findPdfsTitle => 'നിങ്ങളുടെ ഉപകരണത്തിൽ PDF കണ്ടെത്തുക';

  @override
  String get storageAccessOff => 'സ്റ്റോറേജ് ആക്സസ് ഓഫാണ്';

  @override
  String get storageAccessOffBody =>
      'ഉപകരണത്തിലെ PDF കണ്ടെത്താൻ Comfy Reader-നെ അനുവദിക്കാൻ ക്രമീകരണങ്ങൾ തുറക്കുക — അല്ലെങ്കിൽ + അമർത്തി സ്വയം ചേർക്കുക.';

  @override
  String get openSettingsLabel => 'ക്രമീകരണങ്ങൾ തുറക്കുക';

  @override
  String get tourLibraryTitle => 'നിങ്ങളുടെ പുസ്തകങ്ങൾ';

  @override
  String get tourLibraryBody =>
      'ഇറക്കുമതി ചെയ്തതും സ്കാൻ ചെയ്തതുമായ എല്ലാ PDF-കളും ഇവിടെയുണ്ട്.';

  @override
  String get tourReadingTitle => 'വായന തുടരുക';

  @override
  String get tourReadingBody =>
      'തുടങ്ങിയ പുസ്തകങ്ങളിലേക്ക് നിർത്തിയിടത്ത് നിന്ന് മടങ്ങുക.';

  @override
  String get tourSettingsNavTitle => 'ക്രമീകരണങ്ങൾ';

  @override
  String get tourSettingsNavBody =>
      'തീമുകൾ, ഭാഷകൾ, ഉറക്കെ വായന ശബ്ദങ്ങൾ എന്നിവയും അതിലേറെയും.';

  @override
  String get tourSearchTitle => 'തിരയുക';

  @override
  String get tourSearchBody => 'ശീർഷകം ഉപയോഗിച്ച് പുസ്തകം കണ്ടെത്തുക.';

  @override
  String get tourLayoutTitle => 'ഗ്രിഡ് അല്ലെങ്കിൽ ലിസ്റ്റ്';

  @override
  String get tourLayoutBody => 'ഗ്രിഡ്, ലിസ്റ്റ് കാഴ്ചകൾക്കിടയിൽ മാറുക.';

  @override
  String get tourAddTitle => 'ഒരു പുസ്തകം ചേർക്കുക';

  @override
  String get tourAddBody =>
      'വായന തുടങ്ങാൻ ഉപകരണത്തിൽ നിന്ന് ഒരു PDF ഇറക്കുമതി ചെയ്യുക.';

  @override
  String get tourThemeTitle => 'രൂപഭാവം';

  @override
  String get tourThemeBody =>
      'പകൽ, രാത്രി, അല്ലെങ്കിൽ സിസ്റ്റം അനുസരിച്ച് മാറുക.';

  @override
  String get tourLanguageTitle => 'ആപ്പ് ഭാഷ';

  @override
  String get tourLanguageBody => 'ഇഷ്ടഭാഷയിൽ ആപ്പ് ഇന്റർഫേസ് വായിക്കുക.';

  @override
  String get tourVoicesTitle => 'ഉറക്കെ വായന ശബ്ദങ്ങൾ';

  @override
  String get tourVoicesBody =>
      'ഉറക്കെ വായനയ്ക്ക് ശബ്ദങ്ങൾ തിരഞ്ഞെടുത്ത് ഭാഷകൾ ഡൗൺലോഡ് ചെയ്യുക.';

  @override
  String get tourTintTitle => 'സുഖകര നിറം';

  @override
  String get tourTintBody =>
      'പുതിയ പുസ്തകങ്ങൾക്ക് സ്ഥിര കടലാസ് നിറം സജ്ജമാക്കുക.';

  @override
  String get tourTapTitle => 'നിയന്ത്രണങ്ങൾ കാണിക്കുക';

  @override
  String get tourTapBody =>
      'നിയന്ത്രണങ്ങൾ കാണിക്കാനോ മറയ്ക്കാനോ പേജിന്റെ മധ്യഭാഗത്ത് അമർത്തുക.';

  @override
  String get tourScrubberTitle => 'ഒരു പേജിലേക്ക് പോകുക';

  @override
  String get tourScrubberBody =>
      'ഏത് പേജും കാണാനും അതിലേക്ക് പോകാനും വലിക്കുക.';

  @override
  String get tourReadAloudTitle => 'ഉറക്കെ വായിക്കുക';

  @override
  String get tourReadAloudBody =>
      'പുസ്തകം നിങ്ങൾക്കായി ഉറക്കെ വായിച്ചുകേൾപ്പിക്കുക.';

  @override
  String get tourReaderTintTitle => 'സുഖകര നിറം';

  @override
  String get tourReaderTintBody => 'കടലാസ്, സെപിയ, രാത്രി നിറങ്ങൾ മാറ്റുക.';

  @override
  String get tourBrightnessTitle => 'തെളിച്ചം';

  @override
  String get tourBrightnessBody =>
      'പുസ്തകം വിടാതെ സ്ക്രീൻ തെളിച്ചം ക്രമീകരിക്കുക.';

  @override
  String get tourBookmarkTitle => 'ബുക്ക്മാർക്ക്';

  @override
  String get tourBookmarkBody =>
      'നിങ്ങളുടെ ഇടം സംരക്ഷിച്ച് പിന്നീട് കണ്ടെത്തുക.';

  @override
  String get tourSwipeTitle => 'പേജ് മറിക്കൽ';

  @override
  String get tourSwipeShortBody =>
      'ചെറിയ സ്വൈപ്പ് തിരികെ പോകും, പേജ് മറിയില്ല.';

  @override
  String get tourSwipeLongBody => 'നീണ്ട സ്വൈപ്പ് പേജ് മറിക്കും.';

  @override
  String get tourSwipeFastBody => 'വേഗത്തിലുള്ള സ്വൈപ്പും പേജ് മറിക്കും.';

  @override
  String get readScannedBooks => 'സ്കാൻ ചെയ്ത പുസ്തകങ്ങൾ വായിക്കുക';

  @override
  String get readScannedBooksSub =>
      'തിരഞ്ഞെടുക്കാവുന്ന ടെക്സ്റ്റ് ഇല്ലാത്ത പേജുകൾ വായിക്കാൻ ഉപകരണ OCR ഉപയോഗിക്കുക';
}
