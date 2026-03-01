import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/role_manager.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import 'change_admin_password_page.dart';
import 'change_team_admin_password_page.dart';

class SecureAdminPage extends StatefulWidget {
  const SecureAdminPage({super.key});

  @override
  State<SecureAdminPage> createState() => _SecureAdminPageState();
}

class _SecureAdminPageState extends State<SecureAdminPage>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>>? _users;
  bool _loadingUsers = false;
  String? _usersError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUsersIfAdmin());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadUsersIfAdmin() async {
    final roleManager = Provider.of<RoleManager>(context, listen: false);
    if (!roleManager.isAdmin) return;

    setState(() {
      _loadingUsers = true;
      _usersError = null;
    });
    try {
      final token = await AuthService.getToken();
      if (token == null) return;
      final raw = await ApiService().getAllUsers(token);
      if (mounted) {
        setState(() => _users = raw.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      if (mounted) setState(() => _usersError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingUsers = false);
    }
  }

  Future<void> _updateRole(String userId, String newRole) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;
      await ApiService().updateUserRole(token, userId, newRole);
      await _loadUsersIfAdmin();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleManager = Provider.of<RoleManager>(context);

    if (!roleManager.isAdmin && !roleManager.isTeamAdmin) {
      Future.microtask(() {
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isAdmin ? 'Bienvenue Admin' : 'Bienvenue Team Admin',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),

            // --- Mots de passe ---
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangeAdminPasswordPage()),
              ),
              child: const Text('Changer mot de passe Admin'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangeTeamAdminPasswordPage()),
              ),
              child: const Text('Changer mot de passe Team Admin'),
            ),

            // --- Gestion des utilisateurs (admin uniquement) ---
            if (isAdmin) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Utilisateurs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadUsersIfAdmin,
                    tooltip: 'Actualiser',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_loadingUsers)
                const Center(child: CircularProgressIndicator()),
              if (_usersError != null)
                Text(
                  'Erreur : $_usersError',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              if (_users != null)
                ..._users!.map((user) {
                  final String userId = user['id'].toString();
                  final String email = user['email']?.toString() ?? '';
                  final String currentRole = user['role']?.toString() ?? 'user';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(email, overflow: TextOverflow.ellipsis),
                      subtitle: Text(currentRole),
                      trailing: DropdownButton<String>(
                        value: ['admin', 'user', 'team_admin'].contains(currentRole)
                            ? currentRole
                            : 'user',
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('User')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          DropdownMenuItem(value: 'team_admin', child: Text('Team Admin')),
                        ],
                        onChanged: (newRole) {
                          if (newRole != null && newRole != currentRole) {
                            _updateRole(userId, newRole);
                          }
                        },
                      ),
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }
}
