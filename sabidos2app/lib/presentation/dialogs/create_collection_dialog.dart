import 'package:flutter/material.dart';
import 'package:sabidos2app/domain/models/flashcard_collection.dart';

class CreateCollectionDialog extends StatefulWidget {
  const CreateCollectionDialog({super.key});

  @override
  State<CreateCollectionDialog> createState() => _CreateCollectionDialogState();
}

class _CreateCollectionDialogState extends State<CreateCollectionDialog> {
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  bool get _canCreate => _tituloController.text.trim().isNotEmpty;

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF1A1A2E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFBCB4E), width: 2),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFFBCB4E),
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom:
              MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom +
              24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nova Coleção',
                style: TextStyle(
                  color: Color(0xFFFBCB4E),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: _label('Título da coleção *'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tituloController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Ex: Anatomia Humana'),
            ),

            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: _label('Descrição (opcional)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descricaoController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('O que você vai estudar aqui?'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canCreate
                        ? () {
                            Navigator.of(context).pop(
                              CollectionFormData(
                                titulo: _tituloController.text.trim(),
                                descricao: _descricaoController.text.trim(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFBCB4E),
                      foregroundColor: const Color(0xFF292535),
                      disabledBackgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Criar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
