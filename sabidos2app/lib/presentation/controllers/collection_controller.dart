import 'package:flutter/material.dart';
import '../../domain/models/flashcard_collection.dart';
import '../../data/repositories/api_flashcards_repository.dart';

class CollectionController extends ChangeNotifier {
  final ApiFlashcardsRepository _repository = ApiFlashcardsRepository();

  List<FlashcardCollection> _collections = [];
  bool _isLoading = false;
  String _error = '';

  List<FlashcardCollection> get collections => _collections;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadCollections() async {
    // Se já estiver carregando, não faz nada
    if (_isLoading) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final data = await _repository.getCollections();
      _collections = data;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar coleções';
      _isLoading = false;
      notifyListeners();
      debugPrint('Erro no CollectionController: $e');
    }
  }

  // Métodos auxiliares para atualizar o estado local sem recarregar tudo da API
  void addLocalCollection(FlashcardCollection collection) {
    _collections.add(collection);
    notifyListeners();
  }

  void removeLocalCollection(String id) {
    _collections.removeWhere((c) => id == c.id);
    notifyListeners();
  }
}
