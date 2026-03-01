import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Pages
import 'pages/auth/login_page.dart';
import 'pages/auth/signup_page.dart';
import 'pages/home/home_page.dart';
import 'pages/vault/vault_page.dart';
import 'pages/generator/password_generator_page.dart';
import 'pages/admin/secure_admin_page.dart';

// Theme
import 'theme/app_theme.dart';

// Providers & Services
import 'services/admin_provider.dart';
import 'services/role_manager.dart';
import 'services/team_admin_provider.dart';
import 'services/auth_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoleManager()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => TeamAdminProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    // Restore backend role from secure storage when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreRole());
  }

  Future<void> _restoreRole() async {
    final roleStr = await AuthService.getUserRoleString();
    if (!mounted) return;
    final roleManager = Provider.of<RoleManager>(context, listen: false);
    if (roleStr == 'admin') {
      roleManager.setRole(UserRole.admin);
      Provider.of<AdminProvider>(context, listen: false).activateAdmin();
    } else if (roleStr == 'team_admin') {
      roleManager.setRole(UserRole.teamAdmin);
      Provider.of<TeamAdminProvider>(context, listen: false).setTeamAdmin(true);
    }
  }

  void changeTheme(bool isDark) {
    setState(() {
      themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔗 Synchronisation des providers avec RoleManager
    final roleManager = Provider.of<RoleManager>(context, listen: false);

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    adminProvider.attachRoleManager(roleManager);

    final teamAdminProvider = Provider.of<TeamAdminProvider>(context, listen: false);
    teamAdminProvider.updateRoleManager(roleManager);

    return MaterialApp(
      title: 'Password Mobile App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => HomePage(
              onThemeToggle: changeTheme,
              currentThemeMode: themeMode,
            ),
        '/vault': (context) => const VaultPage(),
        '/generator': (context) => const PasswordGeneratorPage(),
        '/admin': (context) => const SecureAdminPage(),
      },
    );
  }
}
