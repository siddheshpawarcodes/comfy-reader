import 'package:flutter/widgets.dart';

/// One selectable app UI language, with its name in its own script for the
/// language picker.
class AppLocale {
  const AppLocale(this.locale, this.nativeName);

  final Locale locale;
  final String nativeName;
}

/// The languages the app interface is translated into (must stay in sync with
/// the ARB files in lib/l10n and AppLocalizations.supportedLocales). English is
/// the default and fallback; the rest are ordered by speaker prevalence.
const List<AppLocale> kAppLocales = <AppLocale>[
  AppLocale(Locale('en'), 'English'),
  AppLocale(Locale('hi'), 'हिन्दी'),
  AppLocale(Locale('bn'), 'বাংলা'),
  AppLocale(Locale('ta'), 'தமிழ்'),
  AppLocale(Locale('te'), 'తెలుగు'),
  AppLocale(Locale('mr'), 'मराठी'),
  AppLocale(Locale('gu'), 'ગુજરાતી'),
  AppLocale(Locale('kn'), 'ಕನ್ನಡ'),
  AppLocale(Locale('ml'), 'മലയാളം'),
];

/// The native name for a [languageCode], falling back to the code itself.
String nativeLanguageName(String languageCode) {
  for (final l in kAppLocales) {
    if (l.locale.languageCode == languageCode) return l.nativeName;
  }
  return languageCode;
}
