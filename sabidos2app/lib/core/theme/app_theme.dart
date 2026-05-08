import 'package:flutter/material.dart';
import 'app_color_themes.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    extensions: [AppColorThemes.light],

    scaffoldBackgroundColor: AppColorThemes.light.background,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    extensions: [AppColorThemes.dark],

    scaffoldBackgroundColor: AppColorThemes.dark.background,
  );
}
