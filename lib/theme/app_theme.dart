import 'package:flutter/material.dart';

class AppTheme {
  // 🌑 DARK THEME — Neon Blue Cyberpunk
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF050A18),
    primaryColor: Colors.cyanAccent,
    colorScheme: const ColorScheme.dark(
      primary: Colors.cyanAccent,
      secondary: Colors.cyanAccent,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.cyanAccent),
      bodyLarge: TextStyle(color: Colors.cyanAccent),
      titleLarge: TextStyle(
        color: Colors.cyanAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF050A18),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.cyanAccent),
      titleTextStyle: TextStyle(
        color: Colors.cyanAccent,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.cyanAccent),
        foregroundColor: MaterialStateProperty.all(Colors.black),
        elevation: MaterialStateProperty.all(8),
        shadowColor: MaterialStateProperty.all(Colors.cyanAccent),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: Colors.cyanAccent,
      inactiveTrackColor: Colors.white24,
      thumbColor: Colors.cyanAccent,
      overlayColor: Colors.cyanAccent.withOpacity(0.2),
    ),
  );

  // 🌕 LIGHT THEME — Neon Blue Futuristic
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFEFF8FF),
    primaryColor: Colors.blueAccent,
    colorScheme: const ColorScheme.light(
      primary: Colors.blueAccent,
      secondary: Colors.blueAccent,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.blueAccent),
      bodyLarge: TextStyle(color: Colors.blueAccent),
      titleLarge: TextStyle(
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFEFF8FF),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.blueAccent),
      titleTextStyle: TextStyle(
        color: Colors.blueAccent,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        elevation: MaterialStateProperty.all(6),
        shadowColor: MaterialStateProperty.all(Colors.blueAccent),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: Colors.blueAccent,
      inactiveTrackColor: Colors.black12,
      thumbColor: Colors.blueAccent,
      overlayColor: Colors.blueAccent.withOpacity(0.2),
    ),
  );
}
