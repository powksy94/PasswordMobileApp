import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Returns an app-private folder in which to write an export before
/// sharing it via [Share.shareXFiles] (see vault_export_actions.dart).
///
/// We no longer write directly to the public `Download/` folder: under
/// scoped storage (Android 10+), a raw `File` built from a guessed
/// path fails silently or throws, without the
/// `MANAGE_EXTERNAL_STORAGE` permission. Going through the system share sheet lets
/// the user pick the real destination (Files, Drive, email...)
/// through a UI that the OS allows without any extra permission.
Future<Directory> getExportScratchDirectory() => getTemporaryDirectory();
