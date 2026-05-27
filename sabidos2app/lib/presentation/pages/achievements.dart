import 'package:flutter/material.dart';

class AchievementPage extends StatelessWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      AchievementModel(
        title: "Primeiro Resumo",
        description: "Você criou seu primeiro resumo.",
        progress: 1,
        total: 1,
        unlocked: true,
        icon: Icons.description_rounded,
      ),
      AchievementModel(
        title: "Foco Inicial",
        description: "Complete 5 sessões pomodoro.",
        progress: 2,
        total: 5,
        unlocked: false,
        icon: Icons.timer_rounded,
      ),
      AchievementModel(
        title: "Mestre dos Flashcards",
        description: "Crie 20 flashcards.",
        progress: 8,
        total: 20,
        unlocked: false,
        icon: Icons.style_rounded,
      ),
      AchievementModel(
        title: "Organizado",
        description: "Cadastre 10 eventos na agenda.",
        progress: 10,
        total: 10,
        unlocked: true,
        icon: Icons.calendar_month_rounded,
      ),
      AchievementModel(
        title: "Consistência",
        description: "Estude por 3 dias seguidos.",
        progress: 1,
        total: 3,
        unlocked: false,
        icon: Icons.local_fire_department_rounded,
      ),
      AchievementModel(
        title: "Veterano",
        description: "Realize 100 ações na plataforma.",
        progress: 24,
        total: 100,
        unlocked: false,
        icon: Icons.emoji_events_rounded,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF151126),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // HEADER
              const Text(
                "Conquistas",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Acompanhe seu progresso na plataforma.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 30),

              // XP CARD
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2B2344), Color(0xFF1D1733)],
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4DAFFF), Color(0xFFFF4D6D)],
                        ),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),

                    const SizedBox(width: 20),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nível 12",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "1280 XP",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFFFFD04D).withOpacity(0.12),
                      ),
                      child: const Text(
                        "+25 XP",
                        style: TextStyle(
                          color: Color(0xFFFFD04D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 34),

              // SOBRE
              _sectionCard(
                title: "Sobre Mim",
                child: Text(
                  "Nenhuma descrição fornecida.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // ACHIEVEMENTS
              _sectionCard(
                title: "Conquistas",
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: achievements.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.92,
                  ),
                  itemBuilder: (_, index) {
                    final item = achievements[index];

                    return _achievementCard(item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF221B3B), Color(0xFF1A1530)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFD04D),
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),

          const SizedBox(height: 20),

          child,
        ],
      ),
    );
  }

  Widget _achievementCard(AchievementModel item) {
    final progressValue = item.progress / item.total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: item.unlocked
              ? [const Color(0xFF2D2647), const Color(0xFF241E3B)]
              : [const Color(0xFF171327), const Color(0xFF131021)],
        ),
        border: Border.all(
          color: item.unlocked
              ? const Color(0xFFFFD04D).withOpacity(0.45)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF4DAFFF), Color(0xFFFF4D6D)],
                  ),
                ),
                child: Icon(item.icon, color: Colors.white, size: 24),
              ),

              Icon(
                item.unlocked
                    ? Icons.verified_rounded
                    : Icons.lock_outline_rounded,
                color: item.unlocked ? const Color(0xFFFFD04D) : Colors.white38,
              ),
            ],
          ),

          const Spacer(),

          Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            item.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 15,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                item.unlocked
                    ? const Color(0xFFFFD04D)
                    : const Color(0xFFC85C9E),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            "${item.progress}/${item.total}",
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class AchievementModel {
  final String title;
  final String description;
  final int progress;
  final int total;
  final bool unlocked;
  final IconData icon;

  AchievementModel({
    required this.title,
    required this.description,
    required this.progress,
    required this.total,
    required this.unlocked,
    required this.icon,
  });
}
