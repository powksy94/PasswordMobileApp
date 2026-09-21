import 'package:flutter/foundation.dart';

/// Signal global levé quand le serveur rejette le token de session (invalide
/// ou expiré). Volontairement neutre : la couche réseau le lève sans rien
/// savoir de l'authentification ni de la navigation, celui qui l'écoute
/// (`main.dart`) décide quoi en faire.
class SessionExpirySignal {
  static final ValueNotifier<int> notifier = ValueNotifier(0);

  static void raise() => notifier.value++;
}
