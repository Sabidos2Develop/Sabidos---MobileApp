import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabidos2app/domain/models/earn_response.dart';
import 'package:sabidos2app/domain/models/user_progress.dart';
import 'package:sabidos2app/presentation/controllers/notification_controller.dart';
import 'package:sabidos2app/data/core/models/achievement_catalog.dart';
import 'package:sabidos2app/presentation/controllers/gamification_controller.dart';
import '../core/api_client.dart';

import 'package:sabidos2app/data/core/models/daily_mission.dart';

class PointsService {
  final Dio _dio;

  PointsService({Dio? dio}) : _dio = dio ?? apiClient;

  Future<EarnResponse> earnPoints({
    required String action,
    required Map<String, dynamic> data,
    BuildContext? context,
  }) async {
    final response = await _dio.post(
      "/Points/earn", 
      data: {"action": action, "data": data},
    );

    final result = EarnResponse.fromJson(response.data);

    // Se houver novas conquistas ou missões e tivermos o contexto, disparamos a notificação
    if (context != null) {
      final gami = context.read<GamificationController>();
      
      // 1. Atualiza os dados globais
      await gami.fetchStats();

      // 2. Notifica Conquistas Permanentes
      if (result.unlockedAchievements.isNotEmpty) {
        final catalog = AchievementCatalog.buildFromStats(gami.stats, []);
        for (var achievementId in result.unlockedAchievements) {
          final ach = catalog.firstWhere((a) => a.id == achievementId);
          context.read<NotificationController>().showAchievement(
            AchievementNotification(
              title: ach.title,
              description: ach.description,
              xp: ach.xpReward,
              icon: ach.icon,
            ),
          );
        }
      }

      // 3. Notifica Missões Diárias Cumpridas (que acabaram de bater 100%)
      for (var mission in gami.dailyMissions) {
        if (mission.completed && !mission.claimed) {
          // Aqui poderíamos ter uma lógica para só avisar UMA VEZ
          context.read<NotificationController>().showMissionComplete(
            mission.title, 
            mission.emoji
          );
        }
      }
    }

    return result;
  }

  Future<UserProgress> getMyProgress() async {
    final result = await _dio.get("/points/me");

    return UserProgress.fromJson(result.data);
  }
}







// await http.post(
//   Uri.parse("https://sua-api/points/earn"),
//   headers: {
//     "Authorization": "Bearer $tokenFirebase"
//   },
//   body: jsonEncode({
//     "action": "Flashcard",
//     "data": {
//       "correct": true,
//       "difficulty": "MEDIO"
//     }
//   }),
// );