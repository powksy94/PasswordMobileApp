import 'package:flutter/material.dart';
import '../../../shared/widgets/common/glass_panel.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/services/logout_service.dart';

class LogoutPanel extends StatelessWidget {
  const LogoutPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return GlassPanel(
      width: double.infinity,
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => LogoutService.confirmAndLogout(context),
          icon:  const Icon(Icons.logout),
          label: Text(l.btnLogout),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}
