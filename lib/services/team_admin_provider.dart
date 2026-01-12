import 'package:flutter/material.dart';
import 'role_manager.dart';

class TeamAdminProvider extends ChangeNotifier {
  RoleManager? _roleManager;
  bool _isTeamAdmin = false;

  bool get isTeamAdmin => _isTeamAdmin;

  // Attacher RoleManager
  void updateRoleManager(RoleManager manager) {
    _roleManager = manager;
  }

  Future<void> setTeamAdmin(bool value) async {
    _isTeamAdmin = value;
    _roleManager?.setTeamAdmin(value);
    notifyListeners();
  }

  // 🔥 Méthode refreshActivity appelée dans HomePage
  void refreshActivity() {
    notifyListeners();
  }
}
