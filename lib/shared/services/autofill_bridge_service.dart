import 'package:flutter/services.dart';

/// Bridges VaultAutofillService's "generate a new password" flow (native,
/// see upgrade/ANDROID_AUTOFILL_SUGGESTION.md) to Dart. Separate from
/// [AutofillCacheService]: a different concern (driving this launch's
/// result and reading a one-shot pending save, not syncing the
/// existing-credential cache).
class AutofillBridgeService {
  static const _channel = MethodChannel('autofill_bridge');

  /// True if this app launch is the authentication step for a "generate a
  /// new password" autofill suggestion, rather than a normal app open.
  static Future<bool> isGenerateMode() async {
    try {
      return await _channel.invokeMethod<bool>('checkGenerateMode') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Hands the generated password back to Android, which fills it into the
  /// third-party app's field and closes this screen.
  static Future<void> completeGenerate(String password) async {
    try {
      await _channel.invokeMethod('completeGenerate', {'password': password});
    } catch (_) {
      // Nothing more we can do from here; the native side simply won't
      // produce a suggestion value if this fails.
    }
  }

  /// The user declined without generating anything (e.g. backed out of the
  /// unlock screen): tells Android there is no suggestion after all.
  static Future<void> cancelGenerate() async {
    try {
      await _channel.invokeMethod('cancelGenerate');
    } catch (_) {}
  }

  /// A generated password queued by `onSaveRequest`, awaiting confirmation,
  /// or `null` if none. Consumed: a second call right after returns `null`.
  static Future<({String domain, String password})?> consumePendingSave() async {
    try {
      final result = await _channel.invokeMethod<Map>('consumePendingSave');
      if (result == null) return null;
      return (
        domain:   result['domain'] as String,
        password: result['password'] as String,
      );
    } catch (_) {
      return null;
    }
  }
}
