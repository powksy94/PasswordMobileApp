import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  bool _isAdmin = false;
  Timer? _logoutTimer;

  bool get isAdmin => _isAdmin;

  /// Charger l'état admin depuis le stockage, timeout intégré
  Future<void> loadAdminStatus() async {
    try {
      final value = await _storage.read(key: 'isAdmin').timeout(
        const Duration(seconds: 1),
        onTimeout: () => 'false',
      );
      _isAdmin = value == 'true';
      if (_isAdmin) _startLogoutTimer();
      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ loadAdminStatus error: $e");
      _isAdmin = false;
      notifyListeners();
    }
  }

  /// Activation admin
  Future<void> activateAdmin() async {
    _isAdmin = true;
    try {
      await _storage.write(key: 'isAdmin', value: 'true').timeout(const Duration(seconds: 1));
    } catch (_) {}
    _startLogoutTimer();
    notifyListeners();
  }

  /// Désactivation admin
  Future<void> deactivateAdmin() async {
    _isAdmin = false;
    _logoutTimer?.cancel();
    try {
      await _storage.delete(key: 'isAdmin').timeout(const Duration(seconds: 1));
    } catch (_) {}
    notifyListeners();
  }

  /// Reset du timer admin
  void refreshActivity() {
    if (_isAdmin) _startLogoutTimer();
  }

  void _startLogoutTimer() {
    _logoutTimer?.cancel();
    _logoutTimer = Timer(const Duration(minutes: 5), () async {
      _isAdmin = false;
      try {
        await _storage.delete(key: 'isAdmin').timeout(const Duration(seconds: 1));
      } catch (_) {}
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _logoutTimer?.cancel();
    super.dispose();
  }
}
