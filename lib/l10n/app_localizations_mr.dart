// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appTitle => 'Comfy Reader';

  @override
  String get appTagline => 'खऱ्या पुस्तकासारखे वाचा.';

  @override
  String get navLibrary => 'ग्रंथालय';

  @override
  String get navReading => 'वाचन';

  @override
  String get navSettings => 'सेटिंग्ज';

  @override
  String get close => 'बंद करा';

  @override
  String get notNow => 'आता नको';

  @override
  String get continueLabel => 'सुरू ठेवा';

  @override
  String get open => 'उघडा';

  @override
  String get goBack => 'मागे जा';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Exit';

  @override
  String get quitAppTitle => 'Quit Comfy Reader?';

  @override
  String get quitAppMessage => 'Are you sure you want to close the app?';

  @override
  String get libraryTitle => 'ग्रंथालय';

  @override
  String get searchTooltip => 'शोधा';

  @override
  String get closeSearchTooltip => 'शोध बंद करा';

  @override
  String get searchHint => 'शीर्षके शोधा…';

  @override
  String get toggleLayoutTooltip => 'मांडणी बदला';

  @override
  String get dayTheme => 'दिवस थीम';

  @override
  String get nightTheme => 'रात्र थीम';

  @override
  String get sortRecent => 'क्रम: अलीकडील';

  @override
  String get sortName => 'क्रम: नाव';

  @override
  String get sortDateAdded => 'क्रम: जोडल्याची तारीख';

  @override
  String get noStorageAccess => 'स्टोरेज प्रवेश नाही — PDF जोडण्यासाठी + दाबा.';

  @override
  String get noNewBooks => 'नवीन पुस्तके सापडली नाहीत';

  @override
  String foundBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पुस्तके सापडली',
      one: '1 पुस्तक सापडले',
    );
    return '$_temp0';
  }

  @override
  String get emptyNoMatches => 'जुळणारे काही नाही';

  @override
  String get emptyTryDifferent => 'वेगळे शीर्षक वापरून पहा.';

  @override
  String get emptyNoBooks => 'अद्याप पुस्तके नाहीत';

  @override
  String get emptyNoBooksBody =>
      'PDF जोडण्यासाठी + दाबा, किंवा डिव्हाइस स्कॅन करण्यासाठी खाली ओढा.';

  @override
  String get continueReadingTitle => 'वाचन सुरू ठेवा';

  @override
  String get nothingInProgress => 'काहीही प्रगतीपथावर नाही';

  @override
  String get nothingInProgressBody =>
      'तुमच्या ग्रंथालयातून एखादे पुस्तक उघडा, ते इथे दिसेल जेणेकरून तुम्ही जिथे थांबला होता तिथून पुन्हा सुरू करू शकता.';

  @override
  String pageOfTotal(int current, int total) {
    return 'पृष्ठ $current / $total';
  }

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String get details => 'तपशील';

  @override
  String get removeFromLibrary => 'ग्रंथालयातून काढा';

  @override
  String get detailPages => 'पृष्ठे';

  @override
  String get detailSize => 'आकार';

  @override
  String get detailProgress => 'प्रगती';

  @override
  String get detailSource => 'स्रोत';

  @override
  String get sourceImported => 'आयात केलेले';

  @override
  String get sourceOnDevice => 'डिव्हाइसवर';

  @override
  String get addPdf => 'PDF जोडा';

  @override
  String addedBook(String title) {
    return '\"$title\" जोडले';
  }

  @override
  String get couldntImport => 'ती फाईल आयात करता आली नाही.';

  @override
  String get settingsTitle => 'सेटिंग्ज';

  @override
  String get appearance => 'स्वरूप';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeDay => 'दिवस';

  @override
  String get themeNight => 'रात्र';

  @override
  String get reading => 'वाचन';

  @override
  String get pageTurnSound => 'पृष्ठ उलटण्याचा आवाज';

  @override
  String get pageTurnSoundSub => 'प्रत्येक उलटताना हलका आवाज वाजवा';

  @override
  String get volume => 'आवाज';

  @override
  String get haptics => 'कंपन';

  @override
  String get hapticsSub => 'पृष्ठ उलटल्यावर सौम्य कंपन';

  @override
  String get keepScreenOn => 'स्क्रीन चालू ठेवा';

  @override
  String get keepScreenOnSub => 'वाचताना स्क्रीन बंद होण्यापासून रोखा';

  @override
  String get readAloudSpeed => 'वाचनाचा वेग';

  @override
  String get readAloudVoices => 'वाचनाचे आवाज';

  @override
  String get readAloudVoicesSub => 'भाषा, आवाज गुणवत्ता आणि डाउनलोड';

  @override
  String get defaultPageTint => 'मूलभूत पृष्ठ रंगछटा';

  @override
  String get tintPaper => 'कागद';

  @override
  String get tintSepia => 'सेपिया';

  @override
  String get tintNight => 'रात्र';

  @override
  String get defaultPageTintNote =>
      'नवीन पुस्तके याच रंगछटेने उघडतात. वाचकातून प्रत्येक पुस्तकासाठी तुम्ही ती बदलू शकता.';

  @override
  String get librarySection => 'ग्रंथालय';

  @override
  String get rescanTitle => 'PDF साठी डिव्हाइस पुन्हा स्कॅन करा';

  @override
  String get rescanSub => 'नवीन फाईलींसाठी डाउनलोड, दस्तऐवज आणि पुस्तके शोधा';

  @override
  String get about => 'विषयी';

  @override
  String get openSourceLicenses => 'मुक्त-स्रोत परवाने';

  @override
  String appVersion(String version) {
    return 'v$version';
  }

  @override
  String get appLanguage => 'अॅप भाषा';

  @override
  String get appLanguageSub => 'अॅपच्या इंटरफेससाठी भाषा निवडा';

  @override
  String get chooseLanguage => 'भाषा निवडा';

  @override
  String get takeTourAgain => 'फेरफटका पुन्हा पहा';

  @override
  String get takeTourAgainSub => 'वैशिष्ट्यांचे ठळक मुद्दे पुन्हा पहा';

  @override
  String get backToLibrary => 'ग्रंथालयाकडे परत';

  @override
  String get bookmarksTooltip => 'खुणा';

  @override
  String get bookmarkThisPage => 'हे पृष्ठ खुणा करा';

  @override
  String get previousPage => 'मागील पृष्ठ';

  @override
  String get nextPage => 'पुढील पृष्ठ';

  @override
  String get screenBrightness => 'स्क्रीन उजळपणा';

  @override
  String get pauseReading => 'वाचन थांबवा';

  @override
  String get resumeReading => 'वाचन सुरू ठेवा';

  @override
  String get readAloud => 'मोठ्याने वाचा';

  @override
  String get pause => 'थांबवा';

  @override
  String get play => 'चालवा';

  @override
  String get stopReading => 'वाचन बंद करा';

  @override
  String get noBookmarks =>
      'अद्याप खुणा नाहीत. खूण जोडण्यासाठी खूण चिन्ह दाबा.';

  @override
  String pageNumber(int page) {
    return 'पृष्ठ $page';
  }

  @override
  String get bookNotFound => 'पुस्तक सापडले नाही';

  @override
  String get cantOpenBook => 'हे पुस्तक उघडता येत नाही';

  @override
  String get somethingWentWrong => 'काहीतरी चूक झाली.';

  @override
  String get findPdfsTitle => 'तुमच्या डिव्हाइसवर PDF शोधा';

  @override
  String get storageAccessOff => 'स्टोरेज प्रवेश बंद आहे';

  @override
  String get storageAccessOffBody =>
      'Comfy Reader ला तुमच्या डिव्हाइसवरील PDF शोधू देण्यासाठी सेटिंग्ज उघडा — किंवा ती स्वतः जोडण्यासाठी + दाबा.';

  @override
  String get openSettingsLabel => 'सेटिंग्ज उघडा';

  @override
  String get tourLibraryTitle => 'तुमची पुस्तके';

  @override
  String get tourLibraryBody =>
      'तुमचे सर्व आयात केलेले आणि स्कॅन केलेले PDF येथे राहतात.';

  @override
  String get tourReadingTitle => 'वाचन सुरू ठेवा';

  @override
  String get tourReadingBody =>
      'सुरू केलेल्या पुस्तकांत जिथे थांबलात तिथून पुन्हा सुरू करा.';

  @override
  String get tourSettingsNavTitle => 'सेटिंग्ज';

  @override
  String get tourSettingsNavBody => 'थीम, भाषा, वाचनाचे आवाज आणि बरेच काही.';

  @override
  String get tourSearchTitle => 'शोधा';

  @override
  String get tourSearchBody => 'शीर्षकाने पुस्तक शोधा.';

  @override
  String get tourLayoutTitle => 'ग्रिड किंवा यादी';

  @override
  String get tourLayoutBody => 'ग्रिड आणि यादी दृश्यांमध्ये बदला.';

  @override
  String get tourAddTitle => 'पुस्तक जोडा';

  @override
  String get tourAddBody =>
      'वाचन सुरू करण्यासाठी तुमच्या डिव्हाइसवरून PDF आयात करा.';

  @override
  String get tourThemeTitle => 'स्वरूप';

  @override
  String get tourThemeBody => 'दिवस, रात्र यांमध्ये बदला किंवा सिस्टम अनुसरा.';

  @override
  String get tourLanguageTitle => 'अॅप भाषा';

  @override
  String get tourLanguageBody => 'अॅपचा इंटरफेस तुमच्या आवडत्या भाषेत वाचा.';

  @override
  String get tourVoicesTitle => 'वाचनाचे आवाज';

  @override
  String get tourVoicesBody => 'वाचनासाठी आवाज निवडा आणि भाषा डाउनलोड करा.';

  @override
  String get tourTintTitle => 'आरामदायी रंगछटा';

  @override
  String get tourTintBody => 'नवीन पुस्तकांसाठी मूलभूत कागद रंगछटा सेट करा.';

  @override
  String get tourTapTitle => 'नियंत्रणे दाखवा';

  @override
  String get tourTapBody =>
      'वाचक नियंत्रणे दाखवण्यासाठी किंवा लपवण्यासाठी पृष्ठाच्या मध्यभागी दाबा.';

  @override
  String get tourScrubberTitle => 'पृष्ठावर जा';

  @override
  String get tourScrubberBody =>
      'कोणत्याही पृष्ठाचे पूर्वावलोकन करण्यासाठी आणि तिथे जाण्यासाठी ओढा.';

  @override
  String get tourReadAloudTitle => 'मोठ्याने वाचा';

  @override
  String get tourReadAloudBody => 'पुस्तक तुम्हाला मोठ्याने वाचून दाखवले जाईल.';

  @override
  String get tourReaderTintTitle => 'आरामदायी रंगछटा';

  @override
  String get tourReaderTintBody => 'कागद, सेपिया आणि रात्र रंगछटा बदला.';

  @override
  String get tourBrightnessTitle => 'उजळपणा';

  @override
  String get tourBrightnessBody =>
      'पुस्तक न सोडता स्क्रीन उजळपणा समायोजित करा.';

  @override
  String get tourBookmarkTitle => 'खूण';

  @override
  String get tourBookmarkBody => 'तुमची जागा जतन करा आणि नंतर पुन्हा शोधा.';

  @override
  String get tourSwipeTitle => 'पान उलटणे';

  @override
  String get tourSwipeShortBody => 'छोटा स्वाइप मागे येतो, पान उलटत नाही.';

  @override
  String get tourSwipeLongBody => 'मोठा स्वाइप पान उलटवतो.';

  @override
  String get tourSwipeFastBody => 'जलद स्वाइपनेही पान उलटते.';

  @override
  String get readScannedBooks => 'स्कॅन केलेली पुस्तके वाचा';

  @override
  String get readScannedBooksSub =>
      'निवडण्यायोग्य मजकूर नसलेली पृष्ठे वाचण्यासाठी डिव्हाइस OCR वापरा';
}
