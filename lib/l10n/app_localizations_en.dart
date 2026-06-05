// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navGenerator => 'Generator';

  @override
  String get navVault => 'Vault';

  @override
  String get navHealth => 'Health';

  @override
  String get tooltipImport => 'Import vault';

  @override
  String get tooltipExport => 'Export vault';

  @override
  String get tooltipAddPassword => 'Add a password';

  @override
  String get tooltipRefresh => 'Refresh';

  @override
  String get menuAccountSettings => 'Account settings';

  @override
  String get menuLogout => 'Logout';

  @override
  String get dialogLogoutTitle => 'Logout';

  @override
  String get dialogLogoutContent => 'Are you sure you want to log out?';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnLogout => 'Log out';

  @override
  String get sessionExpired => '🔒 Session expired';

  @override
  String get lockScreenTitle => 'Locked vault';

  @override
  String get btnUnlock => 'Unlock';

  @override
  String get btnUnlockVault => 'Unlock vault';

  @override
  String get labelEmail => 'Email';

  @override
  String get labelPassword => 'Password';

  @override
  String get labelMasterPassword => 'Master password';

  @override
  String get labelAccountPassword => 'Account password';

  @override
  String get btnLogin => 'Log in';

  @override
  String get biometricReason => 'Log in to your vault';

  @override
  String get signupStep1Title => 'Your account';

  @override
  String get signupStep2Title => 'Your personal vault';

  @override
  String get btnNext => 'Next';

  @override
  String get btnCreateAccount => 'Create my account';

  @override
  String get btnBack => '← Back';

  @override
  String get tutorialDismiss => 'Got it →';

  @override
  String get tutorialStep1Body =>
      'This email and password are used to log in to the app.\n\nThey are verified by our server at each login.';

  @override
  String get tutorialStep2Body =>
      'The master password encrypts all your passwords directly on your phone.\n\n⚠️ We do not know it. If you forget it, your vault will be permanently unrecoverable.\n\nWrite it down in a safe place.';

  @override
  String get validatorEmailInvalid => 'Invalid email';

  @override
  String get validatorPasswordMismatch => 'Passwords do not match';

  @override
  String get validatorMasterPasswordMismatch => 'Master passwords do not match';

  @override
  String get warningMasterPassword => 'Cannot be recovered if forgotten.';

  @override
  String get vaultEmpty => 'Empty vault';

  @override
  String get vaultNoResults => 'No results';

  @override
  String get itemLabel => 'Label *';

  @override
  String get itemLogin => 'Login / Email';

  @override
  String get itemPassword => 'Password *';

  @override
  String get itemWebsite => 'Website';

  @override
  String get itemWebsiteHint => 'e.g.: amazon.com';

  @override
  String get itemNotes => 'Notes';

  @override
  String get itemIcon => 'Icon';

  @override
  String get titleAdd => 'Add';

  @override
  String get titleEdit => 'Edit';

  @override
  String get titleSettings => 'Account settings';

  @override
  String get titleMasterPassword => 'Master password';

  @override
  String get btnSave => 'Save';

  @override
  String get btnSaving => 'Saving…';

  @override
  String get btnAddToVault => 'Add to vault';

  @override
  String get btnAdding => 'Saving…';

  @override
  String get successAdded => 'Added successfully';

  @override
  String get successModified => 'Modified successfully';

  @override
  String get errorLabelRequired => 'Label is required';

  @override
  String get errorPasswordRequired => 'Password is required';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountContent =>
      'This action is irreversible.\n\nAll your encrypted passwords will be permanently deleted.';

  @override
  String get btnDeleteConfirm => 'Delete permanently';

  @override
  String get loginTitle => 'Login';

  @override
  String get btnLoginWithBiometric => 'Log in with fingerprint';

  @override
  String get orDivider => 'or';

  @override
  String get btnSignup => 'Create an account';

  @override
  String get validatorMinChars => '6 characters minimum';

  @override
  String get sessionExpiredInfo => 'Session expired due to inactivity.';

  @override
  String get masterPasswordDialogContent =>
      'Enter your master password to decrypt your vault.';

  @override
  String get masterPasswordDialogHint =>
      'This password is different from your login password.';

  @override
  String get biometricUnlock => 'Unlock with biometrics';

  @override
  String get lockScreenOrPassword => 'or enter your master password';

  @override
  String get dialogDeleteTitle => 'Delete';

  @override
  String get dialogDeleteContent => 'Delete this item permanently?';

  @override
  String get btnDelete => 'Delete';

  @override
  String get snackItemDeleted => 'Item deleted';

  @override
  String get snackCopied => 'Copied — cleared in 30 s';

  @override
  String get tooltipEdit => 'Edit';

  @override
  String get tooltipDelete => 'Delete';

  @override
  String get tooltipShow => 'Show';

  @override
  String get tooltipHide => 'Hide';

  @override
  String get tooltipCopy => 'Copy';

  @override
  String get tooltipCopyPassword => 'Copy password';

  @override
  String get snackPasswordAdded => 'Password added to vault!';

  @override
  String get errorBiometricKey =>
      'Biometric key not found — enter your master password';

  @override
  String get errorWrongMasterPassword => 'Wrong master password';

  @override
  String get btnGenerate => 'Generate';

  @override
  String get errorLabelMissing => 'Please enter a label for the password.';

  @override
  String get vaultEmptyExport => 'Empty vault — nothing to export';

  @override
  String get btnAlreadyAccount => 'Already have an account? Log in';

  @override
  String get titleChangePassword => 'Change login password';

  @override
  String get labelCurrentPassword => 'Current password';

  @override
  String get labelNewPassword => 'New password';

  @override
  String get labelConfirmNewPassword => 'Confirm new password';

  @override
  String get btnChangePassword => 'Change password';

  @override
  String get titleDangerZone => 'Danger zone';

  @override
  String get btnDeleteAccount => 'Delete my account';

  @override
  String get passwordEmpty => 'Empty password';

  @override
  String get signupTitle => 'Create an account';

  @override
  String get errorBiometricFailed =>
      'Fingerprint not recognized — retry or use the form';

  @override
  String get labelConfirmPassword => 'Confirm password';

  @override
  String get labelConfirmMasterPassword => 'Confirm master password';

  @override
  String get validatorMinCharsUnit => 'characters minimum';
}
