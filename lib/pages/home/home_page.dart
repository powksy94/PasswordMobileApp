import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../vault/vault_page.dart';
import '../vault/password_health_page.dart';
import '../generator/password_generator_page.dart';
import '../admin/secure_admin_page.dart';
import '../../widgets/common/neon_text.dart';
import '../../services/role_provider.dart';
import '../../services/auth_service.dart';

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

  late RoleProvider _roleProvider;
  UserRole?         _prevRole;
  VoidCallback?     _roleListener;
  bool _listenerAdded = false;

  static const _titles = ['Générateur', 'Vault', 'Santé'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _roleProvider = Provider.of<RoleProvider>(context);

    if (!_listenerAdded) {
      _listenerAdded = true;
      _prevRole      = _roleProvider.role;
      _roleListener  = () {
        if (!mounted) return;
        final current = _roleProvider.role;
        if (_prevRole != UserRole.user && current == UserRole.user) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🔒 Session expirée')),
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

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await AuthService.logout();
    if (!mounted) return;
    Provider.of<RoleProvider>(context, listen: false).deactivate();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = widget.currentThemeMode == ThemeMode.dark;
    final accent  = isDark ? Colors.cyanAccent : Colors.blueAccent;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: NeonText(
          text: _titles[_index], fontSize: 22, color: accent, glow: true),
        actions: [
          if (_roleProvider.isAdmin)
            IconButton(
              icon: Icon(Icons.shield, color: accent, size: 26),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SecureAdminPage())),
            ),
          if (_roleProvider.isTeamAdmin)
            IconButton(
              icon: Icon(Icons.verified_user,
                  color: isDark ? Colors.orangeAccent : Colors.deepOrange,
                  size: 26),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SecureAdminPage())),
            ),
          Row(
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
              if (v == 'logout')   _logout();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'settings',
                child: Row(children: [
                  Icon(Icons.manage_accounts, size: 20),
                  SizedBox(width: 10),
                  Text('Paramètres du compte'),
                ]),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(children: [
                  Icon(Icons.logout, size: 20, color: Colors.redAccent),
                  SizedBox(width: 10),
                  Text('Déconnexion',
                      style: TextStyle(color: Colors.redAccent)),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          PasswordGeneratorPage(onVaultUpdated: () => setState(() {})),
          const VaultPage(),
          const PasswordHealthPage(),
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
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.password), label: 'Générateur'),
          BottomNavigationBarItem(icon: Icon(Icons.lock), label: 'Vault'),
          BottomNavigationBarItem(
              icon: Icon(Icons.health_and_safety), label: 'Santé'),
        ],
      ),
    );
  }
}
