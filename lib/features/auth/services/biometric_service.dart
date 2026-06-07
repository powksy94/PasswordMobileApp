import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final _auth = LocalAuthentication();

  static Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      final methods = await _auth.getAvailableBiometrics();
      return methods.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate({String reason = 'Déverrouillez votre coffre-fort'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
