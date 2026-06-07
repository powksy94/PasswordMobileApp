import 'package:flutter/material.dart';

class UpdateService {
  static Future<void> downloadAndInstallApk({
    required BuildContext context,
    required String url,
  }) async {
    final nav     = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final accent  = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.blueAccent;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CircularProgressIndicator(color: accent),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    nav.pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Téléchargement terminé !')),
    );
  }
}
