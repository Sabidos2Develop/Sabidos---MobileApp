import 'package:flutter/material.dart';
import 'package:sabidos2app/presentation/pages/teste2.dart';
import './widgets/b_navbar.dart';
import 'package:sabidos2app/presentation/pages/flashcards_page.dart';
import 'package:sabidos2app/presentation/pages/dashboard_page.dart';
import 'package:sabidos2app/presentation/pages/pomodoro_page.dart';
import 'package:sabidos2app/presentation/pages/resumo_page.dart';
import 'package:sabidos2app/presentation/pages/agenda_page.dart';
import 'package:sabidos2app/presentation/pages/perfil_page.dart';
import 'package:flutter/material.dart';
import '../../data/datasources/auth_service.dart';
import '../../data/datasources/points_service.dart';
import '../../data/core/api_client.dart';
import '../../core/theme/theme_controller.dart';
import 'package:provider/provider.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
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

    switch (_currentIndex) {
      case 0:
        currentPage = const AchievementPage();
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
      case 5:
        currentPage = const PerfilPage();
        break;
      default:
        currentPage = const DashboardPage();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF171621),
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
      body: currentPage,
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onTabChange,
      ),
    );
  }
}
