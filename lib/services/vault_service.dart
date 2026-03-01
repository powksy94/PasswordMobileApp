// lib/services/vault_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'crypto_service.dart';
import '../models/vault_item.dart';
import 'auth_service.dart';
import 'package:uuid/uuid.dart';

class VaultService {
  static final _api = ApiService();
  static final _storage = const FlutterSecureStorage();
  static final _uuid = Uuid();

  /// Charge le vault depuis le serveur, décrypte les champs via la clé en mémoire
  static Future<List<VaultItem>> loadFromServer() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("Non authentifié");

    final raw = await _api.getVault(token);
    final key = AuthService.getMasterKey();
    if (key == null) throw Exception("Master key absente - demande le mot de passe maître");

    final List<VaultItem> out = [];
    for (final r in raw) {
      // r contient les champs chiffrés : title, login, password, notes
      try {
        final title = CryptoService.decryptText(r['title'] as String, key);
        final login = r['login'] != null ? CryptoService.decryptText(r['login'] as String, key) : '';
        final password = CryptoService.decryptText(r['password'] as String, key);
        final notes = r['notes'] != null ? CryptoService.decryptText(r['notes'] as String, key) : '';

        out.add(VaultItem(
          id: r['id'] as String,
          label: title,
          login: login,
          password: password,
          notes: notes,
          icon: r['icon'] as String? ?? 'lock',
        ));
      } catch (e) {
        debugPrint("Erreur decrypt item ${r['id']}: $e");
        // skip or keep encrypted payload as fallback
      }
    }

    return out;
  }

  /// Ajoute un item (chiffre côté client puis envoi)
  static Future<void> addToServer({
    required String label,
    required String password,
    String login = '',
    String notes = '',
    String icon = 'lock',
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("Non authentifié");
    final key = AuthService.getMasterKey();
    if (key == null) throw Exception("Master key absente - demande le mot de passe maître");

    final id = _uuid.v4();

    final payload = {
      'id': id,
      'title': CryptoService.encryptText(label, key),
      'login': login.isNotEmpty ? CryptoService.encryptText(login, key) : '',
      'password': CryptoService.encryptText(password, key),
      'notes': notes.isNotEmpty ? CryptoService.encryptText(notes, key) : '',
      'icon': icon,
    };

    await _api.addItem(token, payload);
  }

  /// Supprime item côté serveur
  static Future<void> deleteFromServer(String id) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("Non authentifié");
    await _api.deleteItem(token, id);
  }

  // --- Local helpers (fallback) ---
  // Tu peux garder le stockage local pour offline. Ici un exemple simple :
  static Future<void> writeLocal({
    required String id,
    required String label,
    required String password,
    String notes = '',
    String icon = 'lock',
  }) async {
    final jsonString = jsonEncode({
      'label': label,
      'password': password,
      'notes': notes,
      'icon': icon,
    });
    await _storage.write(key: id, value: jsonString);
  }

  static Future<Map<String, dynamic>?> readLocal(String id) async {
    final s = await _storage.read(key: id);
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  static Future<List<String>> listLocalIds() async {
    final all = await _storage.readAll();
    return all.keys.toList();
  }

  static Future<void> deleteLocal(String id) async {
    await _storage.delete(key: id);
  }

  /// Convertit un nom d'icône (string) en IconData
  static IconData getVaultIcon(String iconName) {
    switch (iconName) {
      case 'email':
        return Icons.email;
      case 'wifi':
        return Icons.wifi;
      case 'credit_card':
        return Icons.credit_card;
      case 'person':
        return Icons.person;
      case 'vpn_key':
        return Icons.vpn_key;
      case 'phone':
        return Icons.phone;
      case 'computer':
        return Icons.computer;
      case 'cloud':
        return Icons.cloud;
      case 'lock':
      default:
        return Icons.lock;
    }
  }
}
