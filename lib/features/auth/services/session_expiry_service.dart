import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './auth_service.dart';
import '../../../shared/services/autofill_cache_service.dart';
import '../../../shared/services/role_provider.dart';
import '../../../l10n/app_localizations.dart';

/// Réagit à un token rejeté par le serveur : ferme la session, prévient
/// l'utilisateur et le renvoie à l'écran de connexion.
class SessionExpiryService {
  static bool _handling = false;

  static Future<void> handle(GlobalKey<NavigatorState> navigatorKey) async {
    // Plusieurs requêtes en vol peuvent échouer en rafale : on ne traite
    // qu'une fois, et pas du tout si la session est déjà fermée.
    if (_handling) return;
    _handling = true;
    try {
      if (await AuthService.getToken() == null) return;

      await AutofillCacheService.clear();
      await AuthService.expireSession();

      final context = navigatorKey.currentContext;
      if (context == null || !context.mounted) return;
      Provider.of<RoleProvider>(context, listen: false).deactivate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.sessionExpired)),
      );
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (r) => false);
    } finally {
      _handling = false;
    }
  }
}
