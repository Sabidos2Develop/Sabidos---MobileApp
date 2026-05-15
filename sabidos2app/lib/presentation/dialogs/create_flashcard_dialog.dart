import 'package:flutter/material.dart';
import 'package:sabidos2app/domain/models/flashcard_model.dart';

class CreateFlashcardDialog extends StatefulWidget {
  const CreateFlashcardDialog({super.key});

  @override
  State<CreateFlashcardDialog> createState() => _CreateFlashcardDialogState();
}

class _CreateFlashcardDialogState extends State<CreateFlashcardDialog> {
  final _tituloController = TextEditingController();
  final _frenteController = TextEditingController();
  final _versoController = TextEditingController();
  FlashcardDifficulty _dificuldade = FlashcardDifficulty.medio;

  @override
  void dispose() {
    _tituloController.dispose();
    _frenteController.dispose();
    _versoController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _tituloController.text.trim().isNotEmpty &&
      _frenteController.text.trim().isNotEmpty &&
      _versoController.text.trim().isNotEmpty;

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
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Novo Flashcard',
              style: TextStyle(
                color: Color(0xFFFBCB4E),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Align(alignment: Alignment.centerLeft, child: _label('Título do card *')),
          const SizedBox(height: 8),
          TextField(
            controller: _tituloController,
            onChanged: (_) => setState(() {}),
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Ex: Pergunta Rápida'),
          ),
          const SizedBox(height: 18),
          Align(alignment: Alignment.centerLeft, child: _label('Frente (Pergunta) *')),
          const SizedBox(height: 8),
          TextField(
            controller: _frenteController,
            onChanged: (_) => setState(() {}),
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('O que aparecerá primeiro?'),
          ),
          const SizedBox(height: 18),
          Align(alignment: Alignment.centerLeft, child: _label('Verso (Resposta) *')),
          const SizedBox(height: 8),
          TextField(
            controller: _versoController,
            onChanged: (_) => setState(() {}),
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('A resposta correta'),
          ),
          const SizedBox(height: 18),
          Align(alignment: Alignment.centerLeft, child: _label('Dificuldade')),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<FlashcardDifficulty>(
                value: _dificuldade,
                dropdownColor: const Color(0xFF292535),
                isExpanded: true,
                style: const TextStyle(color: Colors.white),
                items: FlashcardDifficulty.values.map((d) {
                  return DropdownMenuItem(
                    value: d,
                    child: Text(d.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _dificuldade = val);
                },
              ),
            ),
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
                  onPressed: _canSave
                      ? () {
                          Navigator.of(context).pop(FlashcardFormData(
                            titulo: _tituloController.text.trim(),
                            frente: _frenteController.text.trim(),
                            verso: _versoController.text.trim(),
                            dificuldade: _dificuldade,
                          ));
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFBCB4E),
                    foregroundColor: const Color(0xFF292535),
                    disabledBackgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
