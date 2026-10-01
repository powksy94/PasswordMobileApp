import 'package:flutter/material.dart';
import '../../../shared/services/autofill_bridge_service.dart';
import '../../../shared/utils/error_message.dart';
import '../../../l10n/app_localizations.dart';
import './vault_service.dart';

/// Checks for a password generated and saved via the Android autofill
/// "generate a new password" flow (see upgrade/ANDROID_AUTOFILL_SUGGESTION.md)
/// while the vault wasn't unlocked yet, and offers to add it now that it is.
///
/// Call this once the vault is unlocked and a [BuildContext] is available
/// (right after reaching `/home`, and again on app resume): a no-op if
/// there is nothing pending.
Future<void> checkPendingAutofillSave(BuildContext context) async {
  final pending = await AutofillBridgeService.consumePendingSave();
  if (pending == null || !context.mounted) return;

  final l = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title:   Text(l.autofillSaveTitle),
      content: Text(l.autofillSaveContent(pending.domain)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.btnCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.btnAddToVault),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  // A plain domain (contains a dot, no spaces) also becomes the item's url -
  // a bare app label (resolveAppLabel's fallback, native side) does not.
  final looksLikeDomain = pending.domain.contains('.') && !pending.domain.contains(' ');

  try {
    await VaultService.addToServer(
      label:    pending.domain,
      password: pending.password,
      url:      looksLikeDomain ? pending.domain : '',
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.snackPasswordAdded)),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage(AppLocalizations.of(context)!, e))),
      );
    }
  }
}
