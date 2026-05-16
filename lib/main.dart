import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Pages
import 'pages/auth/login_page.dart';
import 'pages/auth/signup_page.dart';
import 'pages/auth/lock_screen.dart';
import 'pages/home/home_page.dart';
import 'pages/vault/vault_page.dart';
import 'pages/generator/password_generator_page.dart';
import 'pages/admin/secure_admin_page.dart';
import 'pages/settings/account_settings_page.dart';

// Theme & widgets
import 'theme/app_theme.dart';
import 'widgets/auth/splash_auth_gate.dart';

// Services
import 'services/role_provider.dart';
import 'services/auth_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => RoleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ThemeMode themeMode = ThemeMode.dark;
  DateTime? _pausedAt;

  static const _lockTimeout  = Duration(minutes: 5);
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreRole());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ── Cycle de vie ─────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final paused = _pausedAt;
      _pausedAt = null;
      if (paused != null && AuthService.getMasterKey() != null) {
        final elapsed = DateTime.now().difference(paused);
        if (elapsed > _lockTimeout) {
          AuthService.clearMasterKey();
          _navigatorKey.currentState
              ?.pushNamedAndRemoveUntil('/lock', (r) => false);
        }
      }
    }
  }

  // ── Restauration du rôle au démarrage ────────────────────────────────────

  Future<void> _restoreRole() async {
    final roleStr = await AuthService.getUserRoleString();
    if (!mounted) return;
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);
    switch (roleStr) {
      case 'admin':
        roleProvider.setRole(UserRole.admin);
      case 'team_admin':
        roleProvider.setRole(UserRole.teamAdmin);
      default:
        break;
    }
  }

  void changeTheme(bool isDark) =>
      setState(() => themeMode = isDark ? ThemeMode.dark : ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:                    'Password Mobile App',
      debugShowCheckedModeBanner: false,
      theme:                    AppTheme.lightTheme,
      darkTheme:                AppTheme.darkTheme,
      themeMode:                themeMode,
      navigatorKey:             _navigatorKey,
      initialRoute: '/splash',
      routes: {
        '/splash':    (_) => const SplashAuthGate(),
        '/login':     (_) => const LoginPage(),
        '/signup':    (_) => const SignupPage(),
        '/lock':      (_) => const LockScreen(),
        '/home':      (_) => HomePage(
              onThemeToggle:    changeTheme,
              currentThemeMode: themeMode,
            ),
        '/vault':     (_) => const VaultPage(),
        '/generator': (_) => const PasswordGeneratorPage(),
        '/admin':     (_) => const SecureAdminPage(),
        '/settings':  (_) => const AccountSettingsPage(),
      },
    );
  }
}
