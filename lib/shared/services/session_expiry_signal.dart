import 'package:flutter/foundation.dart';

/// Global signal raised when the server rejects the session token (invalid
/// or expired). Deliberately neutral: the network layer raises it without knowing
/// anything about authentication or navigation; whoever listens to it
/// (`main.dart`) decides what to do with it.
class SessionExpirySignal {
  static final ValueNotifier<int> notifier = ValueNotifier(0);

  static void raise() => notifier.value++;
}
