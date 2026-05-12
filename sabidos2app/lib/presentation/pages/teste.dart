import 'package:flutter/material.dart';
import '../../data/datasources/auth_service.dart';
import '../../data/datasources/points_service.dart';
import '../../data/core/api_client.dart';
import '../../core/theme/theme_controller.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String resultText = "Nenhuma ação executada";
  bool isLoading = false;

  Future<void> logout(BuildContext context) async {
    await AuthService().logout();
  }

  Future<void> pontsFunc() async {
    setState(() {
      isLoading = true;
      resultText = "Enviando requisição...";
    });

    try {
      final service = PointsService(apiClient);

      final result = await service.earnPoints(
        action: "FlashcardRespondido",
        data: {"correct": true, "difficulty": "MEDIO"},
      );

      setState(() {
        resultText =
            """
✅ Pontos ganhos: ${result.earnedPoints}

🏆 Total de pontos: ${result.totalPoints}

🎯 Conquistas:
${result.unlockedAchievements.isEmpty ? "Nenhuma" : result.unlockedAchievements.join("\n")}
""";
      });
    } catch (e) {
      setState(() {
        resultText = "❌ Erro:\n$e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              context.read<ThemeController>().toggleTheme();
            },
          ),
          Switch(
            value: controller.themeMode == ThemeMode.dark,
            onChanged: (value) {
              controller.setTheme(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: isLoading ? null : pontsFunc,
              icon: const Icon(Icons.stars),
              label: const Text("Ganhar Pontos"),
            ),

            const SizedBox(height: 30),

            if (isLoading) const CircularProgressIndicator(),

            const SizedBox(height: 20),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Text(resultText, style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
