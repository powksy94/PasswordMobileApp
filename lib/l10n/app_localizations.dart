import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// No description provided for @navGenerator.
  ///
  /// In en, this message translates to:
  /// **'Generator'**
  String get navGenerator;

  /// No description provided for @navVault.
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get navVault;

  /// No description provided for @navHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get navHealth;

  /// No description provided for @tooltipImport.
  ///
  /// In en, this message translates to:
  /// **'Import vault'**
  String get tooltipImport;

  /// No description provided for @tooltipExport.
  ///
  /// In en, this message translates to:
  /// **'Export vault'**
  String get tooltipExport;

  /// No description provided for @tooltipAddPassword.
  ///
  /// In en, this message translates to:
  /// **'Add a password'**
  String get tooltipAddPassword;

  /// No description provided for @tooltipRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get tooltipRefresh;

  /// No description provided for @menuAccountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account settings'**
  String get menuAccountSettings;

  /// No description provided for @menuLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get menuLogout;

  /// No description provided for @dialogLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get dialogLogoutTitle;

  /// No description provided for @dialogLogoutContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get dialogLogoutContent;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get btnLogout;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'🔒 Session expired'**
  String get sessionExpired;

  /// No description provided for @lockScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Locked vault'**
  String get lockScreenTitle;

  /// No description provided for @btnUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get btnUnlock;

  /// No description provided for @btnUnlockVault.
  ///
  /// In en, this message translates to:
  /// **'Unlock vault'**
  String get btnUnlockVault;

  /// No description provided for @labelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get labelEmail;

  /// No description provided for @labelPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get labelPassword;

  /// No description provided for @labelMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Master password'**
  String get labelMasterPassword;

  /// No description provided for @labelAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Account password'**
  String get labelAccountPassword;

  /// No description provided for @btnLogin.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get btnLogin;

  /// No description provided for @biometricReason.
  ///
  /// In en, this message translates to:
  /// **'Log in to your vault'**
  String get biometricReason;

  /// No description provided for @signupStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get signupStep1Title;

  /// No description provided for @signupStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Your personal vault'**
  String get signupStep2Title;

  /// No description provided for @btnNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get btnNext;

  /// No description provided for @btnCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create my account'**
  String get btnCreateAccount;

  /// No description provided for @btnBack.
  ///
  /// In en, this message translates to:
  /// **'← Back'**
  String get btnBack;

  /// No description provided for @tutorialDismiss.
  ///
  /// In en, this message translates to:
  /// **'Got it →'**
  String get tutorialDismiss;

  /// No description provided for @tutorialStep1Body.
  ///
  /// In en, this message translates to:
  /// **'This email and password are used to log in to the app.\n\nThey are verified by our server at each login.'**
  String get tutorialStep1Body;

  /// No description provided for @tutorialStep2Body.
  ///
  /// In en, this message translates to:
  /// **'The master password encrypts all your passwords directly on your phone.\n\n⚠️ We do not know it. If you forget it, your vault will be permanently unrecoverable.\n\nWrite it down in a safe place.'**
  String get tutorialStep2Body;

  /// No description provided for @validatorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get validatorEmailInvalid;

  /// No description provided for @validatorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validatorPasswordMismatch;

  /// No description provided for @validatorMasterPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Master passwords do not match'**
  String get validatorMasterPasswordMismatch;

  /// No description provided for @warningMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Cannot be recovered if forgotten.'**
  String get warningMasterPassword;

  /// No description provided for @vaultEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty vault'**
  String get vaultEmpty;

  /// No description provided for @vaultNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get vaultNoResults;

  /// No description provided for @itemLabel.
  ///
  /// In en, this message translates to:
  /// **'Label *'**
  String get itemLabel;

  /// No description provided for @itemLogin.
  ///
  /// In en, this message translates to:
  /// **'Login / Email'**
  String get itemLogin;

  /// No description provided for @itemPassword.
  ///
  /// In en, this message translates to:
  /// **'Password *'**
  String get itemPassword;

  /// No description provided for @itemWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get itemWebsite;

  /// No description provided for @itemWebsiteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g.: amazon.com'**
  String get itemWebsiteHint;

  /// No description provided for @itemNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get itemNotes;

  /// No description provided for @itemIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get itemIcon;

  /// No description provided for @titleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get titleAdd;

  /// No description provided for @titleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get titleEdit;

  /// No description provided for @titleSettings.
  ///
  /// In en, this message translates to:
  /// **'Account settings'**
  String get titleSettings;

  /// No description provided for @titleMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Master password'**
  String get titleMasterPassword;

  /// No description provided for @btnSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// No description provided for @btnSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get btnSaving;

  /// No description provided for @btnAddToVault.
  ///
  /// In en, this message translates to:
  /// **'Add to vault'**
  String get btnAddToVault;

  /// No description provided for @btnAdding.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get btnAdding;

  /// No description provided for @successAdded.
  ///
  /// In en, this message translates to:
  /// **'Added successfully'**
  String get successAdded;

  /// No description provided for @successModified.
  ///
  /// In en, this message translates to:
  /// **'Modified successfully'**
  String get successModified;

  /// No description provided for @errorLabelRequired.
  ///
  /// In en, this message translates to:
  /// **'Label is required'**
  String get errorLabelRequired;

  /// No description provided for @errorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get errorPasswordRequired;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountContent.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible.\n\nAll your encrypted passwords will be permanently deleted.'**
  String get deleteAccountContent;

  /// No description provided for @btnDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get btnDeleteConfirm;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @btnLoginWithBiometric.
  ///
  /// In en, this message translates to:
  /// **'Log in with fingerprint'**
  String get btnLoginWithBiometric;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @btnSignup.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get btnSignup;

  /// No description provided for @validatorMinChars.
  ///
  /// In en, this message translates to:
  /// **'6 characters minimum'**
  String get validatorMinChars;

  /// No description provided for @sessionExpiredInfo.
  ///
  /// In en, this message translates to:
  /// **'Session expired due to inactivity.'**
  String get sessionExpiredInfo;

  /// No description provided for @masterPasswordDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Enter your master password to decrypt your vault.'**
  String get masterPasswordDialogContent;

  /// No description provided for @masterPasswordDialogHint.
  ///
  /// In en, this message translates to:
  /// **'This password is different from your login password.'**
  String get masterPasswordDialogHint;

  /// No description provided for @biometricUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock with biometrics'**
  String get biometricUnlock;

  /// No description provided for @lockScreenOrPassword.
  ///
  /// In en, this message translates to:
  /// **'or enter your master password'**
  String get lockScreenOrPassword;

  String get dialogDeleteTitle;
  String get dialogDeleteContent;
  String get btnDelete;
  String get snackItemDeleted;
  String get snackCopied;

  String get tooltipEdit;
  String get tooltipDelete;
  String get tooltipShow;
  String get tooltipHide;
  String get tooltipCopy;
  String get tooltipCopyPassword;

  String get snackPasswordAdded;
  String get errorBiometricKey;
  String get errorWrongMasterPassword;
  String get btnGenerate;
  String get errorLabelMissing;
  String get vaultEmptyExport;
  String get btnAlreadyAccount;

  String get titleChangePassword;
  String get labelCurrentPassword;
  String get labelNewPassword;
  String get labelConfirmNewPassword;
  String get btnChangePassword;
  String get titleDangerZone;
  String get btnDeleteAccount;

  String get passwordEmpty;
  String get signupTitle;

  String get errorBiometricFailed;
  String get labelConfirmPassword;
  String get labelConfirmMasterPassword;
  String get validatorMinCharsUnit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
