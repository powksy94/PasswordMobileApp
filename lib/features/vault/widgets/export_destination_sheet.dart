import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../l10n/app_localizations.dart';

enum _ExportDestination { device, share }

/// Lets the user decide where an export written to the app's scratch folder
/// ends up: saved on the phone through the system "Save as" dialog (Storage
/// Access Framework: Downloads or any folder, no storage permission needed),
/// or handed to another app through the share sheet (Drive, email...).
Future<void> deliverExportedFile(BuildContext context, String path) async {
  final l = AppLocalizations.of(context)!;
  final destination = await showModalBottomSheet<_ExportDestination>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(l.titleExportDestination,
                style: Theme.of(sheetContext).textTheme.titleMedium),
          ),
          ListTile(
            leading:  const Icon(Icons.save_alt),
            title:    Text(l.optionExportSaveToDevice),
            subtitle: Text(l.optionExportSaveToDeviceSubtitle),
            onTap:    () => Navigator.pop(sheetContext, _ExportDestination.device),
          ),
          ListTile(
            leading:  const Icon(Icons.share),
            title:    Text(l.optionExportShare),
            subtitle: Text(l.optionExportShareSubtitle),
            onTap:    () => Navigator.pop(sheetContext, _ExportDestination.share),
          ),
        ],
      ),
    ),
  );
  if (destination == null || !context.mounted) return;

  final file = File(path);
  switch (destination) {
    case _ExportDestination.device:
      final saved = await FilePicker.platform.saveFile(
        fileName: file.uri.pathSegments.last,
        bytes:    await file.readAsBytes(),
      );
      // The copy chosen by the user is the only one to keep: the scratch
      // file may hold plaintext passwords (JSON export).
      await file.delete().catchError((_) => file);
      if (saved != null && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.snackExportSaved)));
      }
    case _ExportDestination.share:
      await Share.shareXFiles([XFile(path)]);
  }
}
