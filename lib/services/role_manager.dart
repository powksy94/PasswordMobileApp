import 'package:flutter/material.dart';

enum UserRole {
  user,
  admin,
  teamAdmin,
}

class RoleManager extends ChangeNotifier {
  UserRole currentRole = UserRole.user;

  void setRole(UserRole role) {
    currentRole = role;
    notifyListeners();
  }

  /// Utilisé par AdminProvider
  void setAdmin(bool value) {
    currentRole = value ? UserRole.admin : UserRole.user;
    notifyListeners();
  }

  /// Utilisé par TeamAdminProvider
  void setTeamAdmin(bool value) {
    currentRole = value ? UserRole.teamAdmin : UserRole.user;
    notifyListeners();
  }

  bool get isAdmin => currentRole == UserRole.admin;
  bool get isTeamAdmin => currentRole == UserRole.teamAdmin;
}
