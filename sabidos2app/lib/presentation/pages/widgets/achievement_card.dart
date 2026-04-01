import 'package:flutter/material.dart';
import '../../../data/core/models/achievement.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? const Color(0xFF2A243A)
            : const Color(0xFF1B1826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achievement.isUnlocked
              ? const Color(0xFFFBCB4E).withOpacity(0.45)
              : Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: achievement.isUnlocked
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF1598E1),
                            Color(0xFFA45981),
                            Color(0xFFD5343B),
                          ],
                        )
                      : null,
                  color: achievement.isUnlocked ? null : Colors.white12,
                ),
                child: Icon(
                  achievement.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Spacer(),
              Icon(
                achievement.isUnlocked
                    ? Icons.verified_rounded
                    : Icons.lock_outline_rounded,
                color: achievement.isUnlocked
                    ? const Color(0xFFFBCB4E)
                    : Colors.white38,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            achievement.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            achievement.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: achievement.progressValue,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                achievement.isUnlocked
                    ? const Color(0xFFFBCB4E)
                    : const Color(0xFFA45981),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${achievement.progress}/${achievement.goal}",
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}