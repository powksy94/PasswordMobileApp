# Password Mobile App

Application mobile Flutter de gestion de mots de passe : coffre-fort chiffré en AES-256, déverrouillage biométrique, générateur de mots de passe, analyse de la santé du coffre et export/import sécurisé.

## Fonctionnalités

- **Coffre-fort chiffré** : stockage des identifiants chiffrés en AES-256, déverrouillage par mot de passe maître ou biométrie (empreinte/Face ID).
- **Générateur de mots de passe** : génération de mots de passe robustes avec contrôle des types de caractères et de la longueur.
- **Santé du coffre** : détection des mots de passe faibles ou réutilisés, score de robustesse.
- **Export / import** : export sécurisé du coffre (avec déverrouillage biométrique) et import depuis CSV avec aperçu avant validation.
- **Notifications push** : intégration Firebase Cloud Messaging (ex. demandes d'approbation côté admin).
- **Comptes & administration** : authentification, gestion du compte, paramètres de confidentialité et de verrouillage automatique.
- **Internationalisation** : interface disponible en français, anglais et espagnol via `AppLocalizations`.

## Architecture du code

Le dossier `lib/` est organisé selon le principe **"Layered Domain Folder Segregation"** : chaque domaine métier regroupe l'ensemble de ses couches techniques, et le code transverse est isolé dans `shared/`.

```
lib/
  features/
    auth/           pages/ widgets/ services/ utils/   — connexion, inscription, verrouillage, biométrie
    vault/          pages/ widgets/ services/ models/ utils/ — coffre-fort, export/import
    health/         pages/ widgets/               — analyse de la robustesse des mots de passe
    generator/      pages/ widgets/ services/     — génération de mots de passe
    settings/       pages/ widgets/ services/     — paramètres du compte et de l'app
    notifications/  widgets/ services/            — notifications push (FCM)
    home/           pages/                        — écran d'accueil
  shared/
    services/       — services transverses (API, crypto, presse-papiers, navigation, rôles, mises à jour…)
    utils/          — utilitaires partagés (score de robustesse, dossier de téléchargement…)
    widgets/        — composants UI réutilisables (panneaux, animations, indicateurs…)
  l10n/             — fichiers de traduction (.arb) et classes générées AppLocalizations
  theme/            — thèmes clair/sombre de l'application
  main.dart         — point d'entrée
```

Le backend associé (`PasswordMobileApp_backend`) suit la même organisation par domaine (`domains/{vault, auth, admin, …}` + `shared/`).

## Démarrage

### Prérequis

- Flutter SDK ≥ 3.0 (voir `environment.sdk` dans `pubspec.yaml`)
- Un projet Firebase configuré (fichiers `google-services.json` / `GoogleService-Info.plist`) pour les notifications push
- Le backend `PasswordMobileApp_backend` lancé et accessible (configuration de l'URL de l'API dans `shared/services/api_service.dart`)

### Installation

```bash
flutter pub get
flutter gen-l10n
```

### Lancer l'application

```bash
flutter run
```

### Lancer les tests

```bash
flutter test
```

### Analyse statique

```bash
flutter analyze
```

## Ressources Flutter

- [Lab : écrire sa première application Flutter](https://docs.flutter.dev/get-started/codelab)
- [Cookbook : exemples Flutter utiles](https://docs.flutter.dev/cookbook)
- [Documentation officielle Flutter](https://docs.flutter.dev/)
