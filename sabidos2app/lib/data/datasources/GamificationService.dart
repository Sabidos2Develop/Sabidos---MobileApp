import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/models/user_stats.dart';

class GamificationService {
  final Dio dio = apiClient;

  Future<UserStats> getUserStats() async {
    final response = await dio.get(
      "/gamification/profile",
    );

    return UserStats.fromMap(
      response.data["stats"],
    );
  }
}