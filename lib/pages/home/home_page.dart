import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../vault/vault_page.dart';
import '../generator/password_generator_page.dart';
import '../../widgets/neon_text.dart';
import '../../services/admin_provider.dart';
import '../../services/team_admin_provider.dart';
import '../admin/secure_admin_page.dart';

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
  late AdminProvider adminProvider;
  late TeamAdminProvider teamAdminProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    adminProvider = Provider.of<AdminProvider>(context);
    teamAdminProvider = Provider.of<TeamAdminProvider>(context);

    // Listener admin
    adminProvider.addListener(() {
      if (!mounted) return;
      if (!adminProvider.isAdmin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🔒 Session admin expirée")),
        );
      }
    });

    // Listener team admin
    teamAdminProvider.addListener(() {
      if (!mounted) return;
      if (!teamAdminProvider.isTeamAdmin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🔒 Session Team Admin expirée")),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.currentThemeMode == ThemeMode.dark;

    return GestureDetector(
      onTap: () {},
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: NeonText(
            text: _index == 0 ? "Générateur" : "Vault",
            fontSize: 22,
            color: isDark ? Colors.cyanAccent : Colors.blueAccent,
            glow: true,
          ),
          actions: [
            // Icône Admin
            if (adminProvider.isAdmin)
              IconButton(
                icon: Icon(
                  Icons.shield,
                  color: isDark ? Colors.cyanAccent : Colors.blueAccent,
                  size: 26,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SecureAdminPage()),
                  );
                },
              ),

            // Icône Team Admin
            if (teamAdminProvider.isTeamAdmin)
              IconButton(
                icon: Icon(
                  Icons.verified_user,
                  color: isDark ? Colors.orangeAccent : Colors.deepOrange,
                  size: 26,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SecureAdminPage()),
                  );
                },
              ),

            Row(
              children: [
                Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: isDark ? Colors.cyanAccent : Colors.blueAccent,
                ),
                Switch(
                  value: isDark,
                  onChanged: widget.onThemeToggle,
                  activeThumbColor: Colors.cyanAccent,
                  inactiveThumbColor: Colors.blueAccent,
                  activeTrackColor: Colors.cyanAccent.withValues(alpha:0.4),
                  inactiveTrackColor: Colors.blueAccent.withValues(alpha:0.4),
                ),
              ],
            ),
          ],
        ),

       body: IndexedStack(
        index: _index,
        children: [
          PasswordGeneratorPage(
            onVaultUpdated: () {
              setState(() {});   // Rafraîchit la Home, donc VaultPage aussi
            },
          ),
          const VaultPage(),
        ],
      ),


        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: isDark ? Colors.cyanAccent : Colors.blueAccent,
          unselectedItemColor:
              isDark ? Colors.white54 : Colors.black45,
          type: BottomNavigationBarType.fixed,
          onTap: (i) {
            setState(() => _index = i);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.password),
              label: "Générateur",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lock),
              label: "Vault",
            ),
          ],
        ),
      ),
    );
  }
}
