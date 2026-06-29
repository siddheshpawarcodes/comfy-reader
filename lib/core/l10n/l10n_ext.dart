import 'package:comfy_reader/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// Ergonomic access to localized strings: `context.l10n.someKey`.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
