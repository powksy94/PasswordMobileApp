// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navGenerator => 'Générateur';

  @override
  String get navVault => 'Coffre';

  @override
  String get navHealth => 'Santé';

  @override
  String get tooltipImport => 'Importer un coffre';

  @override
  String get tooltipExport => 'Exporter le coffre';

  @override
  String get tooltipAddPassword => 'Ajouter un mot de passe';

  @override
  String get tooltipRefresh => 'Actualiser';

  @override
  String get menuAccountSettings => 'Paramètres du compte';

  @override
  String get menuLogout => 'Déconnexion';

  @override
  String get dialogLogoutTitle => 'Déconnexion';

  @override
  String get dialogLogoutContent => 'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get btnCancel => 'Annuler';

  @override
  String get btnLogout => 'Déconnecter';

  @override
  String get sessionExpired => '🔒 Session expirée';

  @override
  String get lockScreenTitle => 'Coffre verrouillé';

  @override
  String get btnUnlock => 'Déverrouiller';

  @override
  String get btnUnlockVault => 'Déverrouiller le coffre';

  @override
  String get labelEmail => 'Email';

  @override
  String get labelPassword => 'Mot de passe';

  @override
  String get labelMasterPassword => 'Mot de passe maître';

  @override
  String get labelAccountPassword => 'Mot de passe du compte';

  @override
  String get btnLogin => 'Se connecter';

  @override
  String get biometricReason => 'Connectez-vous à votre coffre';

  @override
  String get signupStep1Title => 'Votre compte';

  @override
  String get signupStep2Title => 'Votre coffre-fort personnel';

  @override
  String get btnNext => 'Suivant';

  @override
  String get btnCreateAccount => 'Créer mon compte';

  @override
  String get btnBack => '← Retour';

  @override
  String get tutorialDismiss => 'J\'ai compris →';

  @override
  String get tutorialStep1Body =>
      'Cet email et ce mot de passe vous serviront à vous connecter à l\'application.\n\nIls sont vérifiés par notre serveur à chaque connexion.';

  @override
  String get tutorialStep2Body =>
      'Le mot de passe maître chiffre tous vos mots de passe directement sur votre téléphone.\n\n⚠️ Nous ne le connaissons pas. Si vous l\'oubliez, votre coffre sera définitivement irrécupérable.\n\nNotez-le dans un endroit sûr.';

  @override
  String get validatorEmailInvalid => 'Email invalide';

  @override
  String get validatorPasswordMismatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get validatorMasterPasswordMismatch =>
      'Les mots de passe maîtres ne correspondent pas';

  @override
  String get warningMasterPassword => 'Ne peut pas être récupéré si oublié.';

  @override
  String get vaultEmpty => 'Coffre vide';

  @override
  String get vaultNoResults => 'Aucun résultat';

  @override
  String get itemLabel => 'Label *';

  @override
  String get itemLogin => 'Login / Email';

  @override
  String get itemPassword => 'Mot de passe *';

  @override
  String get itemWebsite => 'Site web';

  @override
  String get itemWebsiteHint => 'ex: amazon.fr';

  @override
  String get itemNotes => 'Notes';

  @override
  String get itemIcon => 'Icône';

  @override
  String get titleAdd => 'Ajouter';

  @override
  String get titleEdit => 'Modifier';

  @override
  String get titleSettings => 'Paramètres du compte';

  @override
  String get titleMasterPassword => 'Mot de passe maître';

  @override
  String get btnSave => 'Enregistrer';

  @override
  String get btnSaving => 'Sauvegarde…';

  @override
  String get btnAddToVault => 'Ajouter au coffre';

  @override
  String get btnAdding => 'Enregistrement…';

  @override
  String get successAdded => 'Ajouté avec succès';

  @override
  String get successModified => 'Modifié avec succès';

  @override
  String get errorLabelRequired => 'Le label est requis';

  @override
  String get errorPasswordRequired => 'Le mot de passe est requis';

  @override
  String get dialogDeleteTitle => 'Supprimer';

  @override
  String get dialogDeleteContent => 'Supprimer cet élément définitivement ?';

  @override
  String get btnDelete => 'Supprimer';

  @override
  String get snackItemDeleted => 'Élément supprimé';

  @override
  String get snackCopied => 'Copié — effacé dans 30 s';

  @override
  String get tooltipEdit => 'Modifier';

  @override
  String get tooltipDelete => 'Supprimer';

  @override
  String get tooltipShow => 'Afficher';

  @override
  String get tooltipHide => 'Masquer';

  @override
  String get tooltipCopy => 'Copier';

  @override
  String get tooltipCopyPassword => 'Copier le mot de passe';

  @override
  String get snackPasswordAdded => 'Mot de passe ajouté au coffre !';

  @override
  String get errorBiometricKey =>
      'Clé biométrique introuvable — entrez le mot de passe maître';

  @override
  String get errorWrongMasterPassword => 'Mot de passe maître incorrect';

  @override
  String get btnGenerate => 'Générer';

  @override
  String get errorLabelMissing =>
      'Veuillez entrer un label pour le mot de passe.';

  @override
  String get vaultEmptyExport => 'Coffre vide — rien à exporter';

  @override
  String get btnAlreadyAccount => 'Déjà un compte ? Se connecter';

  @override
  String get titleChangePassword => 'Changer le mot de passe de connexion';

  @override
  String get labelCurrentPassword => 'Mot de passe actuel';

  @override
  String get labelNewPassword => 'Nouveau mot de passe';

  @override
  String get labelConfirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get btnChangePassword => 'Modifier le mot de passe';

  @override
  String get titleDangerZone => 'Zone dangereuse';

  @override
  String get btnDeleteAccount => 'Supprimer mon compte';

  @override
  String get passwordEmpty => 'Mot de passe vide';

  @override
  String get signupTitle => 'Créer un compte';

  @override
  String get errorBiometricFailed =>
      'Empreinte non reconnue — réessayez ou utilisez le formulaire';

  @override
  String get labelConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get labelConfirmMasterPassword => 'Confirmer le mot de passe maître';

  @override
  String get validatorMinCharsUnit => 'caractères minimum';

  @override
  String get deleteAccountTitle => 'Supprimer le compte';

  @override
  String get deleteAccountContent =>
      'Cette action est irréversible.\n\nTous vos mots de passe chiffrés seront définitivement supprimés.';

  @override
  String get btnDeleteConfirm => 'Supprimer définitivement';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get btnLoginWithBiometric => 'Se connecter avec l\'empreinte';

  @override
  String get orDivider => 'ou';

  @override
  String get btnSignup => 'Créer un compte';

  @override
  String get validatorMinChars => '6 caractères minimum';

  @override
  String get sessionExpiredInfo => 'Session expirée après inactivité.';

  @override
  String get masterPasswordDialogContent =>
      'Entrez votre mot de passe maître pour déchiffrer votre coffre.';

  @override
  String get masterPasswordDialogHint =>
      'Ce mot de passe est différent de votre mot de passe de connexion.';

  @override
  String get biometricUnlock => 'Déverrouiller avec biométrie';

  @override
  String get lockScreenOrPassword => 'ou entrez votre mot de passe maître';

  @override
  String get titleLockTimeout => 'Verrouillage automatique';

  @override
  String get subtitleLockTimeout => 'Verrouiller le coffre après';

  @override
  String get lockTimeoutNever => 'Jamais';

  @override
  String get lockTimeout1min => '1 minute';

  @override
  String get lockTimeout5min => '5 minutes';

  @override
  String get lockTimeout15min => '15 minutes';

  @override
  String get lockTimeout30min => '30 minutes';

  @override
  String get lockTimeout1h => '1 heure';

  @override
  String get titleVaultData => 'Données du coffre';

  @override
  String get titlePrivacy => 'Confidentialité';

  @override
  String get titleClipboardClear => 'Effacement du presse-papiers';

  @override
  String get subtitleClipboardClear => 'Effacer le mot de passe copié après';

  @override
  String get clipboardClear10s => '10 secondes';

  @override
  String get clipboardClear30s => '30 secondes';

  @override
  String get clipboardClear1min => '1 minute';

  @override
  String get clipboardClear2min => '2 minutes';

  @override
  String get titleBiometricToggle => 'Authentification biométrique';

  @override
  String get subtitleBiometricToggle =>
      'Utiliser l\'empreinte digitale ou la reconnaissance faciale pour déverrouiller';

  @override
  String get titleScreenMasking => 'Masquage anti-capture d\'écran';

  @override
  String get subtitleScreenMasking =>
      'Masquer le contenu de l\'application dans le multitâche et empêcher les captures d\'écran';

  @override
  String get linkPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get linkTermsOfService => 'Conditions d\'utilisation';

  @override
  String get titleChangeMasterPassword => 'Changer le mot de passe maître';

  @override
  String get warningChangeMasterPasswordTitle =>
      'Action critique et irréversible';

  @override
  String get warningChangeMasterPasswordBody =>
      'Cette opération re-chiffre l\'intégralité de votre coffre avec un nouveau mot de passe maître.\n\n⚠️ Si vous oubliez ce nouveau mot de passe, votre coffre sera définitivement irrécupérable — nous ne pouvons pas le réinitialiser.\n\nNotez-le dans un endroit sûr avant de continuer.';

  @override
  String get checkboxUnderstandRisks =>
      'Je comprends les risques et je souhaite continuer';

  @override
  String get labelCurrentMasterPassword => 'Mot de passe maître actuel';

  @override
  String get labelNewMasterPassword => 'Nouveau mot de passe maître';

  @override
  String get labelConfirmNewMasterPassword =>
      'Confirmer le nouveau mot de passe maître';

  @override
  String get btnChangeMasterPassword => 'Changer le mot de passe maître';

  @override
  String get progressReencrypting => 'Re-chiffrement du coffre…';

  @override
  String get successMasterPasswordChanged =>
      'Mot de passe maître changé avec succès';

  @override
  String get errorMasterPasswordChangeFailed =>
      'Échec du changement — votre coffre n\'a pas été modifié';

  @override
  String get titleExportDialog => 'Exporter';

  @override
  String get exportOptionBiometricTitle => 'Chiffré — biométrique';

  @override
  String get exportOptionBiometricSubtitle =>
      'Cet appareil uniquement. Empreinte digitale ou code requis.';

  @override
  String get exportOptionPortableTitle => 'Chiffré — portable';

  @override
  String get exportOptionPortableSubtitle =>
      'N\'importe quel appareil avec votre mot de passe maître.';

  @override
  String get exportOptionJsonTitle => 'JSON — texte brut';

  @override
  String get exportOptionJsonSubtitle =>
      '⚠️ Mots de passe lisibles par n\'importe qui.';

  @override
  String get errorBiometricExportUnavailable =>
      'Biométrie indisponible — utilisez l\'export portable';

  @override
  String get titlePortableExport => 'Export portable';

  @override
  String get bodyPortableExport =>
      'Le fichier sera chiffré avec votre mot de passe maître.\n\nIl sera enregistré dans votre dossier Téléchargements.';

  @override
  String get btnExport => 'Exporter';

  @override
  String get titleJsonExport => 'Export JSON';

  @override
  String get bodyJsonExport =>
      '⚠️ Ce fichier contiendra vos mots de passe en texte brut.\n\nIl sera enregistré dans votre dossier Téléchargements.';

  @override
  String get dialogTitleSelectVaultFile =>
      'Sélectionner un fichier vault (.enc, .json, .csv)';

  @override
  String get errorCannotReadFile => 'Impossible de lire le fichier.';

  @override
  String get errorFileReadFailed => 'Lecture échouée';

  @override
  String get errorImportFileEmpty => 'Le fichier ne contient aucun item.';

  @override
  String get labelPasswordsImported => 'mot(s) de passe importé(s)';

  @override
  String get errorImportFailed => 'Erreur import';

  @override
  String get labelPasswordsFound => 'mot(s) de passe trouvé(s)';

  @override
  String get bodyImportPreview =>
      'Les items suivants seront ajoutés à votre vault. Les éventuels doublons seront conservés.';

  @override
  String get labelAndMore => 'autre(s)';

  @override
  String get btnImport => 'Importer';

  @override
  String get errorUnsupportedImportFormat =>
      'Format non supporté. Sélectionnez un fichier .enc, .json ou .csv.';

  @override
  String get errorImportDecryptionFailed =>
      'Impossible de déchiffrer ce fichier.\n\n• Vérifiez que vous êtes connecté avec le bon compte\n• Ou que vous utilisez l\'empreinte de l\'appareil d\'origine';

  @override
  String get errorInvalidCsvFile => 'Le fichier CSV est vide ou invalide.';

  @override
  String get errorCsvPasswordColumnMissing =>
      'Colonne \"password\" introuvable.';

  @override
  String get labelDetectedColumns => 'Colonnes détectées';

  @override
  String get errorEmptyCsvImport =>
      'Aucun mot de passe trouvé dans le fichier CSV.';

  @override
  String get labelImportFallbackPrefix => 'Import';

  @override
  String get reasonApproveVaultAccess =>
      'Confirmez votre identité pour accéder au vault admin';

  @override
  String get reasonApproveAdminLogin =>
      'Confirmez votre identité pour approuver la connexion admin';

  @override
  String get errorApprovalCancelled =>
      'Empreinte non reconnue — approbation annulée';

  @override
  String get titleVaultAdminAccess => 'Accès vault admin';

  @override
  String get titleAdminLogin => 'Connexion admin';

  @override
  String get bodyVaultAdminAccessRequest =>
      'Une demande d\'accès au vault admin vient d\'être effectuée.\n\nApprouvez pour déverrouiller le vault.';

  @override
  String get bodyAdminLoginRequest =>
      'Une tentative de connexion au panneau d\'administration vient d\'être effectuée.\n\nÊtes-vous à l\'origine de cette connexion ?';

  @override
  String get btnDeny => 'Refuser';

  @override
  String get btnApprove => 'Approuver';

  @override
  String get errorPrefix => 'Erreur';

  @override
  String get labelWeakPasswords => 'Mots de passe faibles';

  @override
  String get subtitleWeakPasswords => 'Score < 60 — à remplacer en priorité';

  @override
  String get labelReusedPasswords => 'Mots de passe réutilisés';

  @override
  String get labelGroupsCount => 'groupe(s)';

  @override
  String get subtitleReusedPasswords =>
      'Le même mot de passe est utilisé sur plusieurs services';

  @override
  String get labelSameServicesPassword => 'services — même mot de passe';

  @override
  String get labelAllGood => 'Excellent ! Aucun problème détecté.';
}
