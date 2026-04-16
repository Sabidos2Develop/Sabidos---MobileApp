import 'package:flutter/material.dart';

class FlashcardsPage extends StatefulWidget {
  const FlashcardsPage({super.key});

  @override
  State<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();

  final Set<String> _flippedCards = {};
  final LocalFlashcardRepository _localRepository = LocalFlashcardRepository();

  List<FlashcardModel> _flashcards = [];
  bool _loading = false;
  String _error = '';
  FlashcardModel? _editingFlashcard;

  @override
  void initState() {
    super.initState();
    _loadLocalFlashcards();

    _titleController.addListener(() => setState(() {}));
    _frontController.addListener(() => setState(() {}));
    _backController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalFlashcards() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final cards = await _localRepository.getFlashcards();
      cards.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _flashcards = cards;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Falha ao carregar flashcards locais.';
        _loading = false;
      });
    }
  }

  void _resetForm() {
    _titleController.clear();
    _frontController.clear();
    _backController.clear();
    _editingFlashcard = null;
  }

  bool _validateForm() {
    if (_titleController.text.trim().isEmpty ||
        _frontController.text.trim().isEmpty ||
        _backController.text.trim().isEmpty) {
      setState(() {
        _error = 'Todos os campos são obrigatórios.';
      });
      return false;
    }
    return true;
  }

  Future<void> _createFlashcard() async {
    if (!_validateForm()) return;

    try {
      setState(() => _error = '');

      final newCard = FlashcardModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        titulo: _titleController.text.trim(),
        frente: _frontController.text.trim(),
        verso: _backController.text.trim(),
        data: _formatShortDate(DateTime.now()),
        createdAt: DateTime.now(),
        atualizadoEm: null,
      );

      await _localRepository.addFlashcard(newCard);
      await _loadLocalFlashcards();

      _resetForm();

      if (mounted) {
        Navigator.pop(context);
        _showSnack('Flashcard criado com sucesso!');
      }
    } catch (e) {
      setState(() {
        _error = 'Ocorreu um erro ao salvar o flashcard.';
      });
    }
  }

  Future<void> _updateFlashcard() async {
    if (!_validateForm() || _editingFlashcard == null) return;

    try {
      setState(() => _error = '');

      final updatedCard = _editingFlashcard!.copyWith(
        titulo: _titleController.text.trim(),
        frente: _frontController.text.trim(),
        verso: _backController.text.trim(),
        data: _formatShortDate(DateTime.now()),
        atualizadoEm: DateTime.now(),
      );

      await _localRepository.updateFlashcard(updatedCard);
      await _loadLocalFlashcards();

      _resetForm();

      if (mounted) {
        Navigator.pop(context);
        _showSnack('Flashcard atualizado com sucesso!');
      }
    } catch (e) {
      setState(() {
        _error = 'Ocorreu um erro ao editar o flashcard.';
      });
    }
  }

  Future<void> _deleteFlashcard(String flashcardId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF292535),
        title: const Text(
          'Excluir flashcard',
          style: TextStyle(color: Color(0xFFFBCB4E)),
        ),
        content: const Text(
          'Tem certeza que deseja excluir este flashcard?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFBCB4E),
              foregroundColor: const Color(0xFF292535),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _localRepository.deleteFlashcard(flashcardId);
      await _loadLocalFlashcards();

      if (mounted) {
        _showSnack('Flashcard excluído.');
      }
    } catch (e) {
      setState(() {
        _error = 'Ocorreu um erro ao excluir o flashcard.';
      });
    }
  }

  void _toggleFlip(String flashcardId) {
    setState(() {
      if (_flippedCards.contains(flashcardId)) {
        _flippedCards.remove(flashcardId);
      } else {
        _flippedCards.add(flashcardId);
      }
    });
  }

  void _openDetailsBottomSheet(FlashcardModel card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF292535),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.82,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      card.titulo,
                      style: const TextStyle(
                        color: Color(0xFFFBCB4E),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _detailBlock('Frente', card.frente),
                    const SizedBox(height: 16),
                    _detailBlock('Verso', card.verso),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Criado em: ${_formatFullDate(card.createdAt)}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _handleEditClick(card);
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Editar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blueAccent,
                              side: const BorderSide(color: Colors.blueAccent),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _deleteFlashcard(card.id);
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Excluir'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleEditClick(FlashcardModel flashcard) {
    _editingFlashcard = flashcard;
    _titleController.text = flashcard.titulo;
    _frontController.text = flashcard.frente;
    _backController.text = flashcard.verso;

    _showEditDialog();
  }

  String _formatShortDate(DateTime date) {
    final dia = date.day.toString().padLeft(2, '0');
    final mes = date.month.toString().padLeft(2, '0');
    return '$dia/$mes';
  }

  String _formatFullDate(DateTime date) {
    final dia = date.day.toString().padLeft(2, '0');
    final mes = date.month.toString().padLeft(2, '0');
    final ano = date.year.toString();
    return '$dia/$mes/$ano';
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2A2438),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showCreateConfirmDialog() {
    if (!_validateForm()) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF292535),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confirmar Flashcard',
                  style: TextStyle(
                    color: Color(0xFFFBCB4E),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(12),
                    border: const Border(
                      left: BorderSide(color: Color(0xFFFBCB4E), width: 4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titleController.text.trim(),
                        style: const TextStyle(
                          color: Color(0xFFFBCB4E),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Frente:',
                        style: TextStyle(
                          color: Color(0xFFEBB2B6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _previewTextBox(_frontController.text.trim()),
                      const SizedBox(height: 10),
                      const Text(
                        'Verso:',
                        style: TextStyle(
                          color: Color(0xFFEBB2B6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _previewTextBox(_backController.text.trim()),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
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
                        onPressed: _createFlashcard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFBCB4E),
                          foregroundColor: const Color(0xFF292535),
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
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF292535),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Editar Flashcard',
                  style: TextStyle(
                    color: Color(0xFFFBCB4E),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: 'Título *',
                  controller: _titleController,
                  hint: 'Ex: Fórmula de Bhaskara',
                  maxLength: 50,
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  label: 'Frente *',
                  controller: _frontController,
                  hint: 'Pergunta ou conceito...',
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  label: 'Verso *',
                  controller: _backController,
                  hint: 'Resposta ou explicação...',
                  maxLines: 4,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _resetForm();
                        },
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
                        onPressed: _updateFlashcard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFBCB4E),
                          foregroundColor: const Color(0xFF292535),
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
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFFBCB4E),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF1A1A2E),
            counterStyle: const TextStyle(color: Colors.white54),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
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
              borderSide: const BorderSide(
                color: Color(0xFFFBCB4E),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _previewTextBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2438),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _detailBlock(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFEBB2B6),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  bool get _canCreate =>
      _titleController.text.trim().isNotEmpty &&
      _frontController.text.trim().isNotEmpty &&
      _backController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171621),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171621),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Flashcards',
          style: TextStyle(
            color: Color(0xFFFBCB4E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFFBCB4E),
          backgroundColor: const Color(0xFF292535),
          onRefresh: _loadLocalFlashcards,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _buildEditorPanel(),
              const SizedBox(height: 16),
              _buildListPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditorPanel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF292535),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MobileSectionHeader(title: 'Criar Flashcard'),
          const SizedBox(height: 16),
          _buildInputField(
            label: 'Título *',
            controller: _titleController,
            hint: 'Ex: Fórmula de Bhaskara',
            maxLength: 50,
          ),
          const SizedBox(height: 10),
          _buildInputField(
            label: 'Frente *',
            controller: _frontController,
            hint: 'Pergunta ou conceito...',
            maxLines: 4,
          ),
          const SizedBox(height: 10),
          _buildInputField(
            label: 'Verso *',
            controller: _backController,
            hint: 'Resposta ou explicação...',
            maxLines: 4,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canCreate ? _showCreateConfirmDialog : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFBCB4E),
                foregroundColor: const Color(0xFF292535),
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Criar Flashcard',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(14),
              border: const Border(
                left: BorderSide(color: Color(0xFF3085AA), width: 4),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 Dicas',
                  style: TextStyle(
                    color: Color(0xFF3085AA),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Use perguntas objetivas na frente\n'
                  '• Respostas claras no verso\n'
                  '• Revise regularmente',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // SQL FUTURO:
          // Este painel pode permanecer igual.
          // A troca será apenas nos métodos que hoje usam o repositório local.
        ],
      ),
    );
  }

  Widget _buildListPanel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF292535),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: _MobileSectionHeader(title: 'Meus Flashcards'),
              ),
              const SizedBox(width: 12),
              Text(
                '${_flashcards.length} card(s)',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent),
              ),
              child: Text(
                _error,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFBCB4E),
                ),
              ),
            )
          else if (_flashcards.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Column(
                children: [
                  Text(
                    '🃏',
                    style: TextStyle(fontSize: 52),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Nenhum flashcard encontrado.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Crie seu primeiro card acima.',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              itemCount: _flashcards.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final flashcard = _flashcards[index];
                final isFlipped = _flippedCards.contains(flashcard.id);

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _openDetailsBottomSheet(flashcard),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isFlipped
                          ? const Color(0xFF2A2438)
                          : const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(18),
                      border: const Border(
                        left: BorderSide(
                          color: Color(0xFFFBCB4E),
                          width: 4,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                flashcard.titulo,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFFBCB4E),
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                flashcard.data,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isFlipped ? flashcard.verso : flashcard.frente,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _smallActionButton(
                              icon: Icons.sync,
                              label: isFlipped ? 'Frente' : 'Verso',
                              color: Colors.lightBlueAccent,
                              onTap: () => _toggleFlip(flashcard.id),
                            ),
                            _smallActionButton(
                              icon: Icons.edit,
                              label: 'Editar',
                              color: Colors.blueAccent,
                              onTap: () => _handleEditClick(flashcard),
                            ),
                            _smallActionButton(
                              icon: Icons.delete,
                              label: 'Excluir',
                              color: Colors.redAccent,
                              onTap: () => _deleteFlashcard(flashcard.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _smallActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileSectionHeader extends StatelessWidget {
  final String title;

  const _MobileSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFFBCB4E),
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFFBCB4E),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class FlashcardModel {
  final String id;
  final String titulo;
  final String frente;
  final String verso;
  final String data;
  final DateTime createdAt;
  final DateTime? atualizadoEm;

  FlashcardModel({
    required this.id,
    required this.titulo,
    required this.frente,
    required this.verso,
    required this.data,
    required this.createdAt,
    this.atualizadoEm,
  });

  FlashcardModel copyWith({
    String? id,
    String? titulo,
    String? frente,
    String? verso,
    String? data,
    DateTime? createdAt,
    DateTime? atualizadoEm,
  }) {
    return FlashcardModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      frente: frente ?? this.frente,
      verso: verso ?? this.verso,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'frente': frente,
      'verso': verso,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
    };
  }

  factory FlashcardModel.fromMap(Map<String, dynamic> map) {
    return FlashcardModel(
      id: map['id'],
      titulo: map['titulo'],
      frente: map['frente'],
      verso: map['verso'],
      data: map['data'],
      createdAt: DateTime.parse(map['createdAt']),
      atualizadoEm: map['atualizadoEm'] != null
          ? DateTime.parse(map['atualizadoEm'])
          : null,
    );
  }
}

class LocalFlashcardRepository {
  final List<FlashcardModel> _memoryDb = [];

  Future<List<FlashcardModel>> getFlashcards() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.from(_memoryDb);
  }

  Future<void> addFlashcard(FlashcardModel card) async {
    await Future.delayed(const Duration(milliseconds: 120));
    _memoryDb.add(card);
  }

  Future<void> updateFlashcard(FlashcardModel updatedCard) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final index = _memoryDb.indexWhere((item) => item.id == updatedCard.id);
    if (index != -1) {
      _memoryDb[index] = updatedCard;
    }
  }

  Future<void> deleteFlashcard(String id) async {
    await Future.delayed(const Duration(milliseconds: 120));
    _memoryDb.removeWhere((item) => item.id == id);
  }

  // SQL FUTURO:
  // Trocar este repositório local por um serviço que converse com seu backend SQL.
}