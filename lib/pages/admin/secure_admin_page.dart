import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/role_manager.dart';
import 'change_admin_password_page.dart';
import 'change_team_admin_password_page.dart';

class SecureAdminPage extends StatefulWidget {
  const SecureAdminPage({super.key});

  @override
  State<SecureAdminPage> createState() => _SecureAdminPageState();
}

class _SecureAdminPageState extends State<SecureAdminPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleManager = Provider.of<RoleManager>(context);

    // ❗ Évite la redirection prématurée (bug original)
    if (!roleManager.isAdmin && !roleManager.isTeamAdmin) {
      Future.microtask(() {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
      return const SizedBox.shrink();
    }

    final bool isAdmin = roleManager.isAdmin;
    final bool isTeamAdmin = roleManager.isTeamAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        actions: [
          if (isAdmin)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.shield, color: Colors.amberAccent),
            ),
          if (isTeamAdmin)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.play_arrow, color: Colors.greenAccent),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isAdmin
                  ? 'Bienvenue Admin'
                  : 'Bienvenue Team Admin (Playstore)',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: (isTeamAdmin || isAdmin)
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ChangeAdminPasswordPage()),
                      );
                    }
                  : null,
              child: const Text('Changer mot de passe Admin'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: (isTeamAdmin || isAdmin)
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const ChangeTeamAdminPasswordPage()),
                      );
                    }
                  : null,
              child: const Text('Changer mot de passe Team Admin'),
            ),
          ],
        ),
      ),
    );
  }
}
