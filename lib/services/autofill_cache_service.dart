import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/vault_item.dart';

class AutofillCacheService {
  static const _channel = MethodChannel('autofill_cache');

  static Future<void> update(List<VaultItem> items) async {
    final entries = items
        .where((e) => e.url.isNotEmpty)
        .map((e) => {
              'url':      e.url,
              'login':    e.login,
              'password': e.password,
            })
        .toList();
    await _channel.invokeMethod('update', {'entries': jsonEncode(entries)});
  }

  static Future<void> clear() async {
    await _channel.invokeMethod('clear');
  }
}
