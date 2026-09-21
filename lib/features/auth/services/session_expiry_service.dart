import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './auth_service.dart';
import '../../../shared/services/autofill_cache_service.dart';
import '../../../shared/services/role_provider.dart';
import '../../../l10n/app_localizations.dart';

/// Reacts to a token rejected by the server: closes the session, notifies
/// the user and redirects to the login screen.
class SessionExpiryService {
  static bool _handling = false;

  static Future<void> handle(GlobalKey<NavigatorState> navigatorKey) async {
    // Several in-flight requests can fail in a burst: we only handle
    // it once, and not at all if the session is already closed.
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
