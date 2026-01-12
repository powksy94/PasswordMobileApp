import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'role_manager.dart';

class AdminProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  bool _isAdmin = false;
  RoleManager? _roleManager;

  bool get isAdmin => _isAdmin;

  // Attacher RoleManager pour pouvoir synchroniser le rôle
  void attachRoleManager(RoleManager manager) {
    _roleManager = manager;
  }

  Future<void> loadAdminStatus() async {
    final value = await _storage.read(key: 'isAdmin');
    _isAdmin = value == 'true';
    _roleManager?.setAdmin(_isAdmin);
    notifyListeners();
  }

  Future<void> activateAdmin() async {
    _isAdmin = true;
    await _storage.write(key: 'isAdmin', value: 'true');
    _roleManager?.setAdmin(true);
    notifyListeners();
  }

  Future<void> deactivateAdmin() async {
    _isAdmin = false;
    await _storage.delete(key: 'isAdmin');
    _roleManager?.setAdmin(false);
    notifyListeners();
  }
}
