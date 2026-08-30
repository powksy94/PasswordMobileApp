import '../../vault/services/vault_service.dart';
import '../../../shared/services/clipboard_service.dart';
import './generator_exceptions.dart';

export './generator_exceptions.dart';

/// Orchestration (validation + persistance + presse-papiers) pour le
/// générateur de mots de passe — séparée de l'UI, sans dépendance à
/// `State`/`setState`, sur le même principe que `VaultReencryptService`.
class PasswordGeneratorController {
  /// Valide puis ajoute le mot de passe généré au coffre.
  /// Lève [MissingLabelException] si le label est vide ; toute autre
  /// exception (réseau, etc.) remonte telle quelle à l'appelant.
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
