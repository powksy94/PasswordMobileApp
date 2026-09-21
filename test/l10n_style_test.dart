import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Style guard: user-visible texts use a plain hyphen "-", never
/// the em dash (U+2014).
void main() {
  for (final locale in ['fr', 'en', 'es']) {
    test('app_$locale.arb contains no em dash', () {
      final lines = File('lib/l10n/app_$locale.arb').readAsLinesSync();
      final offenders = <String>[
        for (var i = 0; i < lines.length; i++)
          if (lines[i].contains(String.fromCharCode(0x2014))) 'line ${i + 1}: ${lines[i].trim()}',
      ];
      expect(offenders, isEmpty, reason: offenders.join('\n'));
    });
  }
}
