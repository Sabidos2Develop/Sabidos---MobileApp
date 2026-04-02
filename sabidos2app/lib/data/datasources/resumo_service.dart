import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/resumo.dart';

class ResumoService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Resumo>> getResumos(String userId) {
    return _db
        .collection("resumos")
        .where("userId", isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Resumo.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  Future<void> addResumo(Resumo resumo) async {
    await _db.collection("resumos").add(resumo.toMap());
  }

  Future<void> deleteResumo(String id) async {
    await _db.collection("resumos").doc(id).delete();
  }

  Future<void> updateResumo(Resumo resumo) async {
    await _db.collection("resumos").doc(resumo.id).update(resumo.toMap());
  }
}
