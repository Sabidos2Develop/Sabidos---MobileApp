import 'package:dio/dio.dart';
import 'package:sabidos2app/domain/models/User.dart';
import 'package:sabidos2app/domain/models/Evento.dart';
import 'package:sabidos2app/domain/models/Pomodoro.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://sua-api.com',
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<Response> get(String path) async {
    return await _dio.get(path);
  }

  Future<Response> post(String path, dynamic data) async {
    return await _dio.post(path, data: data);
  }
}

class UserApiService {
  final Dio _dio;

  UserApiService(this._dio);

  // 🔍 VALIDATE LOGIN
  Future<User?> validateLogin(String firebaseUid) async {
    final response = await _dio.post(
      '/api/user/validate-login',
      data: {'firebaseUid': firebaseUid},
    );

    if (response.data['success'] == true) {
      return User.fromJson(response.data['user']);
    }

    return null;
  }

  // 🔄 SYNC USER
  Future<User> syncUser({
    required String firebaseUid,
    required String email,
    required String name,
  }) async {
    final response = await _dio.post(
      '/api/user/sync',
      data: {'firebaseUid': firebaseUid, 'email': email, 'name': name},
    );

    return User.fromJson(response.data);
  }
}

class EventoApiService {
  final Dio _dio;

  EventoApiService(this._dio);

  Future<List<EventoModel>> getUserEventos(String firebaseUid) async {
    final response = await _dio.post(
      '/api/eventos/user',
      data: {'firebaseUid': firebaseUid},
    );

    if (response.data['success'] == true) {
      final List list = response.data['data'];
      return list.map((e) => EventoModel.fromJson(e)).toList();
    }

    throw Exception(response.data['message']);
  }

  Future<EventoModel> createEvento({
    required String firebaseUid,
    required Map<String, dynamic> eventoData,
  }) async {
    final response = await _dio.post(
      '/api/eventos',
      data: {'firebaseUid': firebaseUid, 'eventoData': eventoData},
    );

    if (response.data['success']) {
      return EventoModel.fromJson(response.data['data']);
    }

    throw Exception(response.data['message']);
  }

  Future<void> deleteEvento(int id, String firebaseUid) async {
    final response = await _dio.delete(
      '/api/eventos/$id',
      data: {'firebaseUid': firebaseUid},
    );

    if (!response.data['success']) {
      throw Exception(response.data['message']);
    }
  }

  Future<EventoModel> updateEvento({
    required int id,
    required String firebaseUid,
    required Map<String, dynamic> eventoData,
  }) async {
    final response = await _dio.put(
      '/api/eventos/$id',
      data: {'firebaseUid': firebaseUid, 'eventoData': eventoData},
    );

    if (response.data['success']) {
      return EventoModel.fromJson(response.data['data']);
    }

    throw Exception(response.data['message']);
  }
}

class PomodoroApiService {
  final Dio _dio;

  PomodoroApiService(this._dio);

  // 🔍 GET ALL (precisa token se backend estiver configurado)
  Future<List<PomodoroModel>> getAll(String firebaseUid) async {
    final response = await _dio.get(
      '/api/pomodoro',
      // ⚠️ Se não tiver autenticação real, isso pode falhar
    );

    final List data = response.data;
    return data.map((e) => PomodoroModel.fromJson(e)).toList();
  }

  // ⏱️ COUNT TIME
  Future<int> countTime(String firebaseUid) async {
    final response = await _dio.get(
      '/api/pomodoro/count-time',
      queryParameters: {'firebaseUid': firebaseUid},
    );

    return response.data;
  }

  // ➕ CREATE
  Future<PomodoroModel> create({
    required String firebaseUid,
    required Map<String, dynamic> pomodoroData,
  }) async {
    final response = await _dio.post(
      '/api/pomodoro',
      data: {'firebaseUid': firebaseUid, 'pomodoroData': pomodoroData},
    );

    return PomodoroModel.fromJson(response.data);
  }
}
