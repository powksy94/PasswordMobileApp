import '../../vault/services/vault_service.dart';
import '../../../shared/services/clipboard_service.dart';
import './generator_exceptions.dart';

export './generator_exceptions.dart';

/// Orchestration (validation + persistence + clipboard) for the
/// password generator, separated from the UI, with no dependency on
/// `State`/`setState`, following the same principle as `VaultReencryptService`.
class PasswordGeneratorController {
  /// Validates then adds the generated password to the vault.
  /// Throws [MissingLabelException] if the label is empty; any other
  /// exception (network, etc.) bubbles up unchanged to the caller.
  Future<void> addToVault({
    required String label,
    required String password,
    required String login,
    required String notes,
    required String url,
  }) async {
    if (label.isEmpty) throw MissingLabelException();
    await VaultService.addToServer(
      label:    label,
      login:    login,
      password: password,
      notes:    notes,
      icon:     'lock',
      url:      url,
    );
  }

  Future<void> copy(String password) =>
      ClipboardService.copyAndScheduleClear(password);
}
