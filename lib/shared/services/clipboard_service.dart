import 'package:flutter/services.dart';
import '../../features/settings/services/settings_service.dart';

/// Copie un texte dans le presse-papiers puis programme son effacement
/// après le délai configuré dans les réglages de confidentialité.
class ClipboardService {
  static Future<void> copyAndScheduleClear(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    final seconds = await SettingsService.getClipboardClearSeconds();
    Future.delayed(Duration(seconds: seconds), () async {
      final data = await Clipboard.getData('text/plain');
      if (data?.text == text) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    });
  }
}
