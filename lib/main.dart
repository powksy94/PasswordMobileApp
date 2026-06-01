import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Pages
import 'pages/auth/login_page.dart';
import 'pages/auth/signup_page.dart';
import 'pages/auth/signup_success_page.dart';
import 'pages/auth/lock_screen.dart';
import 'pages/home/home_page.dart';
import 'pages/vault/vault_page.dart';
import 'pages/generator/password_generator_page.dart';
import 'pages/settings/account_settings_page.dart';

// Theme & widgets
import 'theme/app_theme.dart';
import 'widgets/auth/splash_auth_gate.dart';

// Services
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/role_provider.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
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

  static const _lockTimeout = Duration(minutes: 5);
  final _navigatorKey = GlobalKey<NavigatorState>();

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

  void changeTheme(bool isDark) =>
      setState(() => themeMode = isDark ? ThemeMode.dark : ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:                     'Password Mobile App',
      debugShowCheckedModeBanner: false,
      theme:                     AppTheme.lightTheme,
      darkTheme:                 AppTheme.darkTheme,
      themeMode:                 themeMode,
      navigatorKey:              _navigatorKey,
      initialRoute: '/splash',
      routes: {
        '/splash':    (_) => const SplashAuthGate(),
        '/login':     (_) => const LoginPage(),
        '/signup':         (_) => const SignupPage(),
        '/signup-success': (_) => const SignupSuccessPage(),
        '/lock':      (_) => const LockScreen(),
        '/home':      (_) => HomePage(
              onThemeToggle:    changeTheme,
              currentThemeMode: themeMode,
            ),
        '/vault':     (_) => const VaultPage(),
        '/generator': (_) => const PasswordGeneratorPage(),
        '/settings':  (_) => const AccountSettingsPage(),
      },
    );
  }
}
