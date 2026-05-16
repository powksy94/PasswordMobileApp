import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart' as pc;

class AdminPasswordService {
  static final _storage = const FlutterSecureStorage();
  static const _adminKey = 'adminPassword';
  static const _teamAdminKey = 'teamAdminPassword';

  static String _hash(String input) {
    final bytes = Uint8List.fromList(utf8.encode(input));
    final digest = pc.SHA256Digest().process(bytes);
    return base64Encode(digest);
  }

  // Admin password
  static Future<bool> hasPassword() async =>
      (await _storage.read(key: _adminKey)) != null;

  static Future<bool> verifyPassword(String input) async {
    final stored = await _storage.read(key: _adminKey);
    return stored != null && stored == _hash(input);
  }

  static Future<void> setPassword(String password) async =>
      await _storage.write(key: _adminKey, value: _hash(password));

  // Team Admin password
  static Future<bool> hasTeamAdminPassword() async =>
      (await _storage.read(key: _teamAdminKey)) != null;

  static Future<bool> verifyTeamAdminPassword(String input) async {
    final stored = await _storage.read(key: _teamAdminKey);
    return stored != null && stored == _hash(input);
  }

  static Future<void> setTeamAdminPassword(String password) async =>
      await _storage.write(key: _teamAdminKey, value: _hash(password));
}
