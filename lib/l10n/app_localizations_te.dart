// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'Comfy Reader';

  @override
  String get appTagline => 'నిజమైన పుస్తకంలా చదవండి.';

  @override
  String get navLibrary => 'లైబ్రరీ';

  @override
  String get navReading => 'చదవడం';

  @override
  String get navSettings => 'సెట్టింగ్‌లు';

  @override
  String get close => 'మూసివేయి';

  @override
  String get notNow => 'ఇప్పుడు కాదు';

  @override
  String get continueLabel => 'కొనసాగించు';

  @override
  String get open => 'తెరువు';

  @override
  String get goBack => 'వెనక్కి';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Exit';

  @override
  String get quitAppTitle => 'Quit Comfy Reader?';

  @override
  String get quitAppMessage => 'Are you sure you want to close the app?';

  @override
  String get libraryTitle => 'లైబ్రరీ';

  @override
  String get searchTooltip => 'శోధించు';

  @override
  String get closeSearchTooltip => 'శోధనను మూసివేయి';

  @override
  String get searchHint => 'శీర్షికలను శోధించండి…';

  @override
  String get toggleLayoutTooltip => 'లేఅవుట్ మార్చు';

  @override
  String get dayTheme => 'పగటి థీమ్';

  @override
  String get nightTheme => 'రాత్రి థీమ్';

  @override
  String get sortRecent => 'క్రమం: ఇటీవలి';

  @override
  String get sortName => 'క్రమం: పేరు';

  @override
  String get sortDateAdded => 'క్రమం: జోడించిన తేదీ';

  @override
  String get noStorageAccess =>
      'నిల్వ యాక్సెస్ లేదు — PDFలు జోడించడానికి + నొక్కండి.';

  @override
  String get noNewBooks => 'కొత్త పుస్తకాలు కనబడలేదు';

  @override
  String foundBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count పుస్తకాలు దొరికాయి',
      one: '1 పుస్తకం దొరికింది',
    );
    return '$_temp0';
  }

  @override
  String get emptyNoMatches => 'సరిపోలికలు లేవు';

  @override
  String get emptyTryDifferent => 'వేరే శీర్షికను ప్రయత్నించండి.';

  @override
  String get emptyNoBooks => 'ఇంకా పుస్తకాలు లేవు';

  @override
  String get emptyNoBooksBody =>
      'PDF జోడించడానికి + నొక్కండి, లేదా పరికరాన్ని స్కాన్ చేయడానికి కిందికి లాగండి.';

  @override
  String get continueReadingTitle => 'చదవడం కొనసాగించు';

  @override
  String get nothingInProgress => 'ప్రగతిలో ఏమీ లేదు';

  @override
  String get nothingInProgressBody =>
      'మీ లైబ్రరీ నుండి ఒక పుస్తకాన్ని తెరవండి, అది ఇక్కడ కనిపిస్తుంది, దీంతో మీరు ఆపిన చోటు నుండే కొనసాగించవచ్చు.';

  @override
  String pageOfTotal(int current, int total) {
    return 'పేజీ $current / $total';
  }

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String get details => 'వివరాలు';

  @override
  String get removeFromLibrary => 'లైబ్రరీ నుండి తీసివేయి';

  @override
  String get detailPages => 'పేజీలు';

  @override
  String get detailSize => 'పరిమాణం';

  @override
  String get detailProgress => 'ప్రగతి';

  @override
  String get detailSource => 'మూలం';

  @override
  String get sourceImported => 'దిగుమతి చేయబడింది';

  @override
  String get sourceOnDevice => 'పరికరంలో';

  @override
  String get addPdf => 'PDF జోడించు';

  @override
  String addedBook(String title) {
    return '\"$title\" జోడించబడింది';
  }

  @override
  String get couldntImport => 'ఆ ఫైల్‌ను దిగుమతి చేయలేకపోయాం.';

  @override
  String get settingsTitle => 'సెట్టింగ్‌లు';

  @override
  String get appearance => 'రూపం';

  @override
  String get themeSystem => 'సిస్టమ్';

  @override
  String get themeDay => 'పగలు';

  @override
  String get themeNight => 'రాత్రి';

  @override
  String get reading => 'చదవడం';

  @override
  String get pageTurnSound => 'పేజీ తిప్పే శబ్దం';

  @override
  String get pageTurnSoundSub => 'ప్రతి తిప్పుకు మృదువైన శబ్దం వినిపించు';

  @override
  String get volume => 'వాల్యూమ్';

  @override
  String get haptics => 'హాప్టిక్స్';

  @override
  String get hapticsSub => 'పేజీ తిప్పడం పూర్తయినప్పుడు మృదువైన కంపనం';

  @override
  String get keepScreenOn => 'స్క్రీన్ ఆన్‌లో ఉంచు';

  @override
  String get keepScreenOnSub => 'చదువుతున్నప్పుడు స్క్రీన్ నిద్రపోకుండా చూడు';

  @override
  String get readAloudSpeed => 'చదివే వేగం';

  @override
  String get readAloudVoices => 'చదివే స్వరాలు';

  @override
  String get readAloudVoicesSub => 'భాషలు, స్వర నాణ్యత, డౌన్‌లోడ్‌లు';

  @override
  String get defaultPageTint => 'డిఫాల్ట్ పేజీ రంగు';

  @override
  String get tintPaper => 'కాగితం';

  @override
  String get tintSepia => 'సెపియా';

  @override
  String get tintNight => 'రాత్రి';

  @override
  String get defaultPageTintNote =>
      'కొత్త పుస్తకాలు ఈ రంగుతో తెరుచుకుంటాయి. రీడర్‌లో ప్రతి పుస్తకానికి దీన్ని మార్చవచ్చు.';

  @override
  String get librarySection => 'లైబ్రరీ';

  @override
  String get rescanTitle => 'PDFల కోసం పరికరాన్ని మళ్లీ స్కాన్ చేయి';

  @override
  String get rescanSub =>
      'కొత్త ఫైళ్ల కోసం డౌన్‌లోడ్‌లు, పత్రాలు, పుస్తకాలను శోధించు';

  @override
  String get about => 'గురించి';

  @override
  String get openSourceLicenses => 'ఓపెన్-సోర్స్ లైసెన్స్‌లు';

  @override
  String appVersion(String version) {
    return 'v$version';
  }

  @override
  String get appLanguage => 'యాప్ భాష';

  @override
  String get appLanguageSub => 'యాప్ ఇంటర్‌ఫేస్ కోసం భాషను ఎంచుకోండి';

  @override
  String get chooseLanguage => 'భాషను ఎంచుకోండి';

  @override
  String get takeTourAgain => 'మళ్లీ టూర్ చూడండి';

  @override
  String get takeTourAgainSub => 'ఫీచర్ హైలైట్‌లను మళ్లీ చూడండి';

  @override
  String get backToLibrary => 'లైబ్రరీకి తిరిగి';

  @override
  String get bookmarksTooltip => 'బుక్‌మార్క్‌లు';

  @override
  String get bookmarkThisPage => 'ఈ పేజీని బుక్‌మార్క్ చేయి';

  @override
  String get previousPage => 'మునుపటి పేజీ';

  @override
  String get nextPage => 'తదుపరి పేజీ';

  @override
  String get screenBrightness => 'స్క్రీన్ ప్రకాశం';

  @override
  String get pauseReading => 'చదవడం పాజ్ చేయి';

  @override
  String get resumeReading => 'చదవడం కొనసాగించు';

  @override
  String get readAloud => 'చదివి వినిపించు';

  @override
  String get pause => 'పాజ్';

  @override
  String get play => 'ప్లే';

  @override
  String get stopReading => 'చదవడం ఆపు';

  @override
  String get noBookmarks =>
      'ఇంకా బుక్‌మార్క్‌లు లేవు. ఒకటి జోడించడానికి బుక్‌మార్క్ ఐకాన్‌ను నొక్కండి.';

  @override
  String pageNumber(int page) {
    return 'పేజీ $page';
  }

  @override
  String get bookNotFound => 'పుస్తకం కనబడలేదు';

  @override
  String get cantOpenBook => 'ఈ పుస్తకాన్ని తెరవలేము';

  @override
  String get somethingWentWrong => 'ఏదో తప్పు జరిగింది.';

  @override
  String get findPdfsTitle => 'మీ పరికరంలో PDFలను కనుగొనండి';

  @override
  String get storageAccessOff => 'నిల్వ యాక్సెస్ ఆఫ్‌లో ఉంది';

  @override
  String get storageAccessOffBody =>
      'మీ పరికరంలో PDFలను Comfy Reader కనుగొనేందుకు సెట్టింగ్‌లను తెరవండి — లేదా వాటిని మాన్యువల్‌గా జోడించడానికి + నొక్కండి.';

  @override
  String get openSettingsLabel => 'సెట్టింగ్‌లు తెరువు';

  @override
  String get tourLibraryTitle => 'మీ పుస్తకాలు';

  @override
  String get tourLibraryBody =>
      'మీరు దిగుమతి చేసిన, స్కాన్ చేసిన అన్ని PDFలు ఇక్కడ ఉంటాయి.';

  @override
  String get tourReadingTitle => 'చదవడం కొనసాగించు';

  @override
  String get tourReadingBody =>
      'మీరు మొదలుపెట్టిన పుస్తకాల్లోకి, ఆపిన చోటు నుండే తిరిగి వెళ్లండి.';

  @override
  String get tourSettingsNavTitle => 'సెట్టింగ్‌లు';

  @override
  String get tourSettingsNavBody =>
      'థీమ్‌లు, భాషలు, చదివే స్వరాలు మరియు మరిన్ని.';

  @override
  String get tourSearchTitle => 'శోధన';

  @override
  String get tourSearchBody => 'శీర్షిక ద్వారా పుస్తకాన్ని కనుగొనండి.';

  @override
  String get tourLayoutTitle => 'గ్రిడ్ లేదా జాబితా';

  @override
  String get tourLayoutBody => 'గ్రిడ్ మరియు జాబితా వీక్షణల మధ్య మారండి.';

  @override
  String get tourAddTitle => 'పుస్తకం జోడించు';

  @override
  String get tourAddBody =>
      'చదవడం మొదలుపెట్టడానికి మీ పరికరం నుండి PDF దిగుమతి చేయండి.';

  @override
  String get tourThemeTitle => 'రూపం';

  @override
  String get tourThemeBody =>
      'పగలు, రాత్రి మధ్య మారండి లేదా సిస్టమ్‌ను అనుసరించండి.';

  @override
  String get tourLanguageTitle => 'యాప్ భాష';

  @override
  String get tourLanguageBody => 'యాప్ ఇంటర్‌ఫేస్‌ను మీకు నచ్చిన భాషలో చదవండి.';

  @override
  String get tourVoicesTitle => 'చదివే స్వరాలు';

  @override
  String get tourVoicesBody =>
      'చదవడం కోసం స్వరాలను ఎంచుకుని భాషలను డౌన్‌లోడ్ చేయండి.';

  @override
  String get tourTintTitle => 'కంఫర్ట్ రంగు';

  @override
  String get tourTintBody =>
      'కొత్త పుస్తకాలకు డిఫాల్ట్ కాగితం రంగును సెట్ చేయండి.';

  @override
  String get tourTapTitle => 'నియంత్రణలను చూపించు';

  @override
  String get tourTapBody =>
      'రీడర్ నియంత్రణలను చూపించడానికి లేదా దాచడానికి పేజీ మధ్యలో నొక్కండి.';

  @override
  String get tourScrubberTitle => 'ఒక పేజీకి వెళ్లు';

  @override
  String get tourScrubberBody =>
      'ఏ పేజీనైనా ప్రివ్యూ చేసి దానికి వెళ్లడానికి లాగండి.';

  @override
  String get tourReadAloudTitle => 'చదివి వినిపించు';

  @override
  String get tourReadAloudBody =>
      'పుస్తకాన్ని మీకు పెద్దగా చదివి వినిపించుకోండి.';

  @override
  String get tourReaderTintTitle => 'కంఫర్ట్ రంగు';

  @override
  String get tourReaderTintBody => 'కాగితం, సెపియా, రాత్రి రంగుల మధ్య మారండి.';

  @override
  String get tourBrightnessTitle => 'ప్రకాశం';

  @override
  String get tourBrightnessBody =>
      'పుస్తకాన్ని వదలకుండా స్క్రీన్ ప్రకాశాన్ని సర్దుబాటు చేయండి.';

  @override
  String get tourBookmarkTitle => 'బుక్‌మార్క్';

  @override
  String get tourBookmarkBody =>
      'మీ స్థానాన్ని సేవ్ చేసి తర్వాత మళ్లీ కనుగొనండి.';

  @override
  String get readScannedBooks => 'స్కాన్ చేసిన పుస్తకాలను చదవండి';

  @override
  String get readScannedBooksSub =>
      'ఎంపిక చేయదగిన టెక్స్ట్ లేని పేజీలను చదవడానికి పరికర OCR ఉపయోగించండి';
}
