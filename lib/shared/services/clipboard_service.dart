import 'package:flutter/services.dart';
import '../../features/settings/services/settings_service.dart';

/// Copies a text to the clipboard, then schedules its clearing
/// after the delay configured in the privacy settings.
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
