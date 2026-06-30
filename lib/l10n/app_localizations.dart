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

  /// No description provided for @dialogDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dialogDeleteTitle;

  /// No description provided for @dialogDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Delete this item permanently?'**
  String get dialogDeleteContent;

  /// No description provided for @btnDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btnDelete;

  /// No description provided for @snackItemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted'**
  String get snackItemDeleted;

  /// No description provided for @snackCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied — cleared in 30 s'**
  String get snackCopied;

  /// No description provided for @tooltipEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get tooltipEdit;

  /// No description provided for @tooltipDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get tooltipDelete;

  /// No description provided for @tooltipShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get tooltipShow;

  /// No description provided for @tooltipHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get tooltipHide;

  /// No description provided for @tooltipCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get tooltipCopy;

  /// No description provided for @tooltipCopyPassword.
  ///
  /// In en, this message translates to:
  /// **'Copy password'**
  String get tooltipCopyPassword;

  /// No description provided for @snackPasswordAdded.
  ///
  /// In en, this message translates to:
  /// **'Password added to vault!'**
  String get snackPasswordAdded;

  /// No description provided for @errorBiometricKey.
  ///
  /// In en, this message translates to:
  /// **'Biometric key not found — enter your master password'**
  String get errorBiometricKey;

  /// No description provided for @errorWrongMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong master password'**
  String get errorWrongMasterPassword;

  /// No description provided for @btnGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get btnGenerate;

  /// No description provided for @errorLabelMissing.
  ///
  /// In en, this message translates to:
  /// **'Please enter a label for the password.'**
  String get errorLabelMissing;

  /// No description provided for @vaultEmptyExport.
  ///
  /// In en, this message translates to:
  /// **'Empty vault — nothing to export'**
  String get vaultEmptyExport;

  /// No description provided for @btnAlreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get btnAlreadyAccount;

  /// No description provided for @titleChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change login password'**
  String get titleChangePassword;

  /// No description provided for @labelCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get labelCurrentPassword;

  /// No description provided for @labelNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get labelNewPassword;

  /// No description provided for @labelConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get labelConfirmNewPassword;

  /// No description provided for @btnChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get btnChangePassword;

  /// No description provided for @titleDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get titleDangerZone;

  /// No description provided for @btnDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get btnDeleteAccount;

  /// No description provided for @passwordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty password'**
  String get passwordEmpty;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get signupTitle;

  /// No description provided for @errorBiometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint not recognized — retry or use the form'**
  String get errorBiometricFailed;

  /// No description provided for @labelConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get labelConfirmPassword;

  /// No description provided for @labelConfirmMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm master password'**
  String get labelConfirmMasterPassword;

  /// No description provided for @validatorMinCharsUnit.
  ///
  /// In en, this message translates to:
  /// **'characters minimum'**
  String get validatorMinCharsUnit;

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

  /// No description provided for @titleLockTimeout.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock'**
  String get titleLockTimeout;

  /// No description provided for @subtitleLockTimeout.
  ///
  /// In en, this message translates to:
  /// **'Lock vault after'**
  String get subtitleLockTimeout;

  /// No description provided for @lockTimeoutNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get lockTimeoutNever;

  /// No description provided for @lockTimeout1min.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get lockTimeout1min;

  /// No description provided for @lockTimeout5min.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get lockTimeout5min;

  /// No description provided for @lockTimeout15min.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get lockTimeout15min;

  /// No description provided for @lockTimeout30min.
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get lockTimeout30min;

  /// No description provided for @lockTimeout1h.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get lockTimeout1h;

  /// No description provided for @titleVaultData.
  ///
  /// In en, this message translates to:
  /// **'Vault data'**
  String get titleVaultData;

  /// No description provided for @titlePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get titlePrivacy;

  /// No description provided for @titleClipboardClear.
  ///
  /// In en, this message translates to:
  /// **'Clipboard clearing'**
  String get titleClipboardClear;

  /// No description provided for @subtitleClipboardClear.
  ///
  /// In en, this message translates to:
  /// **'Clear copied password after'**
  String get subtitleClipboardClear;

  /// No description provided for @clipboardClear10s.
  ///
  /// In en, this message translates to:
  /// **'10 seconds'**
  String get clipboardClear10s;

  /// No description provided for @clipboardClear30s.
  ///
  /// In en, this message translates to:
  /// **'30 seconds'**
  String get clipboardClear30s;

  /// No description provided for @clipboardClear1min.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get clipboardClear1min;

  /// No description provided for @clipboardClear2min.
  ///
  /// In en, this message translates to:
  /// **'2 minutes'**
  String get clipboardClear2min;

  /// No description provided for @titleBiometricToggle.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication'**
  String get titleBiometricToggle;

  /// No description provided for @subtitleBiometricToggle.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face recognition to unlock'**
  String get subtitleBiometricToggle;

  /// No description provided for @titleScreenMasking.
  ///
  /// In en, this message translates to:
  /// **'Screenshot protection'**
  String get titleScreenMasking;

  /// No description provided for @subtitleScreenMasking.
  ///
  /// In en, this message translates to:
  /// **'Hide app content in the recent apps view and prevent screenshots'**
  String get subtitleScreenMasking;

  /// No description provided for @linkPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get linkPrivacyPolicy;

  /// No description provided for @titleChangeMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Change master password'**
  String get titleChangeMasterPassword;

  /// No description provided for @warningChangeMasterPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Critical, irreversible action'**
  String get warningChangeMasterPasswordTitle;

  /// No description provided for @warningChangeMasterPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'This operation re-encrypts your entire vault with a new master password.\n\n⚠️ If you forget this new password, your vault will be permanently unrecoverable — we cannot reset it.\n\nWrite it down in a safe place before continuing.'**
  String get warningChangeMasterPasswordBody;

  /// No description provided for @checkboxUnderstandRisks.
  ///
  /// In en, this message translates to:
  /// **'I understand the risks and want to continue'**
  String get checkboxUnderstandRisks;

  /// No description provided for @labelCurrentMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Current master password'**
  String get labelCurrentMasterPassword;

  /// No description provided for @labelNewMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'New master password'**
  String get labelNewMasterPassword;

  /// No description provided for @labelConfirmNewMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new master password'**
  String get labelConfirmNewMasterPassword;

  /// No description provided for @btnChangeMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Change master password'**
  String get btnChangeMasterPassword;

  /// No description provided for @progressReencrypting.
  ///
  /// In en, this message translates to:
  /// **'Re-encrypting vault…'**
  String get progressReencrypting;

  /// No description provided for @successMasterPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Master password changed successfully'**
  String get successMasterPasswordChanged;

  /// No description provided for @errorMasterPasswordChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Change failed — your vault was not modified'**
  String get errorMasterPasswordChangeFailed;

  /// No description provided for @titleExportDialog.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get titleExportDialog;

  /// No description provided for @exportOptionBiometricTitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypted — biometric'**
  String get exportOptionBiometricTitle;

  /// No description provided for @exportOptionBiometricSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This device only. Requires fingerprint or PIN.'**
  String get exportOptionBiometricSubtitle;

  /// No description provided for @exportOptionPortableTitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypted — portable'**
  String get exportOptionPortableTitle;

  /// No description provided for @exportOptionPortableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Any device with your master password.'**
  String get exportOptionPortableSubtitle;

  /// No description provided for @exportOptionJsonTitle.
  ///
  /// In en, this message translates to:
  /// **'JSON — plaintext'**
  String get exportOptionJsonTitle;

  /// No description provided for @exportOptionJsonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Passwords readable by anyone.'**
  String get exportOptionJsonSubtitle;

  /// No description provided for @errorBiometricExportUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics unavailable — use portable export'**
  String get errorBiometricExportUnavailable;

  /// No description provided for @titlePortableExport.
  ///
  /// In en, this message translates to:
  /// **'Portable export'**
  String get titlePortableExport;

  /// No description provided for @bodyPortableExport.
  ///
  /// In en, this message translates to:
  /// **'The file will be encrypted with your master password.\n\nIt will be saved to your Downloads folder.'**
  String get bodyPortableExport;

  /// No description provided for @btnExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get btnExport;

  /// No description provided for @titleJsonExport.
  ///
  /// In en, this message translates to:
  /// **'JSON export'**
  String get titleJsonExport;

  /// No description provided for @bodyJsonExport.
  ///
  /// In en, this message translates to:
  /// **'⚠️ This file will contain your passwords in plaintext.\n\nIt will be saved to your Downloads folder.'**
  String get bodyJsonExport;

  /// No description provided for @dialogTitleSelectVaultFile.
  ///
  /// In en, this message translates to:
  /// **'Select a vault file (.enc, .json, .csv)'**
  String get dialogTitleSelectVaultFile;

  /// No description provided for @errorCannotReadFile.
  ///
  /// In en, this message translates to:
  /// **'Unable to read the file.'**
  String get errorCannotReadFile;

  /// No description provided for @errorFileReadFailed.
  ///
  /// In en, this message translates to:
  /// **'File read failed'**
  String get errorFileReadFailed;

  /// No description provided for @errorImportFileEmpty.
  ///
  /// In en, this message translates to:
  /// **'The file contains no items.'**
  String get errorImportFileEmpty;

  /// No description provided for @labelPasswordsImported.
  ///
  /// In en, this message translates to:
  /// **'password(s) imported'**
  String get labelPasswordsImported;

  /// No description provided for @errorImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import error'**
  String get errorImportFailed;

  /// No description provided for @labelPasswordsFound.
  ///
  /// In en, this message translates to:
  /// **'password(s) found'**
  String get labelPasswordsFound;

  /// No description provided for @bodyImportPreview.
  ///
  /// In en, this message translates to:
  /// **'The following items will be added to your vault. Any duplicates will be kept.'**
  String get bodyImportPreview;

  /// No description provided for @labelAndMore.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get labelAndMore;

  /// No description provided for @btnImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get btnImport;

  /// No description provided for @errorUnsupportedImportFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported format. Select a .enc, .json or .csv file.'**
  String get errorUnsupportedImportFormat;

  /// No description provided for @errorImportDecryptionFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to decrypt this file.\n\n• Check that you\'re signed in with the right account\n• Or that you\'re using the original device\'s fingerprint'**
  String get errorImportDecryptionFailed;

  /// No description provided for @errorInvalidCsvFile.
  ///
  /// In en, this message translates to:
  /// **'The CSV file is empty or invalid.'**
  String get errorInvalidCsvFile;

  /// No description provided for @errorCsvPasswordColumnMissing.
  ///
  /// In en, this message translates to:
  /// **'Column \"password\" not found.'**
  String get errorCsvPasswordColumnMissing;

  /// No description provided for @labelDetectedColumns.
  ///
  /// In en, this message translates to:
  /// **'Detected columns'**
  String get labelDetectedColumns;

  /// No description provided for @errorEmptyCsvImport.
  ///
  /// In en, this message translates to:
  /// **'No passwords found in the CSV file.'**
  String get errorEmptyCsvImport;

  /// No description provided for @labelImportFallbackPrefix.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get labelImportFallbackPrefix;

  /// No description provided for @reasonApproveVaultAccess.
  ///
  /// In en, this message translates to:
  /// **'Confirm your identity to access the admin vault'**
  String get reasonApproveVaultAccess;

  /// No description provided for @reasonApproveAdminLogin.
  ///
  /// In en, this message translates to:
  /// **'Confirm your identity to approve the admin login'**
  String get reasonApproveAdminLogin;

  /// No description provided for @errorApprovalCancelled.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint not recognized — approval cancelled'**
  String get errorApprovalCancelled;

  /// No description provided for @titleVaultAdminAccess.
  ///
  /// In en, this message translates to:
  /// **'Admin vault access'**
  String get titleVaultAdminAccess;

  /// No description provided for @titleAdminLogin.
  ///
  /// In en, this message translates to:
  /// **'Admin login'**
  String get titleAdminLogin;

  /// No description provided for @bodyVaultAdminAccessRequest.
  ///
  /// In en, this message translates to:
  /// **'A request to access the admin vault has just been made.\n\nApprove to unlock the vault.'**
  String get bodyVaultAdminAccessRequest;

  /// No description provided for @bodyAdminLoginRequest.
  ///
  /// In en, this message translates to:
  /// **'A login attempt to the admin panel has just been made.\n\nDid you initiate this login?'**
  String get bodyAdminLoginRequest;

  /// No description provided for @btnDeny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get btnDeny;

  /// No description provided for @btnApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get btnApprove;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorPrefix;

  /// No description provided for @labelWeakPasswords.
  ///
  /// In en, this message translates to:
  /// **'Weak passwords'**
  String get labelWeakPasswords;

  /// No description provided for @subtitleWeakPasswords.
  ///
  /// In en, this message translates to:
  /// **'Score < 60 — replace as a priority'**
  String get subtitleWeakPasswords;

  /// No description provided for @labelReusedPasswords.
  ///
  /// In en, this message translates to:
  /// **'Reused passwords'**
  String get labelReusedPasswords;

  /// No description provided for @labelGroupsCount.
  ///
  /// In en, this message translates to:
  /// **'group(s)'**
  String get labelGroupsCount;

  /// No description provided for @subtitleReusedPasswords.
  ///
  /// In en, this message translates to:
  /// **'The same password is used across multiple services'**
  String get subtitleReusedPasswords;

  /// No description provided for @labelSameServicesPassword.
  ///
  /// In en, this message translates to:
  /// **'services — same password'**
  String get labelSameServicesPassword;

  /// No description provided for @labelAllGood.
  ///
  /// In en, this message translates to:
  /// **'Excellent! No issues detected.'**
  String get labelAllGood;
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
