import 'package:flutter/material.dart';
import '../../data/datasources/auth_service.dart';
import '../../data/datasources/points_service.dart';
import '../../data/core/api_client.dart';
// import '../../data/datasources/token_storage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> logout(BuildContext context) async {
    await AuthService().logout();
    // await TokenStorage().clearToken();
  }

  Future<void> pontsFunc() async {
    final service = PointsService(apiClient);

    final result = await service.earnPoints(
      action: "FlashcardRespondido",
      data: {"correct": true, "difficulty": "MEDIO"},
    );
    print("+${result.earnedPoints} pontos");
    print("Total: ${result.totalPoints}");

    if (result.unlockedAchievements.isNotEmpty) {
      for (var a in result.unlockedAchievements) {
        print("Nova conquista: $a");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Container(
          child: IconButton(
            onPressed: () => pontsFunc(),
            icon: const Icon(Icons.access_alarm),
          ),
        ),
      ),
    );
  }
}
