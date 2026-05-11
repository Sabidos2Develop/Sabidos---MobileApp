import 'package:flutter/material.dart';
import './app_colors.dart';

class AppColorThemes {
  static const dark = AppColors(
    background: Color(0xFF171521),
    card: Color(0xFF292535),
    cardLight: Color(0xFF423E51),
    primary: Color(0xFF3B2868),
    border: Color(0xFF7763B3),
    text: Color(0xFFEAEAEA),
    textSecondary: Color(0xFFAFAFAF),
  );

  static const light = AppColors(
    background: Color(0xFFFFFFFF),
    card: Color(0xFFF5F5F5),
    cardLight: Color(0xFFE0E0E0),
    primary: Color(0xFF6750A4),
    border: Color(0xFFCCCCCC),
    text: Color(0xFF1C1B1F),
    textSecondary: Color(0xFF555555),
  );
}

class AppTheme {
  static const _seedColor = Color.fromARGB(255, 226, 235, 71);

  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    ),
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
  );
}
