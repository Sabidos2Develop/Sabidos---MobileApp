import 'package:flutter/material.dart';
import '../../domain/models/resumo.dart';
import '../../data/datasources/resumo_service.dart';

class ResumoController extends ChangeNotifier {
  final ResumoService _service;

  List<Resumo> _resumos = [];
  bool _isLoading = false;
  String _error = '';

  ResumoController(this._service);

  List<Resumo> get resumos => _resumos;
  bool get isLoading => _isLoading;
  String get error => _error;

  void listenToResumos(String userId) {
    _isLoading = true;
    _error = '';
    notifyListeners();

    _service.getResumos(userId).listen((data) {
      _resumos = data;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _error = 'Erro ao carregar resumos';
      _isLoading = false;
      notifyListeners();
      debugPrint('Erro no ResumoController: $e');
    });
  }

  Future<void> addResumo(Resumo resumo, {BuildContext? context}) async {
    await _service.addResumo(resumo, context: context);
  }

  Future<void> deleteResumo(String id) async {
    await _service.deleteResumo(id);
  }

  Future<void> updateResumo(Resumo resumo) async {
    await _service.updateResumo(resumo);
  }
}
