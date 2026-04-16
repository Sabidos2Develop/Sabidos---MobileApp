import 'package:flutter/material.dart';
import '../../domain/models/flashcard_model.dart';

class EditFlashcardDialog extends StatefulWidget {
  final FlashcardModel card;

  const EditFlashcardDialog({
    super.key,
    required this.card,
  });

  @override
  State<EditFlashcardDialog> createState() => _EditFlashcardDialogState();
}

class _EditFlashcardDialogState extends State<EditFlashcardDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _frontController;
  late final TextEditingController _backController;
  late FlashcardDifficulty _difficulty;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.card.titulo);
    _frontController = TextEditingController(text: widget.card.frente);
    _backController = TextEditingController(text: widget.card.verso);
    _difficulty = widget.card.dificuldade;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _titleController.text.trim().isNotEmpty &&
      _frontController.text.trim().isNotEmpty &&
      _backController.text.trim().isNotEmpty;

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
    return Dialog(
      backgroundColor: const Color(0xFF292535),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Editar Flashcard',
                  style: TextStyle(
                    color: Color(0xFFFBCB4E),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Align(alignment: Alignment.centerLeft, child: _label('Título *')),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Título'),
              ),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerLeft, child: _label('Frente *')),
              const SizedBox(height: 8),
              TextField(
                controller: _frontController,
                onChanged: (_) => setState(() {}),
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Pergunta ou conceito...'),
              ),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerLeft, child: _label('Verso *')),
              const SizedBox(height: 8),
              TextField(
                controller: _backController,
                onChanged: (_) => setState(() {}),
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Resposta correta...'),
              ),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerLeft, child: _label('Dificuldade')),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: FlashcardDifficulty.values.map((difficulty) {
                  final selected = _difficulty == difficulty;
                  return ChoiceChip(
                    label: Text(difficulty.label),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        _difficulty = difficulty;
                      });
                    },
                    selectedColor: const Color(0xFFFBCB4E),
                    backgroundColor: const Color(0xFF1A1A2E),
                    labelStyle: TextStyle(
                      color: selected ? const Color(0xFF292535) : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: selected ? const Color(0xFFFBCB4E) : Colors.white24,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
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
                              Navigator.of(context).pop(
                                FlashcardFormData(
                                  titulo: _titleController.text.trim(),
                                  frente: _frontController.text.trim(),
                                  verso: _backController.text.trim(),
                                  dificuldade: _difficulty,
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
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}