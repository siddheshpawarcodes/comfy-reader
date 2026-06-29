// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'Comfy Reader';

  @override
  String get appTagline => 'உண்மையான புத்தகம் போல் படியுங்கள்.';

  @override
  String get navLibrary => 'நூலகம்';

  @override
  String get navReading => 'படிப்பு';

  @override
  String get navSettings => 'அமைப்புகள்';

  @override
  String get close => 'மூடு';

  @override
  String get notNow => 'இப்போது வேண்டாம்';

  @override
  String get continueLabel => 'தொடரவும்';

  @override
  String get open => 'திற';

  @override
  String get goBack => 'திரும்பிச் செல்';

  @override
  String get libraryTitle => 'நூலகம்';

  @override
  String get searchTooltip => 'தேடு';

  @override
  String get closeSearchTooltip => 'தேடலை மூடு';

  @override
  String get searchHint => 'தலைப்புகளைத் தேடு…';

  @override
  String get toggleLayoutTooltip => 'தளவமைப்பை மாற்று';

  @override
  String get dayTheme => 'பகல் தீம்';

  @override
  String get nightTheme => 'இரவு தீம்';

  @override
  String get sortRecent => 'வரிசை: சமீபத்தியது';

  @override
  String get sortName => 'வரிசை: பெயர்';

  @override
  String get sortDateAdded => 'வரிசை: சேர்த்த தேதி';

  @override
  String get noStorageAccess =>
      'சேமிப்பக அணுகல் இல்லை — PDFகளைச் சேர்க்க + ஐ தட்டவும்.';

  @override
  String get noNewBooks => 'புதிய புத்தகங்கள் எதுவும் இல்லை';

  @override
  String foundBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count புத்தகங்கள் கிடைத்தன',
      one: '1 புத்தகம் கிடைத்தது',
    );
    return '$_temp0';
  }

  @override
  String get emptyNoMatches => 'பொருத்தம் இல்லை';

  @override
  String get emptyTryDifferent => 'வேறு தலைப்பை முயற்சிக்கவும்.';

  @override
  String get emptyNoBooks => 'இன்னும் புத்தகங்கள் இல்லை';

  @override
  String get emptyNoBooksBody =>
      'PDF சேர்க்க + ஐ தட்டவும், அல்லது சாதனத்தை ஸ்கேன் செய்ய கீழே இழுக்கவும்.';

  @override
  String get continueReadingTitle => 'படிப்பைத் தொடரவும்';

  @override
  String get nothingInProgress => 'நடப்பில் எதுவும் இல்லை';

  @override
  String get nothingInProgressBody =>
      'உங்கள் நூலகத்திலிருந்து ஒரு புத்தகத்தைத் திறந்தால், நீங்கள் நிறுத்திய இடத்திலிருந்தே தொடர அது இங்கே தோன்றும்.';

  @override
  String pageOfTotal(int current, int total) {
    return 'பக்கம் $current / $total';
  }

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String get details => 'விவரங்கள்';

  @override
  String get removeFromLibrary => 'நூலகத்திலிருந்து நீக்கு';

  @override
  String get detailPages => 'பக்கங்கள்';

  @override
  String get detailSize => 'அளவு';

  @override
  String get detailProgress => 'முன்னேற்றம்';

  @override
  String get detailSource => 'மூலம்';

  @override
  String get sourceImported => 'இறக்குமதி செய்தது';

  @override
  String get sourceOnDevice => 'சாதனத்தில்';

  @override
  String get addPdf => 'PDF சேர்';

  @override
  String addedBook(String title) {
    return '\"$title\" சேர்க்கப்பட்டது';
  }

  @override
  String get couldntImport => 'அந்தக் கோப்பை இறக்குமதி செய்ய முடியவில்லை.';

  @override
  String get settingsTitle => 'அமைப்புகள்';

  @override
  String get appearance => 'தோற்றம்';

  @override
  String get themeSystem => 'சிஸ்டம்';

  @override
  String get themeDay => 'பகல்';

  @override
  String get themeNight => 'இரவு';

  @override
  String get reading => 'படிப்பு';

  @override
  String get pageTurnSound => 'பக்கம் புரட்டும் ஒலி';

  @override
  String get pageTurnSoundSub => 'ஒவ்வொரு புரட்டலிலும் மென்மையான ஒலி இயக்கு';

  @override
  String get volume => 'ஒலியளவு';

  @override
  String get haptics => 'அதிர்வு';

  @override
  String get hapticsSub => 'பக்கம் புரட்டியதும் மென்மையான அதிர்வு';

  @override
  String get keepScreenOn => 'திரையை இயக்கத்தில் வை';

  @override
  String get keepScreenOnSub => 'படிக்கும்போது திரை உறங்குவதைத் தடு';

  @override
  String get readAloudSpeed => 'வாசிப்பு வேகம்';

  @override
  String get readAloudVoices => 'வாசிப்பு குரல்கள்';

  @override
  String get readAloudVoicesSub => 'மொழிகள், குரல் தரம், பதிவிறக்கங்கள்';

  @override
  String get defaultPageTint => 'இயல்புநிலை பக்க நிறம்';

  @override
  String get tintPaper => 'காகிதம்';

  @override
  String get tintSepia => 'செபியா';

  @override
  String get tintNight => 'இரவு';

  @override
  String get defaultPageTintNote =>
      'புதிய புத்தகங்கள் இந்த நிறத்தில் திறக்கும். வாசிப்பானில் ஒவ்வொரு புத்தகத்திற்கும் இதை மாற்றலாம்.';

  @override
  String get librarySection => 'நூலகம்';

  @override
  String get rescanTitle => 'PDFகளுக்கு சாதனத்தை மீண்டும் ஸ்கேன் செய்';

  @override
  String get rescanSub =>
      'புதிய கோப்புகளுக்கு பதிவிறக்கங்கள், ஆவணங்கள், புத்தகங்களைத் தேடு';

  @override
  String get about => 'பற்றி';

  @override
  String get openSourceLicenses => 'திறந்த மூல உரிமங்கள்';

  @override
  String appVersion(String version) {
    return 'v$version';
  }

  @override
  String get appLanguage => 'ஆப் மொழி';

  @override
  String get appLanguageSub => 'ஆப் இடைமுகத்திற்கான மொழியைத் தேர்வுசெய்';

  @override
  String get chooseLanguage => 'மொழியைத் தேர்வுசெய்';

  @override
  String get takeTourAgain => 'மீண்டும் சுற்றுப்பயணம் செய்';

  @override
  String get takeTourAgainSub => 'அம்ச சிறப்பம்சங்களை மீண்டும் இயக்கு';

  @override
  String get backToLibrary => 'நூலகத்திற்குத் திரும்பு';

  @override
  String get bookmarksTooltip => 'புத்தகக்குறிகள்';

  @override
  String get bookmarkThisPage => 'இந்தப் பக்கத்தைக் குறி';

  @override
  String get previousPage => 'முந்தைய பக்கம்';

  @override
  String get nextPage => 'அடுத்த பக்கம்';

  @override
  String get screenBrightness => 'திரை பிரகாசம்';

  @override
  String get pauseReading => 'படிப்பை இடைநிறுத்து';

  @override
  String get resumeReading => 'படிப்பைத் தொடர்';

  @override
  String get readAloud => 'உரக்கப் படி';

  @override
  String get pause => 'இடைநிறுத்து';

  @override
  String get play => 'இயக்கு';

  @override
  String get stopReading => 'படிப்பை நிறுத்து';

  @override
  String get noBookmarks =>
      'இன்னும் புத்தகக்குறிகள் இல்லை. சேர்க்க புத்தகக்குறி ஐகானைத் தட்டவும்.';

  @override
  String pageNumber(int page) {
    return 'பக்கம் $page';
  }

  @override
  String get bookNotFound => 'புத்தகம் கிடைக்கவில்லை';

  @override
  String get cantOpenBook => 'இந்தப் புத்தகத்தைத் திறக்க முடியவில்லை';

  @override
  String get somethingWentWrong => 'ஏதோ தவறு நடந்தது.';

  @override
  String get findPdfsTitle => 'உங்கள் சாதனத்தில் PDFகளைக் கண்டறி';

  @override
  String get storageAccessOff => 'சேமிப்பக அணுகல் முடக்கப்பட்டுள்ளது';

  @override
  String get storageAccessOffBody =>
      'உங்கள் சாதனத்தில் Comfy Reader PDFகளைக் கண்டறிய அமைப்புகளைத் திறக்கவும் — அல்லது அவற்றை கைமுறையாகச் சேர்க்க + ஐ தட்டவும்.';

  @override
  String get openSettingsLabel => 'அமைப்புகளைத் திற';

  @override
  String get tourLibraryTitle => 'உங்கள் புத்தகங்கள்';

  @override
  String get tourLibraryBody =>
      'இறக்குமதி செய்த மற்றும் ஸ்கேன் செய்த அனைத்து PDFகளும் இங்கே உள்ளன.';

  @override
  String get tourReadingTitle => 'படிப்பைத் தொடரவும்';

  @override
  String get tourReadingBody =>
      'தொடங்கிய புத்தகங்களுக்கு நீங்கள் நிறுத்திய இடத்திலிருந்தே திரும்பவும்.';

  @override
  String get tourSettingsNavTitle => 'அமைப்புகள்';

  @override
  String get tourSettingsNavBody =>
      'தீம்கள், மொழிகள், வாசிப்பு குரல்கள் மற்றும் பல.';

  @override
  String get tourSearchTitle => 'தேடு';

  @override
  String get tourSearchBody => 'தலைப்பின் மூலம் ஒரு புத்தகத்தைக் கண்டறி.';

  @override
  String get tourLayoutTitle => 'கட்டம் அல்லது பட்டியல்';

  @override
  String get tourLayoutBody =>
      'கட்டம் மற்றும் பட்டியல் காட்சிகளுக்கிடையே மாற்று.';

  @override
  String get tourAddTitle => 'புத்தகம் சேர்';

  @override
  String get tourAddBody =>
      'படிக்கத் தொடங்க உங்கள் சாதனத்திலிருந்து ஒரு PDF ஐ இறக்குமதி செய்.';

  @override
  String get tourThemeTitle => 'தோற்றம்';

  @override
  String get tourThemeBody =>
      'பகல், இரவு இடையே மாற்று, அல்லது உங்கள் சிஸ்டத்தைப் பின்பற்று.';

  @override
  String get tourLanguageTitle => 'ஆப் மொழி';

  @override
  String get tourLanguageBody => 'ஆப் இடைமுகத்தை உங்கள் விருப்ப மொழியில் படி.';

  @override
  String get tourVoicesTitle => 'வாசிப்பு குரல்கள்';

  @override
  String get tourVoicesBody =>
      'வாசிப்புக்கான குரல்களைத் தேர்வுசெய்து மொழிகளைப் பதிவிறக்கு.';

  @override
  String get tourTintTitle => 'வசதி நிறம்';

  @override
  String get tourTintBody =>
      'புதிய புத்தகங்களுக்கான இயல்புநிலை காகித நிறத்தை அமை.';

  @override
  String get tourTapTitle => 'கட்டுப்பாடுகளைக் காட்டு';

  @override
  String get tourTapBody =>
      'வாசிப்பான் கட்டுப்பாடுகளைக் காட்ட அல்லது மறைக்க பக்கத்தின் நடுவைத் தட்டவும்.';

  @override
  String get tourScrubberTitle => 'ஒரு பக்கத்திற்குச் செல்';

  @override
  String get tourScrubberBody =>
      'முன்னோட்டம் காண மற்றும் எந்தப் பக்கத்திற்கும் செல்ல இழுக்கவும்.';

  @override
  String get tourReadAloudTitle => 'உரக்கப் படி';

  @override
  String get tourReadAloudBody => 'புத்தகத்தை உங்களுக்கு உரக்க வாசிக்கச் செய்.';

  @override
  String get tourReaderTintTitle => 'வசதி நிறம்';

  @override
  String get tourReaderTintBody => 'காகிதம், செபியா, இரவு நிறங்களை மாற்று.';

  @override
  String get tourBrightnessTitle => 'பிரகாசம்';

  @override
  String get tourBrightnessBody =>
      'புத்தகத்தை விட்டு வெளியேறாமல் திரை பிரகாசத்தை சரிசெய்.';

  @override
  String get tourBookmarkTitle => 'புத்தகக்குறி';

  @override
  String get tourBookmarkBody =>
      'உங்கள் இடத்தைச் சேமித்து பின்னர் மீண்டும் கண்டறி.';

  @override
  String get readScannedBooks => 'ஸ்கேன் செய்த புத்தகங்களைப் படிக்கவும்';

  @override
  String get readScannedBooksSub =>
      'தேர்ந்தெடுக்கக்கூடிய உரை இல்லாத பக்கங்களைப் படிக்க சாதன OCR ஐப் பயன்படுத்தவும்';
}
