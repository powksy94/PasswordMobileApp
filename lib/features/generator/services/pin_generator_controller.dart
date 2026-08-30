import '../../vault/services/vault_service.dart';
import '../../../shared/services/clipboard_service.dart';
import './generator_exceptions.dart';

export './generator_exceptions.dart';

/// Orchestration (validation + persistance + presse-papiers) pour le
/// générateur de PINs — miroir de [PasswordGeneratorController], sans code
/// partagé (logiques indépendantes, voir PIN_VAULT_SPEC.md).
class PinGeneratorController {
  /// Valide puis ajoute le PIN généré au coffre.
  /// Lève [MissingLabelException] si le label est vide.
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
