import 'package:flutter/material.dart';
import '../../domain/models/agenda_event_model.dart';
import '../../data/repositories/agenda_repository.dart';

class AgendaController extends ChangeNotifier {
  final AgendaRepository _repository = AgendaRepository();

  List<AgendaEventModel> _events = [];
  bool _isLoading = false;
  String _error = '';

  List<AgendaEventModel> get events => _events;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadEvents() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final data = await _repository.getEvents();
      _events = data;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar agenda';
      _isLoading = false;
      notifyListeners();
      debugPrint('Erro no AgendaController: $e');
    }
  }

  void addLocalEvent(AgendaEventModel event) {
    _events.add(event);
    notifyListeners();
  }

  Future<void> addEvent(String title, DateTime date, {BuildContext? context}) async {
    await _repository.addEvent(title, date, context: context);
    await loadEvents(); // Recarrega a lista para garantir sincronia
  }
}
