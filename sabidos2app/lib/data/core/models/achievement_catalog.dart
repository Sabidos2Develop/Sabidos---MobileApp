import 'package:flutter/material.dart';
import './achievement.dart';
import './user_stats.dart';

class AchievementCatalog {
  static List<Achievement> buildFromStats(UserStats stats) {
    final achievements = <Achievement>[
      Achievement(
        id: 'primeiro_resumo',
        title: 'Primeiro Resumo',
        description: 'Você criou seu primeiro resumo na plataforma.',
        icon: Icons.article_rounded,
        goal: 1,
        progress: stats.resumosCriados,
        isUnlocked: stats.resumosCriados >= 1,
      ),
      Achievement(
        id: 'foco_inicial',
        title: 'Foco Inicial',
        description: 'Complete 5 sessões de pomodoro.',
        icon: Icons.timer_rounded,
        goal: 5,
        progress: stats.pomodorosConcluidos,
        isUnlocked: stats.pomodorosConcluidos >= 5,
      ),
      Achievement(
        id: 'mestre_flashcards',
        title: 'Mestre dos Flashcards',
        description: 'Crie 20 flashcards.',
        icon: Icons.style_rounded,
        goal: 20,
        progress: stats.flashcardsCriados,
        isUnlocked: stats.flashcardsCriados >= 20,
      ),
      Achievement(
        id: 'organizado',
        title: 'Organizado',
        description: 'Cadastre 10 eventos na agenda.',
        icon: Icons.event_note_rounded,
        goal: 10,
        progress: stats.eventosCriados,
        isUnlocked: stats.eventosCriados >= 10,
      ),
      Achievement(
        id: 'sequencia_3',
        title: 'Consistência',
        description: 'Estude por 3 dias seguidos.',
        icon: Icons.local_fire_department_rounded,
        goal: 3,
        progress: stats.diasSequencia,
        isUnlocked: stats.diasSequencia >= 3,
      ),
      Achievement(
        id: 'veterano',
        title: 'Veterano',
        description: 'Realize 100 ações dentro da plataforma.',
        icon: Icons.emoji_events_rounded,
        goal: 100,
        progress: stats.totalAcoes,
        isUnlocked: stats.totalAcoes >= 100,
      ),
    ];

    return achievements;
  }
}