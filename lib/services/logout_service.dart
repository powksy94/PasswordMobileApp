import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'autofill_cache_service.dart';
import 'role_provider.dart';
import '../l10n/app_localizations.dart';

/// Affiche la confirmation de déconnexion puis, si l'utilisateur confirme,
/// nettoie la session et redirige vers l'écran de connexion.
class LogoutService {
  static Future<void> confirmAndLogout(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   Text(l.dialogLogoutTitle),
        content: Text(l.dialogLogoutContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.btnCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.btnLogout),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await AutofillCacheService.clear();
    await AuthService.logout();
    if (!context.mounted) return;
    Provider.of<RoleProvider>(context, listen: false).deactivate();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
  }
}
