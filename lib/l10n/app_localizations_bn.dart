// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'Comfy Reader';

  @override
  String get appTagline => 'সত্যিকারের বইয়ের মতো পড়ুন।';

  @override
  String get navLibrary => 'লাইব্রেরি';

  @override
  String get navReading => 'পড়ছি';

  @override
  String get navSettings => 'সেটিংস';

  @override
  String get close => 'বন্ধ করুন';

  @override
  String get notNow => 'এখন নয়';

  @override
  String get continueLabel => 'চালিয়ে যান';

  @override
  String get open => 'খুলুন';

  @override
  String get goBack => 'ফিরে যান';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Exit';

  @override
  String get quitAppTitle => 'Quit Comfy Reader?';

  @override
  String get quitAppMessage => 'Are you sure you want to close the app?';

  @override
  String get libraryTitle => 'লাইব্রেরি';

  @override
  String get searchTooltip => 'খুঁজুন';

  @override
  String get closeSearchTooltip => 'অনুসন্ধান বন্ধ করুন';

  @override
  String get searchHint => 'শিরোনাম খুঁজুন…';

  @override
  String get toggleLayoutTooltip => 'লেআউট পরিবর্তন';

  @override
  String get dayTheme => 'দিনের থিম';

  @override
  String get nightTheme => 'রাতের থিম';

  @override
  String get sortRecent => 'সাজান: সাম্প্রতিক';

  @override
  String get sortName => 'সাজান: নাম';

  @override
  String get sortDateAdded => 'সাজান: যোগের তারিখ';

  @override
  String get noStorageAccess => 'স্টোরেজে প্রবেশ নেই — PDF যোগ করতে + চাপুন।';

  @override
  String get noNewBooks => 'কোনো নতুন বই পাওয়া যায়নি';

  @override
  String foundBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বই পাওয়া গেছে',
      one: '১টি বই পাওয়া গেছে',
    );
    return '$_temp0';
  }

  @override
  String get emptyNoMatches => 'কোনো মিল নেই';

  @override
  String get emptyTryDifferent => 'অন্য শিরোনাম চেষ্টা করুন।';

  @override
  String get emptyNoBooks => 'এখনও কোনো বই নেই';

  @override
  String get emptyNoBooksBody =>
      'PDF যোগ করতে + চাপুন, বা ডিভাইস স্ক্যান করতে নিচে টানুন।';

  @override
  String get continueReadingTitle => 'পড়া চালিয়ে যান';

  @override
  String get nothingInProgress => 'কিছু চলমান নেই';

  @override
  String get nothingInProgressBody =>
      'লাইব্রেরি থেকে একটি বই খুলুন, তারপর তা এখানে দেখাবে যাতে আপনি যেখানে থেমেছিলেন সেখান থেকে শুরু করতে পারেন।';

  @override
  String pageOfTotal(int current, int total) {
    return 'পৃষ্ঠা $current / $total';
  }

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String get details => 'বিস্তারিত';

  @override
  String get removeFromLibrary => 'লাইব্রেরি থেকে সরান';

  @override
  String get detailPages => 'পৃষ্ঠা';

  @override
  String get detailSize => 'আকার';

  @override
  String get detailProgress => 'অগ্রগতি';

  @override
  String get detailSource => 'উৎস';

  @override
  String get sourceImported => 'আমদানিকৃত';

  @override
  String get sourceOnDevice => 'ডিভাইসে';

  @override
  String get addPdf => 'PDF যোগ করুন';

  @override
  String addedBook(String title) {
    return '\"$title\" যোগ করা হয়েছে';
  }

  @override
  String get couldntImport => 'ফাইলটি আমদানি করা যায়নি।';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get appearance => 'অবয়ব';

  @override
  String get themeSystem => 'সিস্টেম';

  @override
  String get themeDay => 'দিন';

  @override
  String get themeNight => 'রাত';

  @override
  String get reading => 'পড়া';

  @override
  String get pageTurnSound => 'পৃষ্ঠা ওল্টানোর শব্দ';

  @override
  String get pageTurnSoundSub => 'প্রতিবার ওল্টানোয় মৃদু শব্দ বাজান';

  @override
  String get volume => 'ভলিউম';

  @override
  String get haptics => 'কম্পন';

  @override
  String get hapticsSub => 'পৃষ্ঠা ওল্টানো শেষে মৃদু কম্পন';

  @override
  String get keepScreenOn => 'স্ক্রিন চালু রাখুন';

  @override
  String get keepScreenOnSub => 'পড়ার সময় স্ক্রিন ঘুমাতে দেবে না';

  @override
  String get readAloudSpeed => 'পড়ে শোনানোর গতি';

  @override
  String get readAloudVoices => 'পড়ে শোনানোর কণ্ঠ';

  @override
  String get readAloudVoicesSub => 'ভাষা, কণ্ঠের মান ও ডাউনলোড';

  @override
  String get defaultPageTint => 'ডিফল্ট পৃষ্ঠার রঙ';

  @override
  String get tintPaper => 'কাগজ';

  @override
  String get tintSepia => 'সেপিয়া';

  @override
  String get tintNight => 'রাত';

  @override
  String get defaultPageTintNote =>
      'নতুন বই এই রঙে খুলবে। রিডার থেকে প্রতিটি বইয়ের জন্য তা বদলাতে পারবেন।';

  @override
  String get librarySection => 'লাইব্রেরি';

  @override
  String get rescanTitle => 'PDF-এর জন্য ডিভাইস পুনরায় স্ক্যান করুন';

  @override
  String get rescanSub =>
      'নতুন ফাইলের জন্য Downloads, Documents ও Books খুঁজুন';

  @override
  String get about => 'সম্পর্কে';

  @override
  String get openSourceLicenses => 'ওপেন-সোর্স লাইসেন্স';

  @override
  String appVersion(String version) {
    return 'v$version';
  }

  @override
  String get appLanguage => 'অ্যাপের ভাষা';

  @override
  String get appLanguageSub => 'অ্যাপের ইন্টারফেসের ভাষা বেছে নিন';

  @override
  String get chooseLanguage => 'ভাষা বেছে নিন';

  @override
  String get takeTourAgain => 'আবার ট্যুর নিন';

  @override
  String get takeTourAgainSub => 'ফিচারের ঝলক আবার দেখুন';

  @override
  String get backToLibrary => 'লাইব্রেরিতে ফিরুন';

  @override
  String get bookmarksTooltip => 'বুকমার্ক';

  @override
  String get bookmarkThisPage => 'এই পৃষ্ঠা বুকমার্ক করুন';

  @override
  String get previousPage => 'আগের পৃষ্ঠা';

  @override
  String get nextPage => 'পরের পৃষ্ঠা';

  @override
  String get screenBrightness => 'স্ক্রিনের উজ্জ্বলতা';

  @override
  String get pauseReading => 'পড়া থামান';

  @override
  String get resumeReading => 'পড়া আবার শুরু';

  @override
  String get readAloud => 'পড়ে শোনান';

  @override
  String get pause => 'থামান';

  @override
  String get play => 'চালান';

  @override
  String get stopReading => 'পড়া বন্ধ করুন';

  @override
  String get noBookmarks =>
      'এখনও কোনো বুকমার্ক নেই। যোগ করতে বুকমার্ক আইকনে চাপুন।';

  @override
  String pageNumber(int page) {
    return 'পৃষ্ঠা $page';
  }

  @override
  String get bookNotFound => 'বই পাওয়া যায়নি';

  @override
  String get cantOpenBook => 'এই বই খোলা যাচ্ছে না';

  @override
  String get somethingWentWrong => 'কিছু ভুল হয়েছে।';

  @override
  String get findPdfsTitle => 'আপনার ডিভাইসে PDF খুঁজুন';

  @override
  String get storageAccessOff => 'স্টোরেজ অ্যাক্সেস বন্ধ';

  @override
  String get storageAccessOffBody =>
      'Comfy Reader-কে আপনার ডিভাইসে PDF খুঁজতে দিতে সেটিংস খুলুন — অথবা ম্যানুয়ালি যোগ করতে + চাপুন।';

  @override
  String get openSettingsLabel => 'সেটিংস খুলুন';

  @override
  String get tourLibraryTitle => 'আপনার বইগুলো';

  @override
  String get tourLibraryBody =>
      'আপনার আমদানি করা ও স্ক্যান করা সব PDF এখানে থাকে।';

  @override
  String get tourReadingTitle => 'পড়া চালিয়ে যান';

  @override
  String get tourReadingBody =>
      'শুরু করা বইতে ফিরে যান, ঠিক যেখানে থেমেছিলেন সেখান থেকে।';

  @override
  String get tourSettingsNavTitle => 'সেটিংস';

  @override
  String get tourSettingsNavBody =>
      'থিম, ভাষা, পড়ে শোনানোর কণ্ঠ ও আরও অনেক কিছু।';

  @override
  String get tourSearchTitle => 'অনুসন্ধান';

  @override
  String get tourSearchBody => 'শিরোনাম দিয়ে একটি বই খুঁজুন।';

  @override
  String get tourLayoutTitle => 'গ্রিড বা তালিকা';

  @override
  String get tourLayoutBody => 'গ্রিড ও তালিকা ভিউয়ের মধ্যে বদলান।';

  @override
  String get tourAddTitle => 'বই যোগ করুন';

  @override
  String get tourAddBody =>
      'পড়া শুরু করতে আপনার ডিভাইস থেকে একটি PDF আমদানি করুন।';

  @override
  String get tourThemeTitle => 'অবয়ব';

  @override
  String get tourThemeBody => 'দিন, রাত, বা সিস্টেম অনুসরণের মধ্যে বদলান।';

  @override
  String get tourLanguageTitle => 'অ্যাপের ভাষা';

  @override
  String get tourLanguageBody => 'পছন্দের ভাষায় অ্যাপের ইন্টারফেস পড়ুন।';

  @override
  String get tourVoicesTitle => 'পড়ে শোনানোর কণ্ঠ';

  @override
  String get tourVoicesBody => 'পড়ে শোনানোর কণ্ঠ বাছুন ও ভাষা ডাউনলোড করুন।';

  @override
  String get tourTintTitle => 'আরামদায়ক রঙ';

  @override
  String get tourTintBody => 'নতুন বইয়ের জন্য ডিফল্ট কাগজের রঙ ঠিক করুন।';

  @override
  String get tourTapTitle => 'নিয়ন্ত্রণ দেখান';

  @override
  String get tourTapBody =>
      'রিডার নিয়ন্ত্রণ দেখাতে বা লুকাতে পৃষ্ঠার মাঝখানে চাপুন।';

  @override
  String get tourScrubberTitle => 'পৃষ্ঠায় যান';

  @override
  String get tourScrubberBody => 'যেকোনো পৃষ্ঠা প্রিভিউ ও সেখানে যেতে টানুন।';

  @override
  String get tourReadAloudTitle => 'পড়ে শোনান';

  @override
  String get tourReadAloudBody => 'বইটি আপনাকে শব্দ করে পড়ে শোনানো হবে।';

  @override
  String get tourReaderTintTitle => 'আরামদায়ক রঙ';

  @override
  String get tourReaderTintBody => 'কাগজ, সেপিয়া ও রাতের রঙ পরিবর্তন করুন।';

  @override
  String get tourBrightnessTitle => 'উজ্জ্বলতা';

  @override
  String get tourBrightnessBody =>
      'বই ছাড়াই স্ক্রিনের উজ্জ্বলতা সমন্বয় করুন।';

  @override
  String get tourBookmarkTitle => 'বুকমার্ক';

  @override
  String get tourBookmarkBody =>
      'আপনার জায়গা সংরক্ষণ করুন ও পরে আবার খুঁজে নিন।';

  @override
  String get tourSwipeTitle => 'পাতা উল্টানো';

  @override
  String get tourSwipeShortBody => 'ছোট সোয়াইপ ফিরে আসে, পাতা উল্টায় না।';

  @override
  String get tourSwipeLongBody => 'লম্বা সোয়াইপে পাতা উল্টে যায়।';

  @override
  String get tourSwipeFastBody => 'দ্রুত সোয়াইপেও পাতা উল্টে যায়।';

  @override
  String get readScannedBooks => 'স্ক্যান করা বই পড়ুন';

  @override
  String get readScannedBooksSub =>
      'নির্বাচনযোগ্য টেক্সট নেই এমন পৃষ্ঠা পড়তে ডিভাইস OCR ব্যবহার করুন';
}
