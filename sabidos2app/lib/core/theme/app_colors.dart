import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color card;
  final Color cardLight;
  final Color primary;
  final Color border;
  final Color text;
  final Color textSecondary;

  const AppColors({
    required this.background,
    required this.card,
    required this.cardLight,
    required this.primary,
    required this.border,
    required this.text,
    required this.textSecondary,
  });

  @override
  AppColors copyWith({
    Color? background,
    Color? card,
    Color? cardLight,
    Color? primary,
    Color? border,
    Color? text,
    Color? textSecondary,
  }) {
    return AppColors(
      background: background ?? this.background,
      card: card ?? this.card,
      cardLight: cardLight ?? this.cardLight,
      primary: primary ?? this.primary,
      border: border ?? this.border,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;

    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardLight: Color.lerp(cardLight, other.cardLight, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}
