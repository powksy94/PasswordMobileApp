// lib/services/vault_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'crypto_service.dart';
import '../models/vault_item.dart';
import 'auth_service.dart';
import 'package:uuid/uuid.dart';

class VaultService {
  static final _api  = ApiService();
  static final _uuid = Uuid();
  static const _cacheKey = 'vault_cache_raw';

  // ── Cache offline ─────────────────────────────────────────────────────────

  static Future<void> _saveCache(List<dynamic> raw) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(raw));
  }

  static Future<List<dynamic>?> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_cacheKey);
    if (s == null) return null;
    return jsonDecode(s) as List<dynamic>;
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  // ── Déchiffrement d'un payload brut serveur ───────────────────────────────

  static List<VaultItem> _decryptRaw(List<dynamic> raw, Uint8List key) {
    final out = <VaultItem>[];
    for (final r in raw) {
      try {
        final title    = CryptoService.decryptText(r['title'] as String, key);
        final rawLogin = r['login'];
        final login    = (rawLogin is String && rawLogin.isNotEmpty)
            ? CryptoService.decryptText(rawLogin, key)
            : '';
        final password = CryptoService.decryptText(r['password'] as String, key);
        final rawNotes = r['notes'];
        final notes    = (rawNotes is String && rawNotes.isNotEmpty)
            ? CryptoService.decryptText(rawNotes, key)
            : '';
        out.add(VaultItem(
          id:       r['id'] as String,
          label:    title,
          login:    login,
          password: password,
          notes:    notes,
          icon:     r['icon'] as String? ?? 'lock',
        ));
      } catch (e) {
        debugPrint('Erreur decrypt item ${r['id']}: $e');
      }
    }
    return out;
  }

  // ── Chargement (réseau → cache en cas d'échec) ────────────────────────────

  /// Retourne les items et un flag [fromCache] indiquant si les données viennent du cache.
  static Future<({List<VaultItem> items, bool fromCache})> loadFromServer() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Non authentifié');
    final key = AuthService.getMasterKey();
    if (key == null) throw Exception('Master key absente — déverrouillez le vault');

    try {
      final raw = await _api.getVault(token);
      await _saveCache(raw);
      return (items: _decryptRaw(raw, key), fromCache: false);
    } catch (_) {
      final cached = await _loadCache();
      if (cached == null) rethrow;
      return (items: _decryptRaw(cached, key), fromCache: true);
    }
  }

  // ── Écriture ──────────────────────────────────────────────────────────────

  static Future<void> addToServer({
    required String label,
    required String password,
    String login = '',
    String notes = '',
    String icon  = 'lock',
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Non authentifié');
    final key = AuthService.getMasterKey();
    if (key == null) throw Exception('Master key absente');

    await _api.addItem(token, {
      'id':       _uuid.v4(),
      'title':    CryptoService.encryptText(label, key),
      'login':    login.isNotEmpty ? CryptoService.encryptText(login, key) : '',
      'password': CryptoService.encryptText(password, key),
      'notes':    notes.isNotEmpty ? CryptoService.encryptText(notes, key) : '',
      'icon':     icon,
    });
  }

  static Future<void> updateOnServer({
    required String id,
    required String label,
    required String password,
    String login = '',
    String notes = '',
    String icon  = 'lock',
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Non authentifié');
    final key = AuthService.getMasterKey();
    if (key == null) throw Exception('Master key absente');

    await _api.updateItem(token, id, {
      'title':    CryptoService.encryptText(label, key),
      'login':    login.isNotEmpty ? CryptoService.encryptText(login, key) : '',
      'password': CryptoService.encryptText(password, key),
      'notes':    notes.isNotEmpty ? CryptoService.encryptText(notes, key) : '',
      'icon':     icon,
    });
  }

  static Future<void> deleteFromServer(String id) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Non authentifié');
    await _api.deleteItem(token, id);
  }

  // ── Icônes ────────────────────────────────────────────────────────────────

  static IconData getVaultIcon(String iconName) {
    switch (iconName) {
      case 'email':       return Icons.email;
      case 'wifi':        return Icons.wifi;
      case 'credit_card': return Icons.credit_card;
      case 'person':      return Icons.person;
      case 'vpn_key':     return Icons.vpn_key;
      case 'phone':       return Icons.phone;
      case 'computer':    return Icons.computer;
      case 'cloud':       return Icons.cloud;
      default:            return Icons.lock;
    }
  }
}
