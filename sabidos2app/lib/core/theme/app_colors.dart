import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color boxBackground;
  final Color boxBorder;
  final Color primary;
  final Color border;
  final Color text;
  final Color textSecondary;

  // New colors from source
  final Color accentRed;
  final Color accentYellow;
  final Color accentBlue;
  final Color grayText;
  final Color badgeBlue;
  final Color badgeGold;

  // New gradients from source
  final LinearGradient sabidosGradient;
  final LinearGradient levelGradient;
  final LinearGradient rankGradient;

  const AppColors({
    required this.background,
    required this.boxBackground,
    required this.boxBorder,
    required this.primary,
    required this.border,
    required this.text,
    required this.textSecondary,
    required this.accentRed,
    required this.accentYellow,
    required this.accentBlue,
    required this.grayText,
    required this.badgeBlue,
    required this.badgeGold,
    required this.sabidosGradient,
    required this.levelGradient,
    required this.rankGradient,
  });

  @override
  AppColors copyWith({
    Color? background,
    Color? boxBackground,
    Color? boxBorder,
    Color? primary,
    Color? border,
    Color? text,
    Color? textSecondary,
    Color? accentRed,
    Color? accentYellow,
    Color? accentBlue,
    Color? grayText,
    Color? badgeBlue,
    Color? badgeGold,
    LinearGradient? sabidosGradient,
    LinearGradient? levelGradient,
    LinearGradient? rankGradient,
  }) {
    return AppColors(
      background: background ?? this.background,
      boxBackground: boxBackground ?? this.boxBackground,
      boxBorder: boxBorder ?? this.boxBorder,
      primary: primary ?? this.primary,
      border: border ?? this.border,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      accentRed: accentRed ?? this.accentRed,
      accentYellow: accentYellow ?? this.accentYellow,
      accentBlue: accentBlue ?? this.accentBlue,
      grayText: grayText ?? this.grayText,
      badgeBlue: badgeBlue ?? this.badgeBlue,
      badgeGold: badgeGold ?? this.badgeGold,
      sabidosGradient: sabidosGradient ?? this.sabidosGradient,
      levelGradient: levelGradient ?? this.levelGradient,
      rankGradient: rankGradient ?? this.rankGradient,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;

    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      boxBackground: Color.lerp(boxBackground, other.boxBackground, t)!,
      boxBorder: Color.lerp(boxBorder, other.boxBorder, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      accentRed: Color.lerp(accentRed, other.accentRed, t)!,
      accentYellow: Color.lerp(accentYellow, other.accentYellow, t)!,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
      grayText: Color.lerp(grayText, other.grayText, t)!,
      badgeBlue: Color.lerp(badgeBlue, other.badgeBlue, t)!,
      badgeGold: Color.lerp(badgeGold, other.badgeGold, t)!,
      sabidosGradient: LinearGradient.lerp(sabidosGradient, other.sabidosGradient, t)!,
      levelGradient: LinearGradient.lerp(levelGradient, other.levelGradient, t)!,
      rankGradient: LinearGradient.lerp(rankGradient, other.rankGradient, t)!,
    );
  }
}
