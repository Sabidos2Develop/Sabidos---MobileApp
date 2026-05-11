import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ThemeExtensionX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
