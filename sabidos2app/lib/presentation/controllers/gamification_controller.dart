import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/core/models/user_stats.dart';
import '../../data/core/models/daily_mission.dart';
import '../../data/datasources/gamefication_service.dart';
import './notification_controller.dart';

class GamificationController extends ChangeNotifier {
  final gamefication_service _service = gamefication_service();
  final NotificationController? _notificationController;

  GamificationController({NotificationController? notificationController}) 
    : _notificationController = notificationController;

  NotificationController? _notif;
  void setNotificationController(NotificationController n) => _notif = n;

  UserStats _stats = UserStats.empty();
  int _userLevel = 1;
  int _totalXp = 0;
  int _xpCurrentLevelBase = 0;
  int _xpNextLevelThreshold = 100;
  int _unlockedCount = 0;
  List<String> _unlockedIds = [];
  
  List<DailyMission> _dailyMissions = [];
  int _rerollsLeft = 0;
  
  bool _isLoading = false;
  bool _isInitialized = false; // Flag para ignorar o primeiro carregamento

  UserStats get stats => _stats;
  int get userLevel => _userLevel;
  int get totalXp => _totalXp;
  int get xpCurrentLevelBase => _xpCurrentLevelBase;
  int get xpNextLevelThreshold => _xpNextLevelThreshold;
  int get unlockedCount => _unlockedCount;
  List<String> get unlockedIds => _unlockedIds;
  List<DailyMission> get dailyMissions => _dailyMissions;
  int get rerollsLeft => _rerollsLeft;
  bool get isLoading => _isLoading;

  bool get hasPendingRewards {
    return _dailyMissions.any((m) => m.completed && !m.claimed);
  }

  Future<void> fetchStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final profileData = await _service.getUserStats();
      debugPrint('--- API GAMIFICATION RESPONSE: $profileData ---');
      
      final int newLevel = (profileData['level'] ?? profileData['Level'] ?? 1) as int;
      final int newTotalXp = (profileData['totalXp'] ?? profileData['TotalXp'] ?? 0) as int;
      final int newBase = (profileData['xpCurrentLevelBase'] ?? profileData['XpCurrentLevelBase'] ?? 0) as int;
      final int newNext = (profileData['xpNextLevelThreshold'] ?? profileData['XpNextLevelThreshold'] ?? 100) as int;

      // DETECTA LEVEL UP (Apenas se não for a primeira vez que abrimos o app)
      if (_isInitialized && newLevel > _userLevel) {
        // Cálculo RELATIVO para a barra circular resetar (0% -> 100% -> novo 0% -> novo %)
        final double oldProgress = (_totalXp - _xpCurrentLevelBase) / (_xpNextLevelThreshold - _xpCurrentLevelBase);
        final double newProgress = (newTotalXp - newBase) / (newNext - newBase);
        
        _notif?.showLevelUp(_userLevel, oldProgress.clamp(0, 1), newLevel, newProgress.clamp(0, 1));
      }

      _userLevel = newLevel;
      _totalXp = newTotalXp;
      _xpCurrentLevelBase = newBase;
      _xpNextLevelThreshold = newNext;
      _isInitialized = true; // Marcar como carregado
      
      debugPrint('--- PARSED VALUES: Level=$_userLevel, XP=$_totalXp, Next=$_xpNextLevelThreshold ---');
      
      final List achievementsList = profileData['achievements'] ?? profileData['Achievements'] ?? [];
      _unlockedCount = achievementsList.length;
      _unlockedIds = achievementsList.map((a) => (a['id'] ?? a['Id']).toString()).toList();

      _stats = UserStats.fromMap(profileData['stats'] ?? profileData['Stats']);
      
      // Busca missões diárias também
      await fetchDailyMissions();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchDailyMissions() async {
    try {
      final data = await _service.getDailyMissions();
      
      _rerollsLeft = (data['rerollsLeft'] ?? data['RerollsLeft'] ?? 0) as int;
      final List rawMissions = data['missions'] ?? data['Missions'] ?? [];
      
      _dailyMissions = rawMissions.map((m) => DailyMission.fromMap(m)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao buscar missões diárias: $e');
    }
  }

  Future<void> rerollMission(String missionId) async {
    try {
      final data = await _service.rerollMission(missionId);
      
      _rerollsLeft = (data['rerollsLeft'] ?? data['RerollsLeft'] ?? 0) as int;
      final List rawMissions = data['missions'] ?? data['Missions'] ?? [];
      
      _dailyMissions = rawMissions.map((m) => DailyMission.fromMap(m)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao trocar missão: $e');
      rethrow;
    }
  }

  Future<void> claimDailyMission(String missionId) async {
    try {
      // 1. CAPTURA ESTADO ATUAL (SNAPSHOT ANTES DA API)
      final int oldLevel = _userLevel;
      final double oldProgress = (_totalXp - _xpCurrentLevelBase) / (_xpNextLevelThreshold - _xpCurrentLevelBase);

      debugPrint('--- INICIANDO CLAIM API: $missionId ---');
      final data = await _service.claimMissionReward(missionId);
      
      // 2. NOVOS DADOS DEFINITIVOS DA API
      final int apiNewLevel = (data['level'] ?? data['Level'] ?? _userLevel) as int;
      final int apiNewTotalXp = (data['totalXp'] ?? data['TotalXp'] ?? _totalXp) as int;
      final int apiNewBase = (data['xpCurrentLevelBase'] ?? data['XpCurrentLevelBase'] ?? _xpCurrentLevelBase) as int;
      final int apiNewNext = (data['xpNextLevelThreshold'] ?? data['XpNextLevelThreshold'] ?? _xpNextLevelThreshold) as int;

      // 3. DETECTA LEVEL UP COM DADOS REAIS
      if (apiNewLevel > oldLevel) {
        final double newProgress = (apiNewTotalXp - apiNewBase) / (apiNewNext - apiNewBase);
        
        debugPrint('--- LEVEL UP DETECTADO (API): Progress $oldProgress -> $newProgress ---');
        _notif?.showLevelUp(oldLevel, oldProgress.clamp(0, 1), apiNewLevel, newProgress.clamp(0, 1));
      }

      // 4. ATUALIZAÇÃO DO ESTADO GLOBAL
      _userLevel = apiNewLevel;
      _totalXp = apiNewTotalXp;
      _xpCurrentLevelBase = apiNewBase;
      _xpNextLevelThreshold = apiNewNext;

      _rerollsLeft = (data['rerollsLeft'] ?? data['RerollsLeft'] ?? 0) as int;
      final List rawMissions = data['missions'] ?? data['Missions'] ?? [];
      _dailyMissions = rawMissions.map((m) => DailyMission.fromMap(m)).toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao coletar recompensa: $e');
      rethrow;
    }
  }
}
