import '../../domain/models/flashcard_collection.dart';
import '../../domain/models/flashcard_model.dart';
import '../core/api_client.dart';

class ApiFlashcardsRepository {
  Future<List<FlashcardCollection>> getCollections() async {
    try {
      final response = await apiClient.get('/FlashcardCollection');
      final data = response.data as List;
      
      List<FlashcardCollection> colecoes = [];
      
      for (var item in data) {
        final flashcardsResponse = await apiClient.get('/Flashcard/collection/${item['id']}');
        final flashcardsData = flashcardsResponse.data as List;
        
        List<FlashcardModel> cartas = flashcardsData.map((c) => FlashcardModel(
          id: c['id'],
          titulo: c['front'].toString().split('\n').first,
          frente: c['front'],
          verso: c['back'],
          data: c['createdAt'],
          createdAt: DateTime.parse(c['createdAt']),
          dificuldade: FlashcardDifficulty.medio,
        )).toList();
        
        colecoes.add(FlashcardCollection(
          id: item['id'],
          titulo: item['name'],
          descricao: item['color'],
          criadoEm: DateTime.parse(item['createdAt']),
          flashcards: cartas,
        ));
      }
      
      return colecoes;
    } catch (e) {
      print('Erro: $e'); return [];
    }
  }

  Future<FlashcardCollection?> getCollectionById(String id) async {
    final colecoes = await getCollections();
    try {
      return colecoes.firstWhere((c) => c.id == id);
    } catch (e) { print('ERRO FATAL API GET: $e'); return null; }
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