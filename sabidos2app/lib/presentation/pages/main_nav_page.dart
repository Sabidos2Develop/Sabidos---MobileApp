import 'package:flutter/material.dart';
import './widgets/b_navbar.dart';
import 'package:sabidos2app/presentation/pages/flashcards_page.dart';
import 'package:sabidos2app/presentation/pages/pomodoro_page.dart';
import 'package:sabidos2app/presentation/pages/resumo_page.dart';
import 'package:sabidos2app/presentation/pages/agenda_page.dart';
import '../../data/datasources/auth_service.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:sabidos2app/presentation/pages/profile_page.dart';
import '../controllers/notification_controller.dart';

import '../widgets/success_overlay.dart';
import '../widgets/level_up_overlay.dart';
import '../widgets/mission_complete_overlay.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  int _profileTabIndex = 0;

  void _onTabChange(int index, {int profileTab = 0}) {
    setState(() {
      _currentIndex = index;
      _profileTabIndex = profileTab;
    });
  }

  Future<void> logout(BuildContext context) async {
    await AuthService().logout();
  }

  @override
  Widget build(BuildContext context) {
    // Pegamos a página atual da lista dinamicamente
    // Isso evita que páginas em background (como a Agenda) travem o app durante reconstruções globais
    final Widget currentPage;
    final controller = context.watch<ThemeController>();
    final colors = Theme.of(context).extension<AppColors>()!;

    switch (_currentIndex) {
      case 0:
        currentPage = ProfileScreen(
          onNavigate: (idx) => _onTabChange(idx), 
          initialTabIndex: _profileTabIndex
        );
        break;
      case 1:
        currentPage = const FlashcardsPage();
        break;
      case 2:
        currentPage = const AgendaPage();
        break;
      case 3:
        currentPage = const PomodoroPage();
        break;
      case 4:
        currentPage = const ResumoPage();
        break;
      default:
        currentPage = const ProfileScreen();
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: colors.background,
          body: currentPage,
          bottomNavigationBar: BottomNavbar(
            currentIndex: _currentIndex,
            onTap: (index) => _onTabChange(index, profileTab: 0),
          ),

        ),
        SuccessOverlay(onNavigate: _onTabChange),
        MissionCompleteOverlay(onNavigate: _onTabChange),
        
        // LEVEL UP OVERLAY (Prioridade máxima, mas espera os toasts sumirem)
        Selector<NotificationController, (LevelUpNotification?, bool, bool)>(
          selector: (_, ctrl) => (ctrl.currentLevelUp, ctrl.currentNotification != null, ctrl.currentMission != null),
          builder: (context, data, child) {
            final levelData = data.$1;
            final isShowingToast = data.$2 || data.$3;

            // Se houver level up, mas um toast estiver na tela, esperamos.
            if (levelData == null || isShowingToast) return const SizedBox.shrink();

            return LevelUpOverlay(
              key: ValueKey('level_up_${levelData.newLevel}'),
              notification: levelData,
              onNavigate: _onTabChange,
            );
          },
        ),
      ],
    );
  }
}
