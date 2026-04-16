import './flashcard_model.dart';

class FlashcardCollection {
  final String id;
  final String titulo;
  final String descricao;
  final DateTime criadoEm;
  final List<FlashcardModel> flashcards;

  FlashcardCollection({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.criadoEm,
    required this.flashcards,
  });

  FlashcardCollection copyWith({
    String? id,
    String? titulo,
    String? descricao,
    DateTime? criadoEm,
    List<FlashcardModel>? flashcards,
  }) {
    return FlashcardCollection(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      criadoEm: criadoEm ?? this.criadoEm,
      flashcards: flashcards ?? this.flashcards,
    );
  }
}

class CollectionFormData {
  final String titulo;
  final String descricao;

  CollectionFormData({
    required this.titulo,
    required this.descricao,
  });
}