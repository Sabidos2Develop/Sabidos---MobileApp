import 'package:dio/dio.dart';
import '../../domain/models/agenda_event_model.dart';
import '../core/api_client.dart';

class AgendaRepository {
  Future<List<AgendaEventModel>> getEvents() async {
    try {
      final response = await apiClient.get('/Agenda');
      final data = response.data as List;
      
      return data.map((e) => AgendaEventModel.fromJson(e)).toList();
    } catch (e) {
      print('Erro ao buscar eventos: $e');
      return [];
    }
  }

  Future<void> addEvent(String title, DateTime date) async {
    try {
      await apiClient.post('/Agenda', data: {
        'title': title,
        'date': date.toIso8601String(),
      });
    } on DioException catch (e) {
      print('ERRO DA API (Status ${e.response?.statusCode}): ${e.response?.data}');
      throw Exception('Falha ao adicionar evento: ${e.response?.data}');
    }
  }

  Future<void> updateEvent(String id, String title, DateTime date) async {
    try {
      await apiClient.put('/Agenda/$id', data: {
        'title': title,
        'date': date.toIso8601String(),
      });
    } on DioException catch (e) {
      print('ERRO DA API (Status ${e.response?.statusCode}): ${e.response?.data}');
      throw Exception('Falha ao atualizar evento: ${e.response?.data}');
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await apiClient.delete('/Agenda/$id');
    } on DioException catch (e) {
      print('ERRO DA API (Status ${e.response?.statusCode}): ${e.response?.data}');
      throw Exception('Falha ao deletar evento: ${e.response?.data}');
    }
  }
}
