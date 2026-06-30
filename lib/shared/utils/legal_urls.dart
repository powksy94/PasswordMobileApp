import 'package:flutter/widgets.dart';

const _privacyPolicyBase =
    'https://powksy.com/password-mobile-app/privacy-policy';

/// Returns the privacy policy URL with the device language injected as ?lang=.
/// Supported values: fr, en, es. The web server falls back to French for any
/// unsupported code, so no filtering is required here.
String privacyPolicyUrl(BuildContext context) {
  final lang = Localizations.localeOf(context).languageCode;
  return '$_privacyPolicyBase?lang=$lang';
}
