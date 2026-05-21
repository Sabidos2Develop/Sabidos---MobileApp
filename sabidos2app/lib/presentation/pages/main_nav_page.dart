import 'package:flutter/material.dart';
import 'package:sabidos2app/presentation/pages/teste2.dart';
import './widgets/b_navbar.dart';
import 'package:sabidos2app/presentation/pages/flashcards_page.dart';
import 'package:sabidos2app/presentation/pages/dashboard_page.dart';
import 'package:sabidos2app/presentation/pages/pomodoro_page.dart';
import 'package:sabidos2app/presentation/pages/resumo_page.dart';
import 'package:sabidos2app/presentation/pages/agenda_page.dart';
import 'package:sabidos2app/presentation/pages/perfil_page.dart';

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

  @override
  Widget build(BuildContext context) {
    // Pegamos a página atual da lista dinamicamente
    // Isso evita que páginas em background (como a Agenda) travem o app durante reconstruções globais
    final Widget currentPage;
    
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
      body: currentPage,
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onTabChange,
      ),
    );
  }
}
