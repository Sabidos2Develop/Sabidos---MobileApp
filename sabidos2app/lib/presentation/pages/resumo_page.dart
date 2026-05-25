import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:sabidos2app/domain/models/resumo.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';



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
  String recognizedWords = ""; // Para evitar duplicação
  String lastFinalResult = "";

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
      // 🎤 Pedir permissão de microfone
      final status = await Permission.microphone.request();

      if (status.isDenied) {
        // Permissão negada
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de microfone negada')),
        );
        return;
      }

      if (status.isPermanentlyDenied) {
        // Permissão permanentemente negada, abrir configurações
        openAppSettings();
        return;
      }

      bool available = await speech.initialize(
        onError: (error) {
          print('Erro de fala: $error');
          setState(() => isListening = false);
        },
        onStatus: (status) {
          print('Status de fala: $status');
        },
      );

      if (available) {
        setState(() {
          isListening = true;
          recognizedWords = ""; // Limpar palavras anteriores
          lastFinalResult = "";
        });

        speech.listen(
          localeId: "pt_BR",
          listenMode: stt.ListenMode.dictation,
          listenFor: const Duration(minutes: 10),
          pauseFor: const Duration(seconds: 10),
          onResult: (result) {
            setState(() {
              if (result.finalResult) {
                final newText = result.recognizedWords.trim();
                if (newText.isNotEmpty) {
                  final current = _descricaoController.text.trim();
                  if (lastFinalResult.isNotEmpty &&
                      current.endsWith(lastFinalResult)) {
                    final updated = current
                        .substring(0, current.length - lastFinalResult.length)
                        .trimRight();
                    _descricaoController.text = [
                      updated,
                      newText,
                    ].where((e) => e.isNotEmpty).join(' ');
                  } else {
                    _descricaoController.text = [
                      current,
                      newText,
                    ].where((e) => e.isNotEmpty).join(' ');
                  }
                  lastFinalResult = newText;
                }
              } else {
                recognizedWords = result.recognizedWords;
              }
            });
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech to text não disponível')),
        );
        setState(() => isListening = false);
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

  // 🌟 Ajuste: Configuração assíncrona da voz e handlers de estado
  void configurarVoz() async {
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    // Atualiza o estado da UI quando a fala começar ou terminar
    flutterTts.setStartHandler(() {
      setState(() => isSpeaking = true);
    });

    flutterTts.setCompletionHandler(() {
      setState(() => isSpeaking = false);
    });

    flutterTts.setCancelHandler(() {
      setState(() => isSpeaking = false);
    });
  }

  // 🌟 Ajuste: Alterna entre falar e parar a voz
  void toggleLeitura(String texto) async {
    if (isSpeaking) {
      await flutterTts.stop();
    } else {
      if (texto.isNotEmpty) {
        await flutterTts.speak(texto);
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    speech.stop(); // Parar de escutar
    flutterTts.stop(); // 🌟 Evita vazamento de memória e áudio fantasma
    super.dispose();
  }

  void abrirModal(Resumo r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF292535),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Color(0xFF423E51)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                r.titulo,
                style: const TextStyle(
                  color: Color(0xFFFBCA4E),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF423E51)),
                ),
                child: Text(
                  r.descricao,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: getFontSize(),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      alternarFonte();
                      Navigator.pop(context);
                      abrirModal(r);
                    },
                    icon: const Icon(Icons.format_size),
                    label: const Text("Fonte"),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white70),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            editingResumo = r;
                            _tituloController.text = r.titulo;
                            _descricaoController.text = r.descricao;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Editar", style: TextStyle(color: Colors.blueAccent)),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                              onPressed: () async {
                                toggleLeitura(r.descricao);
                                // Pequeno delay para sincronizar o estado visual do botão no modal
                                await Future.delayed(
                                  const Duration(milliseconds: 100),
                                );
                                setModalState(() {});
                              },
                              // 🌟 Muda dinamicamente o texto com base no estado da fala
                              child: Text(isSpeaking ? "Parar" : "Ouvir"),
                            ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          deletarResumo(r.id);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        child: const Text("Excluir", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1B2A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                // Layout Vertical para Mobile
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildEditor(isMobile: true),
                      const SizedBox(height: 20),
                      _buildSidebar(isMobile: true),
                    ],
                  ),
                );
              } else {
                // Layout Horizontal para Desktop
                return Row(
                  children: [
                    Expanded(flex: 2, child: _buildEditor()),
                    const SizedBox(width: 20),
                    Expanded(flex: 1, child: _buildSidebar()),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEditor({bool isMobile = false}) {
    return Container(
      height: isMobile ? 500 : double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF292535),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF423E51)),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              editingResumo != null ? "Editar Resumo" : "Novo Resumo",
              style: const TextStyle(
                color: Color(0xFFFBCA4E),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1D1B2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: TextField(
              controller: _tituloController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Título do resumo",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1D1B2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: TextField(
                controller: _descricaoController,
                maxLines: null,
                expands: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Digite o conteúdo...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Expanded(
              //   child: GestureDetector(
              //     onTap: toggleMic,
              //     child: Container(
              //       padding: const EdgeInsets.symmetric(vertical: 14),
              //       decoration: BoxDecoration(
              //         color: isListening ? Colors.red : Colors.green,
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //       child: Center(
              //         child: Text(
              //           isListening ? "Parar 🎤" : "Iniciar 🎤",
              //           style: const TextStyle(color: Colors.white),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            IconButton(
                      icon: Icon(
                        isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.yellow,
                      ),
                      onPressed: toggleMic,
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: editingResumo != null ? editarResumo : salvarResumo,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBCA4E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
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
    );
  }

  Widget _buildSidebar({bool isMobile = false}) {
    return Container(
      height: isMobile ? 400 : double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF292535),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF423E51)),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Seus Resumos",
                  style: TextStyle(
                    color: Color(0xFFFBCA4E),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<Resumo>>(
              stream: getResumos(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFBCA4E)),
                  );
                }
                final resumos = snapshot.data!;
                if (resumos.isEmpty) {
                  return const Center(
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
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF423E51),
                          borderRadius: BorderRadius.circular(12),
                          border: const Border(
                            left: BorderSide(
                              color: Colors.pinkAccent,
                              width: 4,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.titulo,
                              style: const TextStyle(
                                color: Color(0xFFFBCA4E),
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              r.descricao,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
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
    );
  }
}
