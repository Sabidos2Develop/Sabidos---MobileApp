import 'package:sabidos2app/domain/models/flashcard_collection.dart';
import 'package:sabidos2app/domain/models/flashcard_model.dart';
import 'package:sabidos2app/data/core/api_client.dart';

class ApiFlashcardsRepository {
  FlashcardModel _mapCard(dynamic c) {
    return FlashcardModel(
      id: c['id'],
      titulo: c['front'].toString().split('\n').first,
      frente: c['front'],
      verso: c['back'],
      data: c['createdAt'],
      createdAt: DateTime.parse(c['createdAt']),
      dificuldade: FlashcardDifficulty.medio,
    );
  }

  Future<List<FlashcardCollection>> getCollections() async {
    try {
      final response = await apiClient.get('/FlashcardCollection');
      final data = response.data as List;
      
      List<FlashcardCollection> colecoes = [];
      for (var item in data) {
        colecoes.add(FlashcardCollection(
          id: item['id'],
          titulo: item['name'],
          descricao: item['color'] ?? '',
          criadoEm: DateTime.parse(item['createdAt']),
          flashcards: [], // Não carrega os cards aqui para ser rápido
        ));
      }
      return colecoes;
    } catch (e) {
      print('Erro getCollections: $e'); return [];
    }
  }

  Future<FlashcardCollection?> getCollectionById(String id) async {
    try {
      // 1. Pega os dados da coleção
      final collRes = await apiClient.get('/FlashcardCollection/$id');
      final item = collRes.data;

      // 2. Pega os cards dessa coleção especificamente
      final cardsRes = await apiClient.get('/Flashcard/collection/$id');
      final cardsData = cardsRes.data as List;
      
      List<FlashcardModel> cartas = cardsData.map((c) => _mapCard(c)).toList();
      
      return FlashcardCollection(
        id: item['id'],
        titulo: item['name'],
        descricao: item['color'] ?? '',
        criadoEm: DateTime.parse(item['createdAt']),
        flashcards: cartas,
      );
    } catch (e) { 
      print('ERRO getCollectionById: $e'); 
      return null; 
    }
  }

  Future<void> addCollection(FlashcardCollection collection) async {
    try {
      await apiClient.post('/FlashcardCollection', data: {
        'name': collection.titulo,
        'color': collection.descricao,
      });
    } catch (e) { print('ERRO FATAL API: $e'); throw Exception(e); }
  }

  Future<void> deleteCollection(String collectionId) async {
    try {
      await apiClient.delete('/FlashcardCollection/$collectionId');
    } catch (e) { print('ERRO FATAL API: $e'); throw Exception(e); }
  }

  Future<void> addCardToCollection(
    String collectionId,
    FlashcardModel card,
  ) async {
    try {
      await apiClient.post('/Flashcard', data: {
        'collectionId': collectionId,
        'front': card.frente,
        'back': card.verso,
      });
    } catch (e) { print('ERRO FATAL API: $e'); throw Exception(e); }
  }

  Future<void> updateCardInCollection(
    String collectionId,
    FlashcardModel updatedCard,
  ) async {}

  Future<void> deleteCardFromCollection(
    String collectionId,
    String cardId,
  ) async {
    try {
      await apiClient.delete('/Flashcard/$cardId');
    } catch (e) { print('ERRO FATAL API: $e'); throw Exception(e); }
  }
}