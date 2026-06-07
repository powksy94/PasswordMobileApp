import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/autofill_cache_service.dart';
import '../../services/api_service.dart';
import '../../services/role_provider.dart';
import '../../widgets/common/neon_text.dart';
import '../../widgets/common/glass_panel.dart';
import '../../widgets/settings/danger_zone_panel.dart';
import '../../widgets/settings/lock_timeout_panel.dart';
import '../../widgets/settings/privacy_settings_panel.dart';
import '../../widgets/settings/vault_data_panel.dart';
import '../../widgets/settings/logout_panel.dart';
import '../../l10n/app_localizations.dart';
import 'change_password_page.dart';
import 'change_master_password_page.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  Future<void> _deleteAccount() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   Text(l.deleteAccountTitle),
        content: Text(l.deleteAccountContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.btnCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text(l.btnDeleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');
      await ApiService().deleteAccount(token);
      if (!mounted) return;
      await _logoutAndRedirect();
    } catch (e) {
      if (mounted) _snack('$e');
    }
  }

  Future<void> _logoutAndRedirect() async {
    await AutofillCacheService.clear();
    await AuthService.fullLogout();
    if (!mounted) return;
    Provider.of<RoleProvider>(context, listen: false).deactivate();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

    return Scaffold(
      appBar: AppBar(
        title: NeonText(
            text: l.titleSettings, fontSize: 20, color: accent, glow: true),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.black, Colors.grey[900]!]
                : [Colors.blueGrey[50]!, Colors.blueGrey[200]!],
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              LockTimeoutPanel(),
              const SizedBox(height: 20),
              const PrivacySettingsPanel(),
              const SizedBox(height: 20),
              const VaultDataPanel(),
              const SizedBox(height: 20),
              GlassPanel(
                width: double.infinity,
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.password),
                  title: Text(l.titleChangePassword),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GlassPanel(
                width: double.infinity,
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
                  title: Text(
                    l.titleChangeMasterPassword,
                    style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.orangeAccent),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangeMasterPasswordPage()),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const LogoutPanel(),
              const SizedBox(height: 20),
              DangerZonePanel(onDelete: _deleteAccount),
            ],
          ),
        ),
      ),
    );
  }
}
