import 'package:flutter/material.dart';
import '../models/vault_item.dart';
import './add_vault_item_page.dart';
import './edit_vault_item_page.dart';
import './add_pin_item_page.dart';
import './edit_pin_item_page.dart';

/// Centralizes the choice of the add/edit page depending on the item type
/// (password or PIN): callers (e.g. VaultPage) do not need to
/// know the 4 individual pages nor their dispatch logic.
class VaultItemNavigation {
  const VaultItemNavigation._();

  static Widget addPageFor(String type) =>
      type == 'pin' ? const AddPinItemPage() : const AddVaultItemPage();

  static Widget editPageFor(VaultItem item) =>
      item.type == 'pin' ? EditPinItemPage(item: item) : EditVaultItemPage(item: item);
}
