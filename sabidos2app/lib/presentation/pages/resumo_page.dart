import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/resumo_controller.dart';
import '../../domain/models/resumo.dart';

class ResumoPage extends StatefulWidget {
  const ResumoPage({super.key});

  @override
  State<ResumoPage> createState() => _ResumoPageState();
}

class _ResumoPageState extends State<ResumoPage> {
  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Future.microtask(() {
        context.read<ResumoController>().listenResumos(user.uid);
      });
    }
  }

  void salvar() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final resumo = Resumo(
      id: "",
      titulo: tituloController.text,
      descricao: descricaoController.text,
      data: DateTime.now().toString(),
      userId: user.uid,
      createdAt: DateTime.now().toIso8601String(),
    );

    await context.read<ResumoController>().addResumo(resumo);

    tituloController.clear();
    descricaoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ResumoController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Resumos")),
      body: Row(
        children: [
          /// EDITOR
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: tituloController,
                    decoration: const InputDecoration(labelText: "Título"),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: TextField(
                      controller: descricaoController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(labelText: "Descrição"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: salvar,
                    child: const Text("Salvar"),
                  ),
                ],
              ),
            ),
          ),

          /// LISTA
          Expanded(
            child: controller.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: controller.resumos.length,
                    itemBuilder: (context, index) {
                      final resumo = controller.resumos[index];

                      return ListTile(
                        title: Text(resumo.titulo),
                        subtitle: Text(resumo.descricao, maxLines: 2),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            controller.deleteResumo(resumo.id);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
