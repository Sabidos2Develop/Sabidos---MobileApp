import 'package:flutter/material.dart';
import '../../../data/core/models/achievement.dart';
import 'achievement_card.dart';

class AchievementsSection extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementsSection({
    super.key,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return const Text(
        "Nenhuma conquista disponível ainda.",
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: achievements
          .map((achievement) => AchievementCard(achievement: achievement))
          .toList(),
    );
  }
}