import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int goal;
  final int progress;
  final bool isUnlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.goal,
    required this.progress,
    required this.isUnlocked,
  });

  double get progressValue {
    if (goal <= 0) return 0;
    final value = progress / goal;
    return value.clamp(0, 1);
  }

  Achievement copyWith({
    int? progress,
    bool? isUnlocked,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      goal: goal,
      progress: progress ?? this.progress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}