import 'package:flutter/foundation.dart';

/// Bottom-nav tab indices of [HomePage]'s IndexedStack, named so callers
/// don't have to know the raw order (generator/vault/health).
class HomeTabIndex {
  const HomeTabIndex._();

  static const generator = 0;
  static const vault     = 1;
  static const health     = 2;
}

/// Lets code outside [HomePage] (e.g. [FcmService] on a push tap) request
/// switching to a given bottom-nav tab, without either side depending on
/// the other's widget/state class. [HomePage] just listens to
/// [requestedTabIndex] and resets it to null once consumed.
class HomeTabRequestService {
  const HomeTabRequestService._();

  static final ValueNotifier<int?> requestedTabIndex = ValueNotifier<int?>(null);

  static void requestHealthTab() => requestedTabIndex.value = HomeTabIndex.health;
}
