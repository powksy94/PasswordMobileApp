import 'dart:math';

class PasswordGenerator {
  static const _lower = "abcdefghijklmnopqrstuvwxyz";
  static const _upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  static const _digits = "0123456789";
  static const _specials = "!@#\$%^&*()-_=+[]{};:,.?/<>|";

  static String generate({
    int length = 16,
    bool useLower = true,
    bool useUpper = true,
    bool useDigits = true,
    bool useSpecials = true,
    bool requireAllTypes = true,
    String exclude = "",
  }) {
    final rand = Random.secure();
    String chars = "";

    if (useLower) chars += _lower;
    if (useUpper) chars += _upper;
    if (useDigits) chars += _digits;
    if (useSpecials) chars += _specials;

    // 🔥 Exclusion des caractères non désirés
    chars = chars.split("").where((c) => !exclude.contains(c)).join();

    if (chars.isEmpty) {
      throw Exception("Aucun caractère disponible après exclusions !");
    }

    List<String> password = [];

    // 🔐 Assure un caractère de chaque type si demandé
    if (requireAllTypes) {
      if (useLower) password.add(_pick(_lower, exclude, rand));
      if (useUpper) password.add(_pick(_upper, exclude, rand));
      if (useDigits) password.add(_pick(_digits, exclude, rand));
      if (useSpecials) password.add(_pick(_specials, exclude, rand));
    }

    // 🔐 Ajoute des caractères aléatoires jusqu'à atteindre la longueur
    while (password.length < length) {
      password.add(chars[rand.nextInt(chars.length)]);
    }

    // 🔀 Mélange final
    password.shuffle(rand);

    return password.join();
  }

  static String _pick(String charset, String exclude, Random rand) {
    final filtered = charset.split("").where((c) => !exclude.contains(c)).toList();
    if (filtered.isEmpty) throw Exception("Impossible de prendre un caractère, tout est exclu !");
    return filtered[rand.nextInt(filtered.length)];
  }
}
