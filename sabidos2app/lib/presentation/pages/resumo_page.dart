import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:sabidos2app/domain/models/resumo.dart';

class ResumoPage extends StatefulWidget {
  const ResumoPage({super.key});

  @override
  _ResumoPageState createState() => _ResumoPageState();
}

class _ResumoPageState extends State<ResumoPage> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  bool isListening = false;
  late stt.SpeechToText speech;

  String tamanhoFonte = "base";
  Resumo? selectedResumo;
  Resumo? editingResumo;

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  String get userId => _auth.currentUser?.uid ?? "";

  Stream<List<Resumo>> getResumos() {
    return _db
        .collection('resumos')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => Resumo.fromMap(doc.id, doc.data()))
              .toList();

          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<void> salvarResumo() async {
    if (_tituloController.text.isEmpty || _descricaoController.text.isEmpty) {
      return;
    }

    await _db.collection('resumos').add({
      "userId": userId,
      "titulo": _tituloController.text,
      "descricao": _descricaoController.text,
      "data": formatarData(DateTime.now()),
      "createdAt": DateTime.now().toIso8601String(),
    });

    limparForm();
  }

  Future<void> editarResumo() async {
    if (editingResumo == null) return;

    await _db.collection('resumos').doc(editingResumo!.id).update({
      "titulo": _tituloController.text,
      "descricao": _descricaoController.text,
      "data": formatarData(DateTime.now()),
    });

    setState(() {
      editingResumo = null;
    });

    limparForm();
  }

  Future<void> deletarResumo(String id) async {
    await _db.collection('resumos').doc(id).delete();
  }

  void limparForm() {
    _tituloController.clear();
    _descricaoController.clear();
  }

  String formatarData(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
  }

  void toggleMic() async {
    if (!isListening) {
      bool available = await speech.initialize();
      if (available) {
        setState(() => isListening = true);
        speech.listen(
          localeId: "pt_BR",
          onResult: (result) {
            _descricaoController.text += " ${result.recognizedWords}";
          },
        );
      }
    } else {
      speech.stop();
      setState(() => isListening = false);
    }
  }

  double getFontSize() {
    switch (tamanhoFonte) {
      case "sm":
        return 12;
      case "lg":
        return 20;
      default:
        return 16;
    }
  }

  void alternarFonte() {
    setState(() {
      if (tamanhoFonte == "sm") {
        tamanhoFonte = "base";
      } else if (tamanhoFonte == "base")
        tamanhoFonte = "lg";
      else
        tamanhoFonte = "sm";
    });
  }

  void abrirModal(Resumo r) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Color(0xFF292535),
          child: Container(
            padding: EdgeInsets.all(20),
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  r.titulo,
                  style: TextStyle(
                    color: Color(0xFFFBCA4E),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFFBCA4E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    r.descricao,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: getFontSize(),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: alternarFonte, child: Text("Fonte")),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              editingResumo = r;
                            });
                            Navigator.pop(context);
                          },
                          child: Text("Editar"),
                        ),
                        TextButton(
                          onPressed: () {
                            deletarResumo(r.id);
                            Navigator.pop(context);
                          },
                          child: Text("Excluir"),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1B2A),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            /// 🟡 EDITOR (2/3)
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Color(0xFF292535),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFF423E51)),
                  boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
                ),
                child: Column(
                  children: [
                    /// Título
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        editingResumo != null ? "Editar Resumo" : "Novo Resumo",
                        style: TextStyle(
                          color: Color(0xFFFBCA4E),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    /// INPUT TÍTULO
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF1D1B2A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: TextField(
                        controller: _tituloController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Título do resumo",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    /// TEXTAREA
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF1D1B2A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: TextField(
                          controller: _descricaoController,
                          maxLines: null,
                          expands: true,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Digite o conteúdo...",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    /// BOTÕES
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: toggleMic,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isListening ? Colors.red : Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  isListening ? "Parar 🎤" : "Iniciar 🎤",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: editingResumo != null
                                ? editarResumo
                                : salvarResumo,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Color(0xFFFBCA4E),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "Salvar",
                                  style: TextStyle(
                                    color: Color(0xFF1D1B2A),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 20),

            /// 🟣 SIDEBAR (1/3)
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF292535),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFF423E51)),
                  boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
                ),
                child: Column(
                  children: [
                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Seus Resumos",
                          style: TextStyle(
                            color: Color(0xFFFBCA4E),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    /// LISTA
                    Expanded(
                      child: StreamBuilder<List<Resumo>>(
                        stream: getResumos(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFBCA4E),
                              ),
                            );
                          }

                          final resumos = snapshot.data!;

                          if (resumos.isEmpty) {
                            return Center(
                              child: Text(
                                "Nenhum resumo",
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: resumos.length,
                            itemBuilder: (_, i) {
                              final r = resumos[i];

                              return GestureDetector(
                                onTap: () => abrirModal(r),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  padding: EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF423E51),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border(
                                      left: BorderSide(
                                        color: Colors.pinkAccent,
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.titulo,
                                        style: TextStyle(
                                          color: Color(0xFFFBCA4E),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        r.descricao,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
