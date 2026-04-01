import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/core/models/achievement.dart';
import '../../data/core/models/user_stats.dart';
import '../../data/core/models/achievement_catalog.dart';
import '../pages/widgets/achievement_card.dart';
import '../../core/app_colors.dart';
import '../controllers/authController.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String? fotoPerfilUrl;
  bool isLoadingImage = false;
  String? backendName;
  String? backendBio;
  String? backendRole;

  List<Achievement> achievements = [];
  bool isLoadingAchievements = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfileData();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() {
      isLoadingAchievements = true;
    });

    final stats = UserStats(
      resumosCriados: 1,
      pomodorosConcluidos: 2,
      flashcardsCriados: 8,
      eventosCriados: 10,
      diasSequencia: 1,
      totalAcoes: 24,
    );

    final data = AchievementCatalog.buildFromStats(stats);

    setState(() {
      achievements = data;
      isLoadingAchievements = false;
    });
  }

  Future<void> _loadUserProfileData() async {
    final auth = context.read<AuthController>();
    final currentUser = auth.user;

    if (currentUser == null) return;

    setState(() {
      fotoPerfilUrl = currentUser.photoURL;
    });
  }

  Future<void> _handleLogout() async {
    final auth = context.read<AuthController>();

    try {
      await auth.logout();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logout realizado com sucesso")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erro ao sair da conta")));
    }
  }

  Future<void> _selectAndUploadImage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Upload de imagem será ativado quando ligar o backend"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final currentUser = auth.user;

    final displayName =
        backendName ?? currentUser?.displayName ?? "Sem nome definido";

    final displayBio = backendBio ?? "";

    final displayEmail = currentUser?.email ?? "";

    final displayRole = backendRole ?? "Membro";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1598E1),
                    Color(0xFFA45981),
                    Color(0xFFD5343B),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.all(1.2),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileHeader(role: displayRole),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                      child: Column(
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -52),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _AvatarSection(
                                      photoUrl: fotoPerfilUrl,
                                      isLoading: isLoadingImage,
                                      onTap: _selectAndUploadImage,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                _LogoutButton(onPressed: _handleLogout),
                              ],
                            ),
                          ),
                          const SizedBox(height: 0),
                          Transform.translate(
                            offset: const Offset(0, -28),
                            child: Column(
                              children: [
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isMobile = constraints.maxWidth < 700;

                                    if (isMobile) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _InfoBlock(
                                            label: "Nome Completo",
                                            child: Text(
                                              displayName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          _InfoBlock(
                                            label: "Email",
                                            child: _EmailChip(
                                              email: displayEmail,
                                            ),
                                          ),
                                        ],
                                      );
                                    }

                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: _InfoBlock(
                                            label: "Nome Completo",
                                            child: Text(
                                              displayName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Expanded(
                                          child: _InfoBlock(
                                            label: "Email",
                                            child: _EmailChip(
                                              email: displayEmail,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 28),
                                _InfoBlock(
                                  label: "Sobre Mim",
                                  child: Text(
                                    displayBio.isNotEmpty
                                        ? displayBio
                                        : "Nenhuma descrição fornecida.",
                                    style: TextStyle(
                                      color: displayBio.isNotEmpty
                                          ? Colors.white
                                          : Colors.white70,
                                      fontSize: 15,
                                      height: 1.6,
                                      fontStyle: displayBio.isNotEmpty
                                          ? FontStyle.normal
                                          : FontStyle.italic,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),

                                _InfoBlock(
                                  label: "Conquistas",
                                  child: isLoadingAchievements
                                      ? const Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : Wrap(
                                          spacing: 14,
                                          runSpacing: 14,
                                          children: achievements
                                              .map(
                                                (a) => AchievementCard(
                                                  achievement: a,
                                                ),
                                              )
                                              .toList(),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String role;

  const _ProfileHeader({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        image: const DecorationImage(
          image: AssetImage(''),
          fit: BoxFit.cover,
          onError: null,
        ),
        color: const Color(0xFF211D30),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.12),
              Colors.black.withOpacity(0.35),
            ],
          ),
        ),
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: const EdgeInsets.only(top: 18, right: 18),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: Text(
              role.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarSection extends StatelessWidget {
  final String? photoUrl;
  final bool isLoading;
  final VoidCallback onTap;

  const _AvatarSection({
    required this.photoUrl,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF1598E1), Color(0xFFA45981), Color(0xFFD5343B)],
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 124,
              height: 124,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE7E7E7),
                image: (photoUrl != null && photoUrl!.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (photoUrl == null || photoUrl!.isEmpty)
                  ? const Icon(Icons.person, size: 58, color: Colors.grey)
                  : null,
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  shape: BoxShape.circle,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LogoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.logout_rounded, size: 18),
      label: const Text("Sair"),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFE1E1),
        foregroundColor: const Color(0xFFC53B3B),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final Widget child;

  const _InfoBlock({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF211D30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFBCB4E),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _EmailChip extends StatelessWidget {
  final String email;

  const _EmailChip({required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mail_outline_rounded, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              email.isNotEmpty ? email : "Email não disponível",
              style: const TextStyle(color: Color(0xFFE7E7E7), fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
