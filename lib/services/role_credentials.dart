class RoleCredentials {
  static String teamAdminPassword = "team123";

  static Future<void> updateTeamAdminPassword(String newPassword) async {
    teamAdminPassword = newPassword;
  }
}
