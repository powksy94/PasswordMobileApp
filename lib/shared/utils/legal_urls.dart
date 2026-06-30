import 'package:flutter/widgets.dart';

const _privacyPolicyBase =
    'https://powksy.com/password-mobile-app/privacy-policy';
const _termsOfServiceBase =
    'https://powksy.com/password-mobile-app/terms-of-service';

String _withLang(String base, BuildContext context) {
  final lang = Localizations.localeOf(context).languageCode;
  return '$base?lang=$lang';
}

/// Returns the privacy policy URL with the device language injected as ?lang=.
String privacyPolicyUrl(BuildContext context) => _withLang(_privacyPolicyBase, context);

/// Returns the terms of service URL with the device language injected as ?lang=.
String termsOfServiceUrl(BuildContext context) => _withLang(_termsOfServiceBase, context);
