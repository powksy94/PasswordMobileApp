import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminPasswordService {
  static final _storage = const FlutterSecureStorage();
  static const _adminKey = 'adminPassword';
  static const _teamAdminKey = 'teamAdminPassword';

  // Mot de passe admin
  static Future<String?> getPassword() async => await _storage.read(key: _adminKey);

  static Future<void> setPassword(String password) async =>
      await _storage.write(key: _adminKey, value: password);

  // Vérification Team Admin
  static Future<bool> verifyTeamAdminPassword(String input) async {
    final stored = await _storage.read(key: _teamAdminKey);
    return stored == input;
  }

  static Future<void> setTeamAdminPassword(String password) async =>
      await _storage.write(key: _teamAdminKey, value: password);
}
