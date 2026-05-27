import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/models/user_stats.dart';

class gamefication_service {
  final Dio dio = apiClient;

  Future<Map<String, dynamic>> getUserStats() async {
    final response = await dio.get("/gamification/profile");
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDailyMissions() async {
    final response = await dio.get("/Missions/daily");
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> rerollMission(String id) async {
    final response = await dio.post("/Missions/reroll/$id");
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> claimMissionReward(String id) async {
    final response = await dio.post("/Missions/claim/$id");
    return response.data as Map<String, dynamic>;
  }
}
