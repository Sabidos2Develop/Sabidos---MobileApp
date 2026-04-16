enum FlashcardDifficulty {
  facil,
  medio,
  dificil,
}

extension FlashcardDifficultyExtension on FlashcardDifficulty {
  String get label {
    switch (this) {
      case FlashcardDifficulty.facil:
        return 'Fácil';
      case FlashcardDifficulty.medio:
        return 'Médio';
      case FlashcardDifficulty.dificil:
        return 'Difícil';
    }
  }

  int get multiplier {
    switch (this) {
      case FlashcardDifficulty.facil:
        return 1;
      case FlashcardDifficulty.medio:
        return 2;
      case FlashcardDifficulty.dificil:
        return 3;
    }
  }
}

class FlashcardModel {
  final String id;
  final String titulo;
  final String frente;
  final String verso;
  final String data;
  final DateTime createdAt;
  final DateTime? atualizadoEm;
  final FlashcardDifficulty dificuldade;

  FlashcardModel({
    required this.id,
    required this.titulo,
    required this.frente,
    required this.verso,
    required this.data,
    required this.createdAt,
    required this.dificuldade,
    this.atualizadoEm,
  });

  FlashcardModel copyWith({
    String? id,
    String? titulo,
    String? frente,
    String? verso,
    String? data,
    DateTime? createdAt,
    DateTime? atualizadoEm,
    FlashcardDifficulty? dificuldade,
  }) {
    return FlashcardModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      frente: frente ?? this.frente,
      verso: verso ?? this.verso,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      dificuldade: dificuldade ?? this.dificuldade,
    );
  }
}

class FlashcardFormData {
  final String titulo;
  final String frente;
  final String verso;
  final FlashcardDifficulty dificuldade;

  FlashcardFormData({
    required this.titulo,
    required this.frente,
    required this.verso,
    required this.dificuldade,
  });
}