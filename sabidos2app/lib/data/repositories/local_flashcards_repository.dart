import '../../domain/models/flashcard_collection.dart';
import '../../domain/models/flashcard_model.dart';

class LocalFlashcardsRepository {
  final List<FlashcardCollection> _collections = [];

  Future<List<FlashcardCollection>> getCollections() async {
    await Future.delayed(const Duration(milliseconds: 120));
    return List.from(_collections);
  }

  Future<FlashcardCollection?> getCollectionById(String id) async {
    await Future.delayed(const Duration(milliseconds: 120));
    try {
      return _collections.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addCollection(FlashcardCollection collection) async {
    await Future.delayed(const Duration(milliseconds: 120));
    _collections.add(collection);
  }

  Future<void> deleteCollection(String collectionId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    _collections.removeWhere((c) => c.id == collectionId);
  }

  Future<void> addCardToCollection(
    String collectionId,
    FlashcardModel card,
  ) async {
    await Future.delayed(const Duration(milliseconds: 120));

    final index = _collections.indexWhere((c) => c.id == collectionId);
    if (index == -1) return;

    final updatedCards = List<FlashcardModel>.from(_collections[index].flashcards)
      ..add(card);

    _collections[index] = _collections[index].copyWith(
      flashcards: updatedCards,
    );
  }

  Future<void> updateCardInCollection(
    String collectionId,
    FlashcardModel updatedCard,
  ) async {
    await Future.delayed(const Duration(milliseconds: 120));

    final collectionIndex = _collections.indexWhere((c) => c.id == collectionId);
    if (collectionIndex == -1) return;

    final cards = List<FlashcardModel>.from(_collections[collectionIndex].flashcards);
    final cardIndex = cards.indexWhere((c) => c.id == updatedCard.id);
    if (cardIndex == -1) return;

    cards[cardIndex] = updatedCard;

    _collections[collectionIndex] = _collections[collectionIndex].copyWith(
      flashcards: cards,
    );
  }

  Future<void> deleteCardFromCollection(
    String collectionId,
    String cardId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 120));

    final collectionIndex = _collections.indexWhere((c) => c.id == collectionId);
    if (collectionIndex == -1) return;

    final cards = List<FlashcardModel>.from(_collections[collectionIndex].flashcards)
      ..removeWhere((c) => c.id == cardId);

    _collections[collectionIndex] = _collections[collectionIndex].copyWith(
      flashcards: cards,
    );
  }
}