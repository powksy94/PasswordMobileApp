import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persiste une copie chiffrée brute du coffre pour permettre un accès
/// hors-ligne quand le serveur est injoignable ([VaultService.loadFromServer]).
class VaultCache {
  static const _cacheKey = 'vault_cache_raw';

  static Future<void> save(List<dynamic> raw) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(raw));
  }

  static Future<List<dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_cacheKey);
    if (s == null) return null;
    return jsonDecode(s) as List<dynamic>;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
