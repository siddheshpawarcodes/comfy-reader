// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appTitle => 'Comfy Reader';

  @override
  String get appTagline => 'ખરા પુસ્તક જેવું વાંચન.';

  @override
  String get navLibrary => 'લાઇબ્રેરી';

  @override
  String get navReading => 'વાંચન';

  @override
  String get navSettings => 'સેટિંગ્સ';

  @override
  String get close => 'બંધ કરો';

  @override
  String get notNow => 'હમણાં નહીં';

  @override
  String get continueLabel => 'ચાલુ રાખો';

  @override
  String get open => 'ખોલો';

  @override
  String get goBack => 'પાછા જાઓ';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Exit';

  @override
  String get quitAppTitle => 'Quit Comfy Reader?';

  @override
  String get quitAppMessage => 'Are you sure you want to close the app?';

  @override
  String get libraryTitle => 'લાઇબ્રેરી';

  @override
  String get searchTooltip => 'શોધો';

  @override
  String get closeSearchTooltip => 'શોધ બંધ કરો';

  @override
  String get searchHint => 'શીર્ષક શોધો…';

  @override
  String get toggleLayoutTooltip => 'લેઆઉટ બદલો';

  @override
  String get dayTheme => 'દિવસ થીમ';

  @override
  String get nightTheme => 'રાત્રિ થીમ';

  @override
  String get sortRecent => 'ક્રમ: તાજેતરનું';

  @override
  String get sortName => 'ક્રમ: નામ';

  @override
  String get sortDateAdded => 'ક્રમ: ઉમેર્યાની તારીખ';

  @override
  String get noStorageAccess => 'સ્ટોરેજ ઍક્સેસ નથી — PDF ઉમેરવા + દબાવો.';

  @override
  String get noNewBooks => 'કોઈ નવાં પુસ્તકો મળ્યાં નથી';

  @override
  String foundBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count પુસ્તકો મળ્યાં',
      one: '1 પુસ્તક મળ્યું',
    );
    return '$_temp0';
  }

  @override
  String get emptyNoMatches => 'કોઈ મેળ નથી';

  @override
  String get emptyTryDifferent => 'બીજું શીર્ષક અજમાવો.';

  @override
  String get emptyNoBooks => 'હજી કોઈ પુસ્તકો નથી';

  @override
  String get emptyNoBooksBody =>
      'PDF ઉમેરવા + દબાવો, અથવા ડિવાઇસ સ્કૅન કરવા નીચે ખેંચો.';

  @override
  String get continueReadingTitle => 'વાંચન ચાલુ રાખો';

  @override
  String get nothingInProgress => 'કંઈ ચાલુ નથી';

  @override
  String get nothingInProgressBody =>
      'તમારી લાઇબ્રેરીમાંથી પુસ્તક ખોલો અને તે અહીં દેખાશે, જેથી તમે જ્યાં છોડ્યું ત્યાંથી જ આગળ વધી શકો.';

  @override
  String pageOfTotal(int current, int total) {
    return 'પાનું $current / $total';
  }

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String get details => 'વિગતો';

  @override
  String get removeFromLibrary => 'લાઇબ્રેરીમાંથી દૂર કરો';

  @override
  String get detailPages => 'પાનાં';

  @override
  String get detailSize => 'કદ';

  @override
  String get detailProgress => 'પ્રગતિ';

  @override
  String get detailSource => 'સ્રોત';

  @override
  String get sourceImported => 'આયાત કરેલ';

  @override
  String get sourceOnDevice => 'ડિવાઇસ પર';

  @override
  String get addPdf => 'PDF ઉમેરો';

  @override
  String addedBook(String title) {
    return '\"$title\" ઉમેર્યું';
  }

  @override
  String get couldntImport => 'એ ફાઇલ આયાત કરી શકાઈ નહીં.';

  @override
  String get settingsTitle => 'સેટિંગ્સ';

  @override
  String get appearance => 'દેખાવ';

  @override
  String get themeSystem => 'સિસ્ટમ';

  @override
  String get themeDay => 'દિવસ';

  @override
  String get themeNight => 'રાત્રિ';

  @override
  String get reading => 'વાંચન';

  @override
  String get pageTurnSound => 'પાનું ફેરવવાનો અવાજ';

  @override
  String get pageTurnSoundSub => 'દરેક ફેરવ પર હળવો ફ્લિપ અવાજ વગાડો';

  @override
  String get volume => 'વોલ્યુમ';

  @override
  String get haptics => 'હૅપ્ટિક્સ';

  @override
  String get hapticsSub => 'પાનું ફરી રહ્યે હળવો કંપન';

  @override
  String get keepScreenOn => 'સ્ક્રીન ચાલુ રાખો';

  @override
  String get keepScreenOnSub => 'વાંચતી વખતે સ્ક્રીન સ્લીપ થતી અટકાવો';

  @override
  String get readAloudSpeed => 'વાંચન ગતિ';

  @override
  String get readAloudVoices => 'વાંચન અવાજો';

  @override
  String get readAloudVoicesSub => 'ભાષાઓ, અવાજ ગુણવત્તા અને ડાઉનલોડ';

  @override
  String get defaultPageTint => 'મૂળભૂત પાનું રંગછટા';

  @override
  String get tintPaper => 'કાગળ';

  @override
  String get tintSepia => 'સેપિયા';

  @override
  String get tintNight => 'રાત્રિ';

  @override
  String get defaultPageTintNote =>
      'નવાં પુસ્તકો આ રંગછટા સાથે ખૂલે છે. તમે હજુ પણ રીડરમાંથી દરેક પુસ્તક માટે તે બદલી શકો છો.';

  @override
  String get librarySection => 'લાઇબ્રેરી';

  @override
  String get rescanTitle => 'PDF માટે ડિવાઇસ ફરી સ્કૅન કરો';

  @override
  String get rescanSub => 'નવી ફાઇલો માટે Downloads, Documents અને Books શોધો';

  @override
  String get about => 'વિશે';

  @override
  String get openSourceLicenses => 'ઓપન-સોર્સ લાઇસન્સ';

  @override
  String appVersion(String version) {
    return 'v$version';
  }

  @override
  String get appLanguage => 'ઍપ ભાષા';

  @override
  String get appLanguageSub => 'ઍપના ઇન્ટરફેસ માટે ભાષા પસંદ કરો';

  @override
  String get chooseLanguage => 'ભાષા પસંદ કરો';

  @override
  String get takeTourAgain => 'ફરી ટૂર લો';

  @override
  String get takeTourAgainSub => 'ફીચર હાઇલાઇટ્સ ફરી જુઓ';

  @override
  String get backToLibrary => 'લાઇબ્રેરી પર પાછા';

  @override
  String get bookmarksTooltip => 'બુકમાર્ક્સ';

  @override
  String get bookmarkThisPage => 'આ પાનું બુકમાર્ક કરો';

  @override
  String get previousPage => 'પાછલું પાનું';

  @override
  String get nextPage => 'આગલું પાનું';

  @override
  String get screenBrightness => 'સ્ક્રીન બ્રાઇટનેસ';

  @override
  String get pauseReading => 'વાંચન થોભાવો';

  @override
  String get resumeReading => 'વાંચન ફરી શરૂ કરો';

  @override
  String get readAloud => 'મોટેથી વાંચો';

  @override
  String get pause => 'થોભાવો';

  @override
  String get play => 'વગાડો';

  @override
  String get stopReading => 'વાંચન રોકો';

  @override
  String get noBookmarks => 'હજી કોઈ બુકમાર્ક નથી. ઉમેરવા બુકમાર્ક આઇકન દબાવો.';

  @override
  String pageNumber(int page) {
    return 'પાનું $page';
  }

  @override
  String get bookNotFound => 'પુસ્તક મળ્યું નથી';

  @override
  String get cantOpenBook => 'આ પુસ્તક ખોલી શકાતું નથી';

  @override
  String get somethingWentWrong => 'કંઈક ખોટું થયું.';

  @override
  String get findPdfsTitle => 'તમારા ડિવાઇસ પર PDF શોધો';

  @override
  String get storageAccessOff => 'સ્ટોરેજ ઍક્સેસ બંધ છે';

  @override
  String get storageAccessOffBody =>
      'Comfy Reader ને તમારા ડિવાઇસ પર PDF શોધવા દેવા સેટિંગ્સ ખોલો — અથવા જાતે ઉમેરવા + દબાવો.';

  @override
  String get openSettingsLabel => 'સેટિંગ્સ ખોલો';

  @override
  String get tourLibraryTitle => 'તમારાં પુસ્તકો';

  @override
  String get tourLibraryBody =>
      'તમારાં બધાં આયાત કરેલ અને સ્કૅન કરેલ PDF અહીં રહે છે.';

  @override
  String get tourReadingTitle => 'વાંચન ચાલુ રાખો';

  @override
  String get tourReadingBody =>
      'તમે શરૂ કરેલાં પુસ્તકોમાં જ્યાં છોડ્યું ત્યાંથી જ પાછા ફરો.';

  @override
  String get tourSettingsNavTitle => 'સેટિંગ્સ';

  @override
  String get tourSettingsNavBody => 'થીમ્સ, ભાષાઓ, વાંચન અવાજો અને વધુ.';

  @override
  String get tourSearchTitle => 'શોધો';

  @override
  String get tourSearchBody => 'શીર્ષક દ્વારા પુસ્તક શોધો.';

  @override
  String get tourLayoutTitle => 'ગ્રિડ કે યાદી';

  @override
  String get tourLayoutBody => 'ગ્રિડ અને યાદી દૃશ્ય વચ્ચે બદલો.';

  @override
  String get tourAddTitle => 'પુસ્તક ઉમેરો';

  @override
  String get tourAddBody => 'વાંચન શરૂ કરવા તમારા ડિવાઇસથી PDF આયાત કરો.';

  @override
  String get tourThemeTitle => 'દેખાવ';

  @override
  String get tourThemeBody => 'દિવસ, રાત્રિ વચ્ચે બદલો કે સિસ્ટમ અનુસરો.';

  @override
  String get tourLanguageTitle => 'ઍપ ભાષા';

  @override
  String get tourLanguageBody => 'ઍપનું ઇન્ટરફેસ તમારી પસંદની ભાષામાં વાંચો.';

  @override
  String get tourVoicesTitle => 'વાંચન અવાજો';

  @override
  String get tourVoicesBody =>
      'વાંચન માટે અવાજો પસંદ કરો અને ભાષાઓ ડાઉનલોડ કરો.';

  @override
  String get tourTintTitle => 'આરામ રંગછટા';

  @override
  String get tourTintBody => 'નવાં પુસ્તકો માટે મૂળભૂત કાગળ રંગછટા સેટ કરો.';

  @override
  String get tourTapTitle => 'નિયંત્રણો બતાવો';

  @override
  String get tourTapBody =>
      'રીડર નિયંત્રણો બતાવવા કે છુપાવવા પાનાની વચ્ચે દબાવો.';

  @override
  String get tourScrubberTitle => 'પાના પર જાઓ';

  @override
  String get tourScrubberBody => 'કોઈપણ પાનું જોવા અને ત્યાં જવા ખેંચો.';

  @override
  String get tourReadAloudTitle => 'મોટેથી વાંચો';

  @override
  String get tourReadAloudBody => 'પુસ્તક તમને મોટેથી વાંચાવો.';

  @override
  String get tourReaderTintTitle => 'આરામ રંગછટા';

  @override
  String get tourReaderTintBody =>
      'કાગળ, સેપિયા અને રાત્રિ રંગછટા વચ્ચે ફેરવો.';

  @override
  String get tourBrightnessTitle => 'બ્રાઇટનેસ';

  @override
  String get tourBrightnessBody => 'પુસ્તક છોડ્યા વગર સ્ક્રીન બ્રાઇટનેસ ગોઠવો.';

  @override
  String get tourBookmarkTitle => 'બુકમાર્ક';

  @override
  String get tourBookmarkBody => 'તમારી જગ્યા સાચવો અને પછી ફરી શોધો.';

  @override
  String get readScannedBooks => 'સ્કેન કરેલી ચોપડીઓ વાંચો';

  @override
  String get readScannedBooksSub =>
      'પસંદ કરી શકાય તેવો ટેક્સ્ટ ન હોય તેવા પાનાં વાંચવા ઉપકરણ OCR વાપરો';
}
