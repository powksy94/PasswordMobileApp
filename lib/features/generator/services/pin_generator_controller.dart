import '../../vault/services/vault_service.dart';
import '../../../shared/services/clipboard_service.dart';
import './generator_exceptions.dart';

export './generator_exceptions.dart';

/// Orchestration (validation + persistence + clipboard) for the
/// PIN generator, mirror of [PasswordGeneratorController], with no shared
/// code (independent logic, see PIN_VAULT_SPEC.md).
class PinGeneratorController {
  /// Validates then adds the generated PIN to the vault.
  /// Throws [MissingLabelException] if the label is empty.
  Future<void> addToVault({
    required String label,
    required String pin,
    required String notes,
  }) async {
    if (label.isEmpty) throw MissingLabelException();
    await VaultService.addToServer(
      type:     'pin',
      label:    label,
      password: '',
      pin:      pin,
      notes:    notes,
    );
  }

  Future<void> copy(String pin) =>
      ClipboardService.copyAndScheduleClear(pin);
}
