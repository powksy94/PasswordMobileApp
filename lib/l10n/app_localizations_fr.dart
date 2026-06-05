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
  String get errorLabelMissing => 'Veuillez entrer un label pour le mot de passe.';

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
}
