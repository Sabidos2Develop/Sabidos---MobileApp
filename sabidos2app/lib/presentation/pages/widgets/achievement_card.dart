import 'package:flutter/material.dart';
import '../../../data/core/models/achievement.dart';
import 'package:sabidos2app/core/theme/theme_extensions.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? colors.boxBackground
            : colors.boxBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achievement.isUnlocked
              ? colors.accentYellow.withOpacity(0.45)
              : colors.boxBorder.withOpacity(0.3),
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
                      ? colors.sabidosGradient
                      : null,
                  color: achievement.isUnlocked ? null : Colors.white10,
                ),
                child: Icon(
                  achievement.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.accentBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.accentBlue.withOpacity(0.3)),
                ),
                child: Text(
                  "+${achievement.xpReward} XP",
                  style: TextStyle(
                    color: colors.accentBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            achievement.title,
            style: TextStyle(
              color: colors.text,
              fontSize: 15, // Reduzi levemente para caber melhor
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Expanded( // Faz a descrição ocupar o espaço disponível
            child: Text(
              achievement.description,
              style: TextStyle(
                color: colors.text.withOpacity(0.7),
                fontSize: 12, // Reduzi levemente
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: achievement.isUnlocked ? 1.0 : achievement.progressValue,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                achievement.isUnlocked
                    ? colors.accentYellow
                    : colors.accentBlue.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (!achievement.isUnlocked)
            Text(
              "${achievement.progress}/${achievement.goal}",
              style: TextStyle(
                color: colors.grayText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            Text(
              "Concluída",
              style: TextStyle(
                color: colors.accentYellow,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
        ],
      ),
    );
  }
}