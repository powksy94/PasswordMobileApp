import 'package:flutter/material.dart';
import '../models/vault_item.dart';
import './add_vault_item_page.dart';
import './edit_vault_item_page.dart';
import './add_pin_item_page.dart';
import './edit_pin_item_page.dart';

/// Centralise le choix de la page d'ajout/modification selon le type d'item
/// (mot de passe ou PIN) : les appelants (ex. VaultPage) n'ont pas besoin de
/// connaître les 4 pages individuellement ni leur logique de dispatch.
class VaultItemNavigation {
  const VaultItemNavigation._();

  static Widget addPageFor(String type) =>
      type == 'pin' ? const AddPinItemPage() : const AddVaultItemPage();

  static Widget editPageFor(VaultItem item) =>
      item.type == 'pin' ? EditPinItemPage(item: item) : EditVaultItemPage(item: item);
}
