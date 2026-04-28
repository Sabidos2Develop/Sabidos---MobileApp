import 'dart:math';
import 'package:flutter/material.dart';

import 'package:sabidos2app/data/repositories/api_flashcards_repository.dart';
import 'package:sabidos2app/domain/models/flashcard_collection.dart';
import 'package:sabidos2app/domain/models/flashcard_model.dart';
import 'package:sabidos2app/presentation/dialogs/create_collection_dialog.dart';
import 'package:sabidos2app/presentation/dialogs/create_flashcard_dialog.dart';
import 'package:sabidos2app/presentation/dialogs/edit_flashcard_dialog.dart';
import 'package:sabidos2app/presentation/dialogs/start_game_dialog.dart';

class FlashcardsPage extends StatefulWidget {
  const FlashcardsPage({super.key});

  @override
  State<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  final ApiFlashcardsRepository _repository = ApiFlashcardsRepository();

  List<FlashcardCollection> _collections = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final data = await _repository.getCollections();

      if (!mounted) return;
      setState(() {
        _collections = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Falha ao carregar coleções.';
        _loading = false;
      });
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2A2438),
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  String _formatShortDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m';
  }

  Future<void> _openCreateCollectionDialog() async {
    final result = await showDialog<CollectionFormData>(
      context: context,
      builder: (_) => const CreateCollectionDialog(),
    );

    if (result == null) return;
    if (!mounted) return;

    try {
      final collection = FlashcardCollection(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        titulo: result.titulo,
        descricao: result.descricao,
        criadoEm: DateTime.now(),
        flashcards: [],
      );

      await _repository.addCollection(collection);
      await _loadCollections();

      if (!mounted) return;
      _showSnack('Coleção criada com sucesso!');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'ERRO: $e';
      });
      }
  }

  Future<void> _deleteCollection(String collectionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF292535),
        title: const Text(
          'Excluir coleção',
          style: TextStyle(color: Color(0xFFFBCB4E)),
        ),
        content: const Text(
          'Tem certeza que deseja excluir esta coleção e todos os cards dela?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _repository.deleteCollection(collectionId);
    await _loadCollections();
    _showSnack('Coleção excluída.');
  }

  Future<void> _openCollectionDetails(FlashcardCollection collection) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CollectionDetailsView(
          collectionId: collection.id,
          repository: _repository,
        ),
      ),
    );

    await _loadCollections();
  }

  Future<void> _playCollection(FlashcardCollection collection) async {
    if (collection.flashcards.isEmpty) {
      _showSnack('Essa coleção ainda não tem flashcards.');
      return;
    }

    final config = await showDialog<StartGameConfig>(
      context: context,
      builder: (_) => StartGameDialog(maxCards: collection.flashcards.length),
    );

    if (config == null) return;
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FlashcardGameView(
          collection: collection,
          quantidadeDeCards: config.quantidade,
        ),
      ),
    );

    await _loadCollections();
  }

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateCollectionDialog,
        backgroundColor: const Color(0xFFFBCB4E),
        foregroundColor: const Color(0xFF292535),
        icon: const Icon(Icons.add),
        label: const Text(
          'Coleção',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFFBCB4E),
          backgroundColor: const Color(0xFF292535),
          onRefresh: _loadCollections,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            children: [
              _buildTopPanel(),
              const SizedBox(height: 16),
              _buildCollectionsPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopPanel() {
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Baralhos de Estudo'),
          SizedBox(height: 14),
          Text(
            'Crie coleções de flashcards por tema, organize seu estudo e entre no modo Jogar para testar sua memória.',
            style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.5),
          ),
          SizedBox(height: 14),
          _InfoBox(
            title: '💡 Como funciona',
            text:
                '• Crie uma coleção\n'
                '• Adicione seus cards\n'
                '• Escolha quantos cards quer jogar\n'
                '• Responda os cards embaralhados\n'
                '• Receba pontos conforme a dificuldade',
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsPanel() {
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
              const Expanded(child: _SectionHeader(title: 'Minhas Coleções')),
              Text(
                '${_collections.length} coleção(ões)',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
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
                child: CircularProgressIndicator(color: Color(0xFFFBCB4E)),
              ),
            )
          else if (_collections.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Column(
                children: [
                  Text('🃏', style: TextStyle(fontSize: 52)),
                  SizedBox(height: 10),
                  Text(
                    'Nenhuma coleção encontrada.',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Crie sua primeira coleção no botão abaixo.',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              itemCount: _collections.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final collection = _collections[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _openCollectionDetails(collection),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(18),
                      border: const Border(
                        left: BorderSide(color: Color(0xFFFBCB4E), width: 4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.style_rounded,
                              color: Color(0xFFFBCB4E),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                collection.titulo,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFFBCB4E),
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
                                _formatShortDate(collection.criadoEm),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (collection.descricao.trim().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            collection.descricao,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _ActionChip(
                              icon: Icons.layers,
                              label: '${collection.flashcards.length} cards',
                              color: Colors.lightBlueAccent,
                              onTap: () => _openCollectionDetails(collection),
                            ),
                            _ActionChip(
                              icon: Icons.play_arrow_rounded,
                              label: 'Jogar',
                              color: const Color(0xFF6BE38A),
                              onTap: () => _playCollection(collection),
                            ),
                            _ActionChip(
                              icon: Icons.delete,
                              label: 'Excluir',
                              color: Colors.redAccent,
                              onTap: () => _deleteCollection(collection.id),
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
}

class _CollectionDetailsView extends StatefulWidget {
  final String collectionId;
  final ApiFlashcardsRepository repository;

  const _CollectionDetailsView({
    required this.collectionId,
    required this.repository,
  });

  @override
  State<_CollectionDetailsView> createState() => _CollectionDetailsViewState();
}

class _CollectionDetailsViewState extends State<_CollectionDetailsView> {
  FlashcardCollection? _collection;
  bool _loading = true;
  String _error = '';
  final Set<String> _flipped = {};

  @override
  void initState() {
    super.initState();
    _loadCollection();
  }

  Future<void> _loadCollection() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final collection = await widget.repository.getCollectionById(
        widget.collectionId,
      );

      if (!mounted) return;
      setState(() {
        _collection = collection;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Falha ao carregar coleção.';
        _loading = false;
      });
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2A2438),
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  String _shortDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m';
  }

  Future<void> _openCreateCardDialog() async {
    final result = await showDialog<FlashcardFormData>(
      context: context,
      builder: (_) => const CreateFlashcardDialog(),
    );

    if (result == null) return;
    if (!mounted) return;

    await widget.repository.addCardToCollection(
      widget.collectionId,
      FlashcardModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        titulo: result.titulo,
        frente: result.frente,
        verso: result.verso,
        data: _shortDate(DateTime.now()),
        createdAt: DateTime.now(),
        atualizadoEm: null,
        dificuldade: result.dificuldade,
      ),
    );

    await _loadCollection();
    _showSnack('Flashcard criado com sucesso!');
  }

  Future<void> _editCard(FlashcardModel card) async {
    final result = await showDialog<FlashcardFormData>(
      context: context,
      builder: (_) => EditFlashcardDialog(card: card),
    );

    if (result == null) return;
    if (!mounted) return;

    await widget.repository.updateCardInCollection(
      widget.collectionId,
      card.copyWith(
        titulo: result.titulo,
        frente: result.frente,
        verso: result.verso,
        data: _shortDate(DateTime.now()),
        atualizadoEm: DateTime.now(),
        dificuldade: result.dificuldade,
      ),
    );

    await _loadCollection();
    _showSnack('Flashcard atualizado!');
  }

  Future<void> _deleteCard(String cardId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF292535),
        title: const Text(
          'Excluir flashcard',
          style: TextStyle(color: Color(0xFFFBCB4E)),
        ),
        content: const Text(
          'Deseja realmente excluir este flashcard?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await widget.repository.deleteCardFromCollection(
      widget.collectionId,
      cardId,
    );
    await _loadCollection();
    _showSnack('Flashcard excluído.');
  }

  Future<void> _startGame(FlashcardCollection collection) async {
    if (collection.flashcards.isEmpty) {
      _showSnack('Adicione ao menos 1 card para jogar.');
      return;
    }

    final config = await showDialog<StartGameConfig>(
      context: context,
      builder: (_) => StartGameDialog(maxCards: collection.flashcards.length),
    );

    if (config == null) return;
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FlashcardGameView(
          collection: collection,
          quantidadeDeCards: config.quantidade,
        ),
      ),
    );

    await _loadCollection();
  }

  void _openBottomSheet(FlashcardModel card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF292535),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.82,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
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
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBCB4E).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFFBCB4E).withOpacity(0.25),
                        ),
                      ),
                      child: Text(
                        'Dificuldade: ${card.dificuldade.label} • x${card.dificuldade.multiplier}',
                        style: const TextStyle(
                          color: Color(0xFFFBCB4E),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              Navigator.of(sheetContext).pop();
                              await Future.delayed(
                                const Duration(milliseconds: 10),
                              );
                              if (!mounted) return;
                              _editCard(card);
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
                              Navigator.of(sheetContext).pop();
                              await Future.delayed(
                                const Duration(milliseconds: 10),
                              );
                              if (!mounted) return;
                              _deleteCard(card.id);
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

  @override
  Widget build(BuildContext context) {
    final collection = _collection;

    return Scaffold(
      backgroundColor: const Color(0xFF171621),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171621),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFFFBCB4E),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          collection?.titulo ?? 'Coleção',
          style: const TextStyle(
            color: Color(0xFFFBCB4E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateCardDialog,
        backgroundColor: const Color(0xFFFBCB4E),
        foregroundColor: const Color(0xFF292535),
        icon: const Icon(Icons.add),
        label: const Text(
          'Flashcard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFFBCB4E),
          backgroundColor: const Color(0xFF292535),
          onRefresh: _loadCollection,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            children: [
              if (collection != null)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF292535),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeader(title: 'Detalhes da Coleção'),
                      const SizedBox(height: 12),
                      if (collection.descricao.trim().isNotEmpty)
                        Text(
                          collection.descricao,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                      if (collection.descricao.trim().isNotEmpty)
                        const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ActionChip(
                            icon: Icons.layers,
                            label: '${collection.flashcards.length} cards',
                            color: Colors.lightBlueAccent,
                            onTap: () {},
                          ),
                          _ActionChip(
                            icon: Icons.play_arrow_rounded,
                            label: 'Jogar',
                            color: const Color(0xFF6BE38A),
                            onTap: () => _startGame(collection),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF292535),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: _SectionHeader(title: 'Flashcards da Coleção'),
                        ),
                        if (collection != null)
                          Text(
                            '${collection.flashcards.length} card(s)',
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
                    else if (collection == null ||
                        collection.flashcards.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Column(
                          children: [
                            Text('🃏', style: TextStyle(fontSize: 52)),
                            SizedBox(height: 10),
                            Text(
                              'Nenhum flashcard nesta coleção.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Crie seu primeiro card no botão abaixo.',
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
                        itemCount: collection.flashcards.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, index) {
                          final card = collection.flashcards[index];
                          final isFlipped = _flipped.contains(card.id);

                          return InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _openBottomSheet(card),
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
                                          card.titulo,
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          card.data,
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
                                    isFlipped ? card.verso : card.frente,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      height: 1.45,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFBCB4E,
                                      ).withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFFBCB4E,
                                        ).withOpacity(0.25),
                                      ),
                                    ),
                                    child: Text(
                                      'Dificuldade: ${card.dificuldade.label} • x${card.dificuldade.multiplier}',
                                      style: const TextStyle(
                                        color: Color(0xFFFBCB4E),
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _ActionChip(
                                        icon: Icons.sync,
                                        label: isFlipped ? 'Frente' : 'Verso',
                                        color: Colors.lightBlueAccent,
                                        onTap: () {
                                          setState(() {
                                            if (_flipped.contains(card.id)) {
                                              _flipped.remove(card.id);
                                            } else {
                                              _flipped.add(card.id);
                                            }
                                          });
                                        },
                                      ),
                                      _ActionChip(
                                        icon: Icons.edit,
                                        label: 'Editar',
                                        color: Colors.blueAccent,
                                        onTap: () => _editCard(card),
                                      ),
                                      _ActionChip(
                                        icon: Icons.delete,
                                        label: 'Excluir',
                                        color: Colors.redAccent,
                                        onTap: () => _deleteCard(card.id),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlashcardGameView extends StatefulWidget {
  final FlashcardCollection collection;
  final int quantidadeDeCards;

  const _FlashcardGameView({
    required this.collection,
    required this.quantidadeDeCards,
  });

  @override
  State<_FlashcardGameView> createState() => _FlashcardGameViewState();
}

class _FlashcardGameViewState extends State<_FlashcardGameView> {
  late final List<FlashcardModel> _cards;
  final TextEditingController _answerController = TextEditingController();

  int _currentIndex = 0;
  int _totalScore = 0;
  bool _answered = false;
  int _lastScore = 0;
  String _feedbackTitle = '';
  String _feedbackText = '';
  String _normalizedExpected = '';

  FlashcardModel get _currentCard => _cards[_currentIndex];

  @override
  void initState() {
    super.initState();
    final shuffled = List<FlashcardModel>.from(widget.collection.flashcards);
    shuffled.shuffle(Random());

    _cards = shuffled.take(widget.quantidadeDeCards).toList();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  String _normalize(String text) {
    return text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  int _scoreAnswer(String userAnswer, String expectedAnswer) {
    final user = _normalize(userAnswer);
    final expected = _normalize(expectedAnswer);

    if (user.isEmpty) return 0;
    if (user == expected) return 100;
    if (expected.contains(user) || user.contains(expected)) return 60;
    return 0;
  }

  void _checkAnswer() {
    if (_answered) return;

    final typed = _answerController.text;
    final expected = _currentCard.verso;
    final base = _scoreAnswer(typed, expected);
    final score = base * _currentCard.dificuldade.multiplier;

    String title;
    String text;

    if (base == 100) {
      title = 'Acerto excelente';
      text =
          'Resposta correta. $base x ${_currentCard.dificuldade.multiplier} = $score pontos.';
    } else if (base == 60) {
      title = 'Quase lá';
      text =
          'Sua resposta chegou perto. $base x ${_currentCard.dificuldade.multiplier} = $score pontos.';
    } else {
      title = 'Não foi dessa vez';
      text = 'A resposta esperada era mostrada abaixo.';
    }

    setState(() {
      _answered = true;
      _lastScore = score;
      _totalScore += score;
      _feedbackTitle = title;
      _feedbackText = text;
      _normalizedExpected = expected;
    });
  }

  void _nextCard() {
    if (_currentIndex == _cards.length - 1) {
      _finishGame();
      return;
    }

    setState(() {
      _currentIndex++;
      _answered = false;
      _lastScore = 0;
      _feedbackTitle = '';
      _feedbackText = '';
      _normalizedExpected = '';
      _answerController.clear();
    });
  }

  Future<void> _finishGame() async {
    final maxScore = _cards.fold<int>(
      0,
      (sum, card) => sum + (100 * card.dificuldade.multiplier),
    );

    final percent = maxScore == 0
        ? 0
        : ((_totalScore / maxScore) * 100).round();

    String medal;
    String message;

    if (percent >= 85) {
      medal = '🏆';
      message = 'Desempenho excelente. Você mandou muito bem!';
    } else if (percent >= 60) {
      medal = '🎯';
      message = 'Bom desempenho. Continue revisando para subir ainda mais.';
    } else {
      medal = '📚';
      message = 'Você já começou. Agora é revisar e tentar novamente.';
    }

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF292535),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(medal, style: const TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              const Text(
                'Resultado Final',
                style: TextStyle(
                  color: Color(0xFFFBCB4E),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.collection.titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                  border: const Border(
                    left: BorderSide(color: Color(0xFFFBCB4E), width: 4),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '$_totalScore pontos',
                      style: const TextStyle(
                        color: Color(0xFFFBCB4E),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$percent% de aproveitamento',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFBCB4E),
                    foregroundColor: const Color(0xFF292535),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Voltar às coleções',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldLeave == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIndex + 1) / _cards.length;

    return Scaffold(
      backgroundColor: const Color(0xFF171621),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171621),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFFFBCB4E),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Jogar • ${widget.collection.titulo}',
          style: const TextStyle(
            color: Color(0xFFFBCB4E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF292535),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology, color: Color(0xFFFBCB4E)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Card ${_currentIndex + 1} de ${_cards.length}',
                          style: const TextStyle(
                            color: Color(0xFFFBCB4E),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '$_totalScore pts',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFFFBCB4E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
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
                  const _SectionHeader(title: 'Pergunta'),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(16),
                      border: const Border(
                        left: BorderSide(color: Color(0xFFFBCB4E), width: 4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentCard.frente,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBCB4E).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFFBCB4E).withOpacity(0.35),
                            ),
                          ),
                          child: Text(
                            'Dificuldade: ${_currentCard.dificuldade.label} • x${_currentCard.dificuldade.multiplier}',
                            style: const TextStyle(
                              color: Color(0xFFFBCB4E),
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sua resposta',
                    style: TextStyle(
                      color: Color(0xFFFBCB4E),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _answerController,
                    enabled: !_answered,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Digite a resposta do verso do card...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1A1A2E),
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
                  const SizedBox(height: 16),
                  if (_answered)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _lastScore > 0
                            ? const Color(0xFF163222)
                            : const Color(0xFF341A1A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _lastScore > 0
                              ? const Color(0xFF6BE38A)
                              : Colors.redAccent,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_feedbackTitle • +$_lastScore pts',
                            style: TextStyle(
                              color: _lastScore > 0
                                  ? const Color(0xFF6BE38A)
                                  : Colors.redAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _feedbackText,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Resposta esperada:',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _normalizedExpected,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _answered ? null : _checkAnswer,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Corrigir'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFBCB4E),
                            side: const BorderSide(color: Color(0xFFFBCB4E)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _answered ? _nextCard : null,
                          icon: Icon(
                            _currentIndex == _cards.length - 1
                                ? Icons.emoji_events
                                : Icons.arrow_forward,
                          ),
                          label: Text(
                            _currentIndex == _cards.length - 1
                                ? 'Finalizar'
                                : 'Próximo',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFBCB4E),
                            foregroundColor: const Color(0xFF292535),
                            disabledBackgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFFBCB4E), width: 2)),
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

class _InfoBox extends StatelessWidget {
  final String title;
  final String text;

  const _InfoBox({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          left: BorderSide(color: Color(0xFF3085AA), width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF3085AA),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
