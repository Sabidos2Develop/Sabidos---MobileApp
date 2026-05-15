import 'package:dio/dio.dart';
import 'package:sabidos2app/domain/models/earn_response.dart';
import 'package:sabidos2app/domain/models/user_progress.dart';

class PointsService {
  final Dio _dio;

  PointsService(this._dio);

  Future<EarnResponse> earnPoints({
    required String action,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.post(
      "/points/earn",
      data: {"action": action, "data": data},
    );

    return EarnResponse.fromJson(response.data);
  }

  Future<UserProgress> getMyProgress() async {
    final response = await _dio.get("/points/me");

    return UserProgress.fromJson(response.data);
  }
}







// await http.post(
//   Uri.parse("https://sua-api/points/earn"),
//   headers: {
//     "Authorization": "Bearer $tokenFirebase"
//   },
//   body: jsonEncode({
//     "action": "Flashcard",
//     "data": {
//       "correct": true,
//       "difficulty": "MEDIO"
//     }
//   }),
// );