import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabidos2app/presentation/controllers/gamification_controller.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasRewards = context.watch<GamificationController>().hasPendingRewards;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF292535),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF292535),
        selectedItemColor: const Color(0xFFFBCB4E),
        unselectedItemColor: Colors.white54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.account_circle),
                if (hasRewards)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ), 
            label: ''
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.style_rounded), label: ''),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: '',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.timer_rounded), label: ''),
          const BottomNavigationBarItem(
            icon: Icon(Icons.sticky_note_2_rounded),
            label: '',
          ),
        ],
      ),
    );
  }
}
