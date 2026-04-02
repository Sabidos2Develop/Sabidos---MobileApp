import 'package:flutter/material.dart';
import '../../domain/models/resumo.dart';
import '../../data/datasources/resumo_service.dart';

class ResumoController extends ChangeNotifier {
  final ResumoService service;

  ResumoController(this.service);

  List<Resumo> resumos = [];
  bool loading = false;

  void listenResumos(String userId) {
    loading = true;
    notifyListeners();

    service.getResumos(userId).listen((data) {
      resumos = data;
      loading = false;
      notifyListeners();
    });
  }

  Future<void> addResumo(Resumo resumo) async {
    await service.addResumo(resumo);
  }

  Future<void> deleteResumo(String id) async {
    await service.deleteResumo(id);
  }

  Future<void> updateResumo(Resumo resumo) async {
    await service.updateResumo(resumo);
  }
}
