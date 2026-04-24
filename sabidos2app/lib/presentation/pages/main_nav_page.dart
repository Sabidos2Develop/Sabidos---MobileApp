import 'package:flutter/material.dart';

import './widgets/b_navbar.dart';

import 'package:sabidos2app/presentation/pages/flashcards_page.dart';
import 'package:sabidos2app/presentation/pages/dashboard_page.dart';
import 'package:sabidos2app/presentation/pages/pomodoro_page.dart';
import 'package:sabidos2app/presentation/pages/resumo_page.dart';
import 'package:sabidos2app/presentation/pages/agenda_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    FlashcardsPage(),
    AgendaPage(),
    PomodoroPage(),
    ResumoPage(),
    
  ];

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onTabChange,
      ),
    );
  }
}