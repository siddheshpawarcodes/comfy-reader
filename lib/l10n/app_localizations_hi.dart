// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Comfy Reader';

  @override
  String get appTagline => 'पढ़ें जैसे यह असली किताब हो।';

  @override
  String get navLibrary => 'लाइब्रेरी';

  @override
  String get navReading => 'पढ़ना';

  @override
  String get navSettings => 'सेटिंग्स';

  @override
  String get close => 'बंद करें';

  @override
  String get notNow => 'अभी नहीं';

  @override
  String get continueLabel => 'जारी रखें';

  @override
  String get open => 'खोलें';

  @override
  String get goBack => 'वापस जाएँ';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Exit';

  @override
  String get quitAppTitle => 'Quit Comfy Reader?';

  @override
  String get quitAppMessage => 'Are you sure you want to close the app?';

  @override
  String get libraryTitle => 'लाइब्रेरी';

  @override
  String get searchTooltip => 'खोजें';

  @override
  String get closeSearchTooltip => 'खोज बंद करें';

  @override
  String get searchHint => 'शीर्षक खोजें…';

  @override
  String get toggleLayoutTooltip => 'लेआउट बदलें';

  @override
  String get dayTheme => 'दिन थीम';

  @override
  String get nightTheme => 'रात थीम';

  @override
  String get sortRecent => 'क्रम: हाल का';

  @override
  String get sortName => 'क्रम: नाम';

  @override
  String get sortDateAdded => 'क्रम: जोड़ने की तारीख';

  @override
  String get noStorageAccess =>
      'स्टोरेज एक्सेस नहीं — PDF जोड़ने के लिए + दबाएँ।';

  @override
  String get noNewBooks => 'कोई नई किताब नहीं मिली';

  @override
  String foundBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count किताबें मिलीं',
      one: '1 किताब मिली',
    );
    return '$_temp0';
  }

  @override
  String get emptyNoMatches => 'कोई मिलान नहीं';

  @override
  String get emptyTryDifferent => 'कोई दूसरा शीर्षक आज़माएँ।';

  @override
  String get emptyNoBooks => 'अभी कोई किताब नहीं';

  @override
  String get emptyNoBooksBody =>
      'PDF जोड़ने के लिए + दबाएँ, या डिवाइस स्कैन करने के लिए नीचे खींचें।';

  @override
  String get continueReadingTitle => 'पढ़ना जारी रखें';

  @override
  String get nothingInProgress => 'कुछ भी चालू नहीं';

  @override
  String get nothingInProgressBody =>
      'अपनी लाइब्रेरी से कोई किताब खोलें और वह यहाँ दिखेगी ताकि आप वहीं से आगे पढ़ सकें जहाँ छोड़ा था।';

  @override
  String pageOfTotal(int current, int total) {
    return 'पृष्ठ $current / $total';
  }

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String get details => 'विवरण';

  @override
  String get removeFromLibrary => 'लाइब्रेरी से हटाएँ';

  @override
  String get detailPages => 'पृष्ठ';

  @override
  String get detailSize => 'आकार';

  @override
  String get detailProgress => 'प्रगति';

  @override
  String get detailSource => 'स्रोत';

  @override
  String get sourceImported => 'आयातित';

  @override
  String get sourceOnDevice => 'डिवाइस पर';

  @override
  String get addPdf => 'PDF जोड़ें';

  @override
  String addedBook(String title) {
    return '\"$title\" जोड़ा गया';
  }

  @override
  String get couldntImport => 'वह फ़ाइल आयात नहीं हो सकी।';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get appearance => 'दिखावट';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeDay => 'दिन';

  @override
  String get themeNight => 'रात';

  @override
  String get reading => 'पढ़ना';

  @override
  String get pageTurnSound => 'पृष्ठ पलटने की ध्वनि';

  @override
  String get pageTurnSoundSub => 'हर पलटने पर हल्की ध्वनि बजाएँ';

  @override
  String get volume => 'वॉल्यूम';

  @override
  String get haptics => 'हैप्टिक्स';

  @override
  String get hapticsSub => 'पृष्ठ पलटने पर हल्का कंपन';

  @override
  String get keepScreenOn => 'स्क्रीन चालू रखें';

  @override
  String get keepScreenOnSub => 'पढ़ते समय स्क्रीन को बंद होने से रोकें';

  @override
  String get readAloudSpeed => 'ज़ोर से पढ़ने की गति';

  @override
  String get readAloudVoices => 'ज़ोर से पढ़ने की आवाज़ें';

  @override
  String get readAloudVoicesSub => 'भाषाएँ, आवाज़ की गुणवत्ता और डाउनलोड';

  @override
  String get defaultPageTint => 'डिफ़ॉल्ट पृष्ठ रंगत';

  @override
  String get tintPaper => 'कागज़';

  @override
  String get tintSepia => 'सेपिया';

  @override
  String get tintNight => 'रात';

  @override
  String get defaultPageTintNote =>
      'नई किताबें इसी रंगत के साथ खुलती हैं। आप इसे रीडर से हर किताब के लिए बदल सकते हैं।';

  @override
  String get librarySection => 'लाइब्रेरी';

  @override
  String get rescanTitle => 'PDF के लिए डिवाइस फिर से स्कैन करें';

  @override
  String get rescanSub =>
      'नई फ़ाइलों के लिए Downloads, Documents और Books खोजें';

  @override
  String get about => 'परिचय';

  @override
  String get openSourceLicenses => 'ओपन-सोर्स लाइसेंस';

  @override
  String appVersion(String version) {
    return 'v$version';
  }

  @override
  String get appLanguage => 'ऐप की भाषा';

  @override
  String get appLanguageSub => 'ऐप के इंटरफ़ेस की भाषा चुनें';

  @override
  String get chooseLanguage => 'भाषा चुनें';

  @override
  String get takeTourAgain => 'टूर फिर से लें';

  @override
  String get takeTourAgainSub => 'फ़ीचर की झलकियाँ दोबारा देखें';

  @override
  String get backToLibrary => 'लाइब्रेरी पर वापस';

  @override
  String get bookmarksTooltip => 'बुकमार्क';

  @override
  String get bookmarkThisPage => 'इस पृष्ठ को बुकमार्क करें';

  @override
  String get previousPage => 'पिछला पृष्ठ';

  @override
  String get nextPage => 'अगला पृष्ठ';

  @override
  String get screenBrightness => 'स्क्रीन की चमक';

  @override
  String get pauseReading => 'पढ़ना रोकें';

  @override
  String get resumeReading => 'पढ़ना जारी रखें';

  @override
  String get readAloud => 'ज़ोर से पढ़ें';

  @override
  String get pause => 'रोकें';

  @override
  String get play => 'चलाएँ';

  @override
  String get stopReading => 'पढ़ना बंद करें';

  @override
  String get noBookmarks =>
      'अभी कोई बुकमार्क नहीं। जोड़ने के लिए बुकमार्क आइकन दबाएँ।';

  @override
  String pageNumber(int page) {
    return 'पृष्ठ $page';
  }

  @override
  String get bookNotFound => 'किताब नहीं मिली';

  @override
  String get cantOpenBook => 'यह किताब नहीं खुल सकी';

  @override
  String get somethingWentWrong => 'कुछ गलत हो गया।';

  @override
  String get findPdfsTitle => 'अपने डिवाइस पर PDF खोजें';

  @override
  String get storageAccessOff => 'स्टोरेज एक्सेस बंद है';

  @override
  String get storageAccessOffBody =>
      'Comfy Reader को आपके डिवाइस पर PDF खोजने देने के लिए सेटिंग्स खोलें — या उन्हें मैन्युअल रूप से जोड़ने के लिए + दबाएँ।';

  @override
  String get openSettingsLabel => 'सेटिंग्स खोलें';

  @override
  String get tourLibraryTitle => 'आपकी किताबें';

  @override
  String get tourLibraryBody =>
      'आपके सभी आयातित और स्कैन किए गए PDF यहाँ रहते हैं।';

  @override
  String get tourReadingTitle => 'पढ़ना जारी रखें';

  @override
  String get tourReadingBody =>
      'शुरू की गई किताबों पर वहीं लौटें जहाँ छोड़ा था।';

  @override
  String get tourSettingsNavTitle => 'सेटिंग्स';

  @override
  String get tourSettingsNavBody =>
      'थीम, भाषाएँ, ज़ोर से पढ़ने की आवाज़ें और बहुत कुछ।';

  @override
  String get tourSearchTitle => 'खोज';

  @override
  String get tourSearchBody => 'शीर्षक से किताब खोजें।';

  @override
  String get tourLayoutTitle => 'ग्रिड या सूची';

  @override
  String get tourLayoutBody => 'ग्रिड और सूची दृश्य के बीच स्विच करें।';

  @override
  String get tourAddTitle => 'किताब जोड़ें';

  @override
  String get tourAddBody =>
      'पढ़ना शुरू करने के लिए अपने डिवाइस से PDF आयात करें।';

  @override
  String get tourThemeTitle => 'दिखावट';

  @override
  String get tourThemeBody => 'दिन, रात के बीच चुनें या सिस्टम का अनुसरण करें।';

  @override
  String get tourLanguageTitle => 'ऐप की भाषा';

  @override
  String get tourLanguageBody => 'ऐप का इंटरफ़ेस अपनी पसंदीदा भाषा में पढ़ें।';

  @override
  String get tourVoicesTitle => 'ज़ोर से पढ़ने की आवाज़ें';

  @override
  String get tourVoicesBody =>
      'ज़ोर से पढ़ने के लिए आवाज़ें चुनें और भाषाएँ डाउनलोड करें।';

  @override
  String get tourTintTitle => 'आरामदायक रंगत';

  @override
  String get tourTintBody => 'नई किताबों के लिए डिफ़ॉल्ट कागज़ रंगत सेट करें।';

  @override
  String get tourTapTitle => 'नियंत्रण दिखाएँ';

  @override
  String get tourTapBody =>
      'रीडर नियंत्रण दिखाने या छिपाने के लिए पृष्ठ के बीच में दबाएँ।';

  @override
  String get tourScrubberTitle => 'किसी पृष्ठ पर जाएँ';

  @override
  String get tourScrubberBody =>
      'किसी भी पृष्ठ का पूर्वावलोकन करने और वहाँ जाने के लिए खींचें।';

  @override
  String get tourReadAloudTitle => 'ज़ोर से पढ़ें';

  @override
  String get tourReadAloudBody => 'किताब को अपने लिए ज़ोर से पढ़वाएँ।';

  @override
  String get tourReaderTintTitle => 'आरामदायक रंगत';

  @override
  String get tourReaderTintBody => 'कागज़, सेपिया और रात की रंगत बदलें।';

  @override
  String get tourBrightnessTitle => 'चमक';

  @override
  String get tourBrightnessBody =>
      'किताब छोड़े बिना स्क्रीन की चमक समायोजित करें।';

  @override
  String get tourBookmarkTitle => 'बुकमार्क';

  @override
  String get tourBookmarkBody => 'अपनी जगह सहेजें और बाद में फिर पाएँ।';

  @override
  String get readScannedBooks => 'स्कैन की गई किताबें पढ़ें';

  @override
  String get readScannedBooksSub =>
      'बिना चयन-योग्य टेक्स्ट वाले पृष्ठ पढ़ने के लिए डिवाइस OCR उपयोग करें';
}
