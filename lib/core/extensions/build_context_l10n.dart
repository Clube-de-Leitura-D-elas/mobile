import 'package:flutter/widgets.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Extension on [BuildContext] for easy access to localized strings.
extension BuildContextL10n on BuildContext {
  /// Access [AppLocalizations] for the current context.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

