import 'package:flutter/material.dart';
import '../../../shared/services/api_service.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/services/biometric_service.dart';
import '../../../l10n/app_localizations.dart';

/// Type de demande d'approbation reçue par notification push.
enum ApprovalDialogType { adminLogin, vaultAccess }

/// Dialog générique demandant à l'utilisateur d'approuver ou refuser
/// une connexion admin / un accès au vault admin, avec confirmation biométrique.
class ApprovalDialog extends StatefulWidget {
  final String             sessionId;
  final ApprovalDialogType type;
  const ApprovalDialog({super.key, required this.sessionId, required this.type});

  @override
  State<ApprovalDialog> createState() => _ApprovalDialogState();
}

class _ApprovalDialogState extends State<ApprovalDialog> {
  bool _loading = false;

  bool get _isVault => widget.type == ApprovalDialogType.vaultAccess;

  Future<void> _respond(bool approved) async {
    final l = AppLocalizations.of(context)!;

    if (approved) {
      final reason = _isVault
          ? l.reasonApproveVaultAccess
          : l.reasonApproveAdminLogin;

      final ok = await BiometricService.authenticate(reason: reason);
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.errorApprovalCancelled)),
          );
        }
        return;
      }
    }

    setState(() => _loading = true);
    try {
      final token = await AuthService.getToken();
      if (token == null) return;
      if (_isVault) {
        await ApiService().respondVaultAuth(token, widget.sessionId, approved);
      } else {
        await ApiService().respondAdminSession(token, widget.sessionId, approved);
      }
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _isVault ? Icons.lock_open_rounded : Icons.admin_panel_settings,
            color: _isVault ? Colors.cyanAccent : Colors.orangeAccent,
          ),
          const SizedBox(width: 10),
          Text(_isVault ? l.titleVaultAdminAccess : l.titleAdminLogin),
        ],
      ),
      content: Text(
        _isVault ? l.bodyVaultAdminAccessRequest : l.bodyAdminLoginRequest,
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => _respond(false),
          child: Text(l.btnDeny, style: const TextStyle(color: Colors.redAccent)),
        ),
        ElevatedButton(
          onPressed: _loading ? null : () => _respond(true),
          child: _loading
              ? const SizedBox(
                  height: 16, width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l.btnApprove),
        ),
      ],
    );
  }
}
