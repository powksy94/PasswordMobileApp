import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../vault/vault_page.dart';
import '../vault/password_health_page.dart';
import '../generator/password_generator_page.dart';
import '../../widgets/common/neon_text.dart';
import '../../services/role_provider.dart';
import '../../services/logout_service.dart';
import '../../services/fcm_service.dart';
import '../../l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  final void Function(bool) onThemeToggle;
  final ThemeMode currentThemeMode;

  const HomePage({
    super.key,
    required this.onThemeToggle,
    required this.currentThemeMode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  // GlobalKeys pour accéder aux méthodes publiques des pages d'onglet
  final _vaultKey  = GlobalKey<VaultPageState>();
  final _healthKey = GlobalKey<PasswordHealthPageState>();

  late RoleProvider _roleProvider;
  UserRole?         _prevRole;
  VoidCallback?     _roleListener;
  bool _listenerAdded = false;

  List<String> _pageTitles(AppLocalizations l) => [l.navGenerator, l.navVault, l.navHealth];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _roleProvider = Provider.of<RoleProvider>(context);

    if (!_listenerAdded) {
      _listenerAdded = true;
      FcmService.initialize();
      FcmService.listenForeground(context);
      _prevRole      = _roleProvider.role;
      _roleListener  = () {
        if (!mounted) return;
        final current = _roleProvider.role;
        if (_prevRole != UserRole.user && current == UserRole.user) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.sessionExpired)),
          );
        }
        _prevRole = current;
      };
      _roleProvider.addListener(_roleListener!);
    }
  }

  @override
  void dispose() {
    if (_roleListener != null) {
      _roleProvider.removeListener(_roleListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.currentThemeMode == ThemeMode.dark;
    final accent = isDark ? Colors.cyanAccent : Colors.blueAccent;

    final l      = AppLocalizations.of(context)!;
    final titles = _pageTitles(l);

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: NeonText(
            text: titles[_index], fontSize: 22, color: accent, glow: true),
          actions: [

            // ── Actions spécifiques à chaque onglet ───────────────────────
            if (_index == 1)
              IconButton(
                icon:    const Icon(Icons.add),
                tooltip: l.tooltipAddPassword,
                onPressed: () => _vaultKey.currentState?.openAddPassword(),
              ),
            if (_index == 2)
              IconButton(
                icon:    Icon(Icons.refresh, color: accent),
                tooltip: l.tooltipRefresh,
                onPressed: () => _healthKey.currentState?.refresh(),
              ),

            // ── Thème + menu ─────────────────────────────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: accent),
                Switch(
                  value:              isDark,
                  onChanged:          widget.onThemeToggle,
                  activeThumbColor:   Colors.cyanAccent,
                  inactiveThumbColor: Colors.blueAccent,
                  activeTrackColor:   Colors.cyanAccent.withValues(alpha: 0.4),
                  inactiveTrackColor: Colors.blueAccent.withValues(alpha: 0.4),
                ),
              ],
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: accent),
              onSelected: (v) {
                if (v == 'settings') Navigator.pushNamed(context, '/settings');
                if (v == 'logout')   LogoutService.confirmAndLogout(context);
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'settings',
                  child: Row(children: [
                    const Icon(Icons.manage_accounts, size: 20),
                    const SizedBox(width: 10),
                    Text(l.menuAccountSettings),
                  ]),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(children: [
                    const Icon(Icons.logout, size: 20, color: Colors.redAccent),
                    const SizedBox(width: 10),
                    Text(l.menuLogout,
                        style: const TextStyle(color: Colors.redAccent)),
                  ]),
                ),
              ],
            ),
          ],
        ),

        body: IndexedStack(
          index: _index,
          children: [
            PasswordGeneratorPage(
              onVaultUpdated: () => _vaultKey.currentState?.loadVault(),
            ),
            VaultPage(key: _vaultKey),
            PasswordHealthPage(key: _healthKey),
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex:     _index,
          backgroundColor:  Colors.transparent,
          elevation:        0,
          selectedItemColor:   accent,
          unselectedItemColor: isDark ? Colors.white54 : Colors.black45,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => _index = i),
          items: [
            BottomNavigationBarItem(
                icon: const Icon(Icons.password), label: l.navGenerator),
            BottomNavigationBarItem(
                icon: const Icon(Icons.lock), label: l.navVault),
            BottomNavigationBarItem(
                icon: const Icon(Icons.health_and_safety), label: l.navHealth),
          ],
        ),
      ),
    );
  }
}
