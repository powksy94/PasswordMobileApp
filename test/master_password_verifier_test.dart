import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_mobile_app/features/auth/services/master_password_verifier.dart';
import 'package:password_mobile_app/shared/services/crypto_service.dart';

Uint8List _key(int seed) => Uint8List.fromList(List.generate(32, (i) => (i + seed) % 256));

List<dynamic> _vaultFor(Uint8List key, {int items = 2}) => List.generate(
      items,
      (i) => {'id': '$i', 'title': CryptoService.encryptText('item $i', key)},
    );

void main() {
  group('MasterPasswordVerifier.probe', () {
    test('matches when the key decrypts the vault', () {
      final key = _key(1);
      expect(MasterPasswordVerifier.probe(_vaultFor(key), key), MasterPasswordCheck.matches);
    });

    test('mismatch when the key is incorrect', () {
      expect(
        MasterPasswordVerifier.probe(_vaultFor(_key(1)), _key(2)),
        MasterPasswordCheck.mismatch,
      );
    });

    test('unverifiable when the vault is empty', () {
      expect(MasterPasswordVerifier.probe([], _key(1)), MasterPasswordCheck.unverifiable);
    });

    test('matches if at least one item is readable (corrupted item ignored)', () {
      final key = _key(1);
      final raw = [
        {'id': 'bad', 'title': 'not-json'},
        ..._vaultFor(key, items: 1),
      ];
      expect(MasterPasswordVerifier.probe(raw, key), MasterPasswordCheck.matches);
    });

    test('mismatch when all items are corrupted', () {
      final raw = [
        {'id': 'a', 'title': 'x'},
        {'id': 'b'},
      ];
      expect(MasterPasswordVerifier.probe(raw, _key(1)), MasterPasswordCheck.mismatch);
    });
  });
}
