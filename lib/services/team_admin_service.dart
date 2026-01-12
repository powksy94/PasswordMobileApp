import 'package:flutter/material.dart';
import 'role_manager.dart';

class TeamAdminProvider extends ChangeNotifier {
  final RoleManager roleManager;
  bool _isTeamAdmin = false;

  TeamAdminProvider({required this.roleManager});

  bool get isTeamAdmin => _isTeamAdmin;

  void activateTeamAdmin() {
    _isTeamAdmin = true;
    roleManager.setRole(UserRole.teamAdmin);
    notifyListeners();
  }

  void deactivateTeamAdmin() {
    _isTeamAdmin = false;
    roleManager.setRole(UserRole.user);
    notifyListeners();
  }

  void refreshActivity() {
    if (_isTeamAdmin) notifyListeners();
  }
}
