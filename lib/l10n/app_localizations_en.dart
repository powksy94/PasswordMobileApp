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
  String get titleLockTimeout => 'Auto-lock';

  @override
  String get subtitleLockTimeout => 'Lock vault after';

  @override
  String get lockTimeoutNever => 'Never';

  @override
  String get lockTimeout1min => '1 minute';

  @override
  String get lockTimeout5min => '5 minutes';

  @override
  String get lockTimeout15min => '15 minutes';

  @override
  String get lockTimeout30min => '30 minutes';

  @override
  String get lockTimeout1h => '1 hour';

  @override
  String get titleVaultData => 'Vault data';

  @override
  String get titlePrivacy => 'Privacy';

  @override
  String get titleClipboardClear => 'Clipboard clearing';

  @override
  String get subtitleClipboardClear => 'Clear copied password after';

  @override
  String get clipboardClear10s => '10 seconds';

  @override
  String get clipboardClear30s => '30 seconds';

  @override
  String get clipboardClear1min => '1 minute';

  @override
  String get clipboardClear2min => '2 minutes';

  @override
  String get titleBiometricToggle => 'Biometric authentication';

  @override
  String get subtitleBiometricToggle =>
      'Use fingerprint or face recognition to unlock';

  @override
  String get titleScreenMasking => 'Screenshot protection';

  @override
  String get subtitleScreenMasking =>
      'Hide app content in the recent apps view and prevent screenshots';

  @override
  String get linkPrivacyPolicy => 'Privacy policy';

  @override
  String get linkTermsOfService => 'Terms of service';

  @override
  String get titleChangeMasterPassword => 'Change master password';

  @override
  String get warningChangeMasterPasswordTitle =>
      'Critical, irreversible action';

  @override
  String get warningChangeMasterPasswordBody =>
      'This operation re-encrypts your entire vault with a new master password.\n\n⚠️ If you forget this new password, your vault will be permanently unrecoverable — we cannot reset it.\n\nWrite it down in a safe place before continuing.';

  @override
  String get checkboxUnderstandRisks =>
      'I understand the risks and want to continue';

  @override
  String get labelCurrentMasterPassword => 'Current master password';

  @override
  String get labelNewMasterPassword => 'New master password';

  @override
  String get labelConfirmNewMasterPassword => 'Confirm new master password';

  @override
  String get btnChangeMasterPassword => 'Change master password';

  @override
  String get progressReencrypting => 'Re-encrypting vault…';

  @override
  String get successMasterPasswordChanged =>
      'Master password changed successfully';

  @override
  String get errorMasterPasswordChangeFailed =>
      'Change failed — your vault was not modified';

  @override
  String get titleExportDialog => 'Export';

  @override
  String get exportOptionBiometricTitle => 'Encrypted — biometric';

  @override
  String get exportOptionBiometricSubtitle =>
      'This device only. Requires fingerprint or PIN.';

  @override
  String get exportOptionPortableTitle => 'Encrypted — portable';

  @override
  String get exportOptionPortableSubtitle =>
      'Any device with your master password.';

  @override
  String get exportOptionJsonTitle => 'JSON — plaintext';

  @override
  String get exportOptionJsonSubtitle => '⚠️ Passwords readable by anyone.';

  @override
  String get errorBiometricExportUnavailable =>
      'Biometrics unavailable — use portable export';

  @override
  String get titlePortableExport => 'Portable export';

  @override
  String get bodyPortableExport =>
      'The file will be encrypted with your master password.\n\nIt will be saved to your Downloads folder.';

  @override
  String get btnExport => 'Export';

  @override
  String get titleJsonExport => 'JSON export';

  @override
  String get bodyJsonExport =>
      '⚠️ This file will contain your passwords in plaintext.\n\nIt will be saved to your Downloads folder.';

  @override
  String get dialogTitleSelectVaultFile =>
      'Select a vault file (.enc, .json, .csv)';

  @override
  String get errorCannotReadFile => 'Unable to read the file.';

  @override
  String get errorFileReadFailed => 'File read failed';

  @override
  String get errorImportFileEmpty => 'The file contains no items.';

  @override
  String get labelPasswordsImported => 'password(s) imported';

  @override
  String get errorImportFailed => 'Import error';

  @override
  String get labelPasswordsFound => 'password(s) found';

  @override
  String get bodyImportPreview =>
      'The following items will be added to your vault. Any duplicates will be kept.';

  @override
  String get labelAndMore => 'more';

  @override
  String get btnImport => 'Import';

  @override
  String get errorUnsupportedImportFormat =>
      'Unsupported format. Select a .enc, .json or .csv file.';

  @override
  String get errorImportDecryptionFailed =>
      'Unable to decrypt this file.\n\n• Check that you\'re signed in with the right account\n• Or that you\'re using the original device\'s fingerprint';

  @override
  String get errorInvalidCsvFile => 'The CSV file is empty or invalid.';

  @override
  String get errorCsvPasswordColumnMissing => 'Column \"password\" not found.';

  @override
  String get labelDetectedColumns => 'Detected columns';

  @override
  String get errorEmptyCsvImport => 'No passwords found in the CSV file.';

  @override
  String get labelImportFallbackPrefix => 'Import';

  @override
  String get reasonApproveVaultAccess =>
      'Confirm your identity to access the admin vault';

  @override
  String get reasonApproveAdminLogin =>
      'Confirm your identity to approve the admin login';

  @override
  String get errorApprovalCancelled =>
      'Fingerprint not recognized — approval cancelled';

  @override
  String get titleVaultAdminAccess => 'Admin vault access';

  @override
  String get titleAdminLogin => 'Admin login';

  @override
  String get bodyVaultAdminAccessRequest =>
      'A request to access the admin vault has just been made.\n\nApprove to unlock the vault.';

  @override
  String get bodyAdminLoginRequest =>
      'A login attempt to the admin panel has just been made.\n\nDid you initiate this login?';

  @override
  String get btnDeny => 'Deny';

  @override
  String get btnApprove => 'Approve';

  @override
  String get errorPrefix => 'Error';

  @override
  String get labelWeakPasswords => 'Weak passwords';

  @override
  String get subtitleWeakPasswords => 'Score < 60 — replace as a priority';

  @override
  String get labelReusedPasswords => 'Reused passwords';

  @override
  String get labelGroupsCount => 'group(s)';

  @override
  String get subtitleReusedPasswords =>
      'The same password is used across multiple services';

  @override
  String get labelSameServicesPassword => 'services — same password';

  @override
  String get labelAllGood => 'Excellent! No issues detected.';
}
