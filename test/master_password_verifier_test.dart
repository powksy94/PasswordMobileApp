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
    test('matches quand la clé déchiffre le coffre', () {
      final key = _key(1);
      expect(MasterPasswordVerifier.probe(_vaultFor(key), key), MasterPasswordCheck.matches);
    });

    test('mismatch quand la clé est incorrecte', () {
      expect(
        MasterPasswordVerifier.probe(_vaultFor(_key(1)), _key(2)),
        MasterPasswordCheck.mismatch,
      );
    });

    test('unverifiable quand le coffre est vide', () {
      expect(MasterPasswordVerifier.probe([], _key(1)), MasterPasswordCheck.unverifiable);
    });

    test('matches si au moins un item est lisible (item corrompu ignoré)', () {
      final key = _key(1);
      final raw = [
        {'id': 'bad', 'title': 'pas-du-json'},
        ..._vaultFor(key, items: 1),
      ];
      expect(MasterPasswordVerifier.probe(raw, key), MasterPasswordCheck.matches);
    });

    test('mismatch quand tous les items sont corrompus', () {
      final raw = [
        {'id': 'a', 'title': 'x'},
        {'id': 'b'},
      ];
      expect(MasterPasswordVerifier.probe(raw, _key(1)), MasterPasswordCheck.mismatch);
    });
  });
}
