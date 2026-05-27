import 'package:flutter/material.dart';
import './app_colors.dart';

class AppColorThemes {
  static const dark = AppColors(
    background: Color(0xFF151522),
    boxBackground: Color(0xFF2B2735),
    boxBorder: Color(0xFF3F3C4E),
    primary: Color(0xFF3B2868),
    border: Color(0xFF7763B3),
    text: Color(0xFFEAEAEA),
    textSecondary: Color(0xFFAFAFAF),
    // New colors from source
    accentRed: Color(0xFFD3353E),
    accentYellow: Color(0xFFFFDE4D),
    accentBlue: Color(0xFF1499E2),
    grayText: Color(0xFFBEBEBE),
    badgeBlue: Color(0xFF27659E),
    badgeGold: Color(0xFF9E813A),
    // New gradients from source
    sabidosGradient: LinearGradient(
      colors: [Color(0xFFD3353E),Color(0xFFA45981), Color(0xFF1499E2)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    levelGradient: LinearGradient(
      colors: [
        Color(0xFFFFDE4D),
        Color(0xFFFFDA7B),
        Color(0xFFFFDE4D),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    rankGradient: LinearGradient(
      colors: [
        Color(0xFF1499E2),
        Color(0xFF61C7FF),
        Color(0xFF1499E2),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
  );

  static const light = AppColors(
    background: Color(0xFFFFFFFF),
    boxBackground: Color(0xFFF5F5F5),
    boxBorder: Color(0xFFE0E0E0),
    primary: Color(0xFF6750A4),
    border: Color(0xFFCCCCCC),
    text: Color(0xFF1C1B1F),
    textSecondary: Color(0xFF555555),
    // New colors from source (keeping them same as dark or slightly adjusted if needed)
    accentRed: Color(0xFFD3353E),
    accentYellow: Color(0xFFFFDE4D),
    accentBlue: Color(0xFF1499E2),
    grayText: Color(0xFF757575), // Darker gray for light theme
    badgeBlue: Color(0xFF27659E),
    badgeGold: Color(0xFF9E813A),
    // New gradients from source
    sabidosGradient: LinearGradient(
      colors: [Color(0xFFD3353E), Color(0xFF1499E2)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    levelGradient: LinearGradient(
      colors: [
        Color(0xFFFFDE4D),
        Color(0xFFFFDA7B),
        Color(0xFFFFDE4D),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    rankGradient: LinearGradient(
      colors: [
        Color(0xFF1499E2),
        Color(0xFF61C7FF),
        Color(0xFF1499E2),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
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
