import 'package:flutter/material.dart';

class AchievementNotification {
  final String title;
  final String description;
  final int xp;
  final IconData icon;

  AchievementNotification({
    required this.title, 
    required this.description, 
    required this.xp, 
    required this.icon
  });
}

class LevelUpNotification {
  final int oldLevel;
  final double oldProgress;
  final int newLevel;
  final double newProgress;

  LevelUpNotification({
    required this.oldLevel,
    required this.oldProgress,
    required this.newLevel,
    required this.newProgress,
  });
}

class MissionNotification {
  final String title;
  final String emoji;
  MissionNotification({required this.title, required this.emoji});
}

class NotificationController extends ChangeNotifier {
  AchievementNotification? _currentNotification;
  AchievementNotification? get currentNotification => _currentNotification;

  LevelUpNotification? _currentLevelUp;
  LevelUpNotification? get currentLevelUp => _currentLevelUp;

  MissionNotification? _currentMission;
  MissionNotification? get currentMission => _currentMission;

  void showAchievement(AchievementNotification notification) {
    _currentNotification = notification;
    notifyListeners();
  }

  void showLevelUp(int oldLevel, double oldProgress, int newLevel, double newProgress) {
    _currentLevelUp = LevelUpNotification(
      oldLevel: oldLevel, 
      oldProgress: oldProgress, 
      newLevel: newLevel, 
      newProgress: newProgress
    );
    notifyListeners();
  }

  void showMissionComplete(String title, String emoji) {
    _currentMission = MissionNotification(title: title, emoji: emoji);
    notifyListeners();
  }

  void dismiss() {
    _currentNotification = null;
    notifyListeners();
  }

  void dismissLevelUp() {
    _currentLevelUp = null;
    notifyListeners();
  }

  void dismissMission() {
    _currentMission = null;
    notifyListeners();
  }
}
