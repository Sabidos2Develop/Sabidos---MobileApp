import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabidos2app/data/repositories/api_flashcards_repository.dart';
import 'package:sabidos2app/domain/models/flashcard_collection.dart';
import 'package:sabidos2app/domain/models/flashcard_model.dart';
import 'package:sabidos2app/presentation/dialogs/create_collection_dialog.dart';
import 'package:sabidos2app/presentation/dialogs/create_flashcard_dialog.dart';
import 'package:sabidos2app/presentation/dialogs/edit_flashcard_dialog.dart';
import 'package:sabidos2app/presentation/dialogs/start_game_dialog.dart';
import 'package:sabidos2app/data/datasources/points_service.dart';
import 'package:sabidos2app/presentation/controllers/collection_controller.dart';

class FlashcardsPage extends StatefulWidget {
  const FlashcardsPage({super.key});

  @override
  State<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  final ApiFlashcardsRepository _repository = ApiFlashcardsRepository();

  @override
  void initState() {
    super.initState();
    // Dispara o carregamento inicial em background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectionController>().loadCollections();
    });
  }

  Future<void> _loadCollections() async {
    await context.read<CollectionController>().loadCollections();
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

  Future<T?> _showSheet<T>(Widget child) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF292535),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Color(0xFF423E51)),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: child,
      ),
    );
  }

  Future<void> _openCreateCollectionDialog() async {
    final result = await _showSheet<CollectionFormData>(
      const CreateCollectionDialog(),
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
      _showSnack('Erro ao criar coleção: $e');
    }
  }

  Future<void> _deleteCollection(String collectionId) async {
    final confirm = await _showSheet<bool>(
      SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
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
              const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.redAccent,
                size: 50,
              ),
              const SizedBox(height: 16),
              const Text(
                'Excluir coleção?',
                style: TextStyle(
                  color: Color(0xFFFBCB4E),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Isso removerá permanentemente a coleção e todos os seus cards.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Excluir',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
    );

    if (confirm != true) return;

    await _repository.deleteCollection(collectionId);
    await _loadCollections();
    _showSnack('Coleção excluída.');
  }

  bool _isNavigating = false;

  Future<void> _openCollectionDetails(FlashcardCollection collection) async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      final bool? changed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => _CollectionDetailsView(
            collectionId: collection.id,
            repository: _repository,
          ),
        ),
      );

      if (changed == true && mounted) {
        _loadCollections();
      }
    } catch (_) {
      // Erro silencioso na navegao
    } finally {
      _isNavigating = false;
    }
  }

  Future<void> _playCollection(FlashcardCollection collection) async {
    if (collection.flashcards == null || collection.flashcards.isEmpty) {
      _showSnack('Essa coleção ainda não tem flashcards.');
      return;
    }

    final config = await _showSheet<StartGameConfig>(
      StartGameDialog(maxCards: collection.flashcards.length),
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

    if (mounted) {
      await _loadCollections();
    }
  }

  @override
  Widget build(BuildContext context) {
    final collectionController = context.watch<CollectionController>();
    final collections = collectionController.collections;
    final isLoading = collectionController.isLoading;
    final error = collectionController.error;

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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFBCB4E),
        onPressed: () => _openCreateCollectionDialog(),
        child: const Icon(Icons.add, color: Color(0xFF171621)),
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
              _buildCollectionsPanel(collections, isLoading, error),
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
        border: Border.all(color: const Color(0xFF423E51)),
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

  Widget _buildCollectionsPanel(List<FlashcardCollection> collections, bool isLoading, String error) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF292535),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF423E51)),
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
                '${collections.length} coleção(ões)',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          if (error.isNotEmpty) ...[
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
                error,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (isLoading && collections.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFFBCB4E)),
              ),
            )
          else if (collections.isEmpty)
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
              itemCount: collections.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final collection = collections[index];

                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF423E51)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ÁREA DE CLIQUE: Apenas o conteúdo
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          debugPrint(
                            '--- CLIQUE DETECTADO NO CORPO: ${collection.titulo} ---',
                          );
                          _openCollectionDetails(collection);
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
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
                            ],
                          ),
                        ),
                      ),
                      // ÁREA DOS BOTÕES: Fora do GestureDetector principal
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _ActionChip(
                              icon: Icons.layers,
                              label: '${collection.flashcards.length} cards',
                              color: Colors.lightBlueAccent,
                              onTap: () {
                                debugPrint('--- CLIQUE INFO CARDS ---');
                                _openCollectionDetails(collection);
                              },
                            ),
                            _ActionChip(
                              icon: Icons.play_arrow_rounded,
                              label: 'Jogar',
                              color: const Color(0xFF6BE38A),
                              onTap: () {
                                debugPrint('--- CLIQUE JOGAR ---');
                                _playCollection(collection);
                              },
                            ),
                            _ActionChip(
                              icon: Icons.delete,
                              label: 'Excluir',
                              color: Colors.redAccent,
                              onTap: () {
                                debugPrint('--- CLIQUE EXCLUIR ---');
                                _deleteCollection(collection.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
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

  Future<T?> _showSheet<T>(Widget child) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF292535),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Color(0xFF423E51)),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: child,
      ),
    );
  }

  Future<void> _openCreateCardDialog() async {
    final result = await _showSheet<FlashcardFormData>(
      const CreateFlashcardDialog(),
    );

    if (result == null) return;
    if (!mounted) return;

    await widget.repository.addCardToCollection(
      widget.collectionId,
      FlashcardModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        frente: result.frente,
        verso: result.verso,
        data: _shortDate(DateTime.now()),
        createdAt: DateTime.now(),
        atualizadoEm: null,
        dificuldade: result.dificuldade,
      ),
    );

    if (!mounted) return;
    await _loadCollection();
    if (!mounted) return;
    _showSnack('Flashcard criado com sucesso!');
  }

  Future<void> _editCard(FlashcardModel card) async {
    final result = await _showSheet<FlashcardFormData>(
      EditFlashcardDialog(card: card),
    );

    if (result == null) return;
    if (!mounted) return;

    await widget.repository.updateCardInCollection(
      widget.collectionId,
      card.copyWith(
        frente: result.frente,
        verso: result.verso,
        data: _shortDate(DateTime.now()),
        atualizadoEm: DateTime.now(),
        dificuldade: result.dificuldade,
      ),
    );

    if (!mounted) return;
    await _loadCollection();
    if (!mounted) return;
    _showSnack('Flashcard atualizado!');
  }

  Future<void> _deleteCard(String cardId) async {
    final confirm = await _showSheet<bool>(
      SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
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
              const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.redAccent,
                size: 50,
              ),
              const SizedBox(height: 16),
              const Text(
                'Excluir card?',
                style: TextStyle(
                  color: Color(0xFFFBCB4E),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Deseja realmente remover este flashcard?',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Não'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Sim, Excluir',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
    );

    if (confirm != true) return;

    await widget.repository.deleteCardFromCollection(
      widget.collectionId,
      cardId,
    );
    if (!mounted) return;
    await _loadCollection();
    if (!mounted) return;
    _showSnack('Flashcard excluído.');
  }

  Future<void> _startGame(FlashcardCollection collection) async {
    if (collection.flashcards == null || collection.flashcards.isEmpty) {
      _showSnack('Adicione ao menos 1 card para jogar.');
      return;
    }

    final config = await _showSheet<StartGameConfig>(
      StartGameDialog(maxCards: collection.flashcards.length),
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
        side: BorderSide(color: Color(0xFF423E51)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.82,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
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
                      card.frente,
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
            border: Border.all(color: const Color(0xFF423E51)),
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

    if (_loading && collection == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF171621),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFBCB4E)),
        ),
      );
    }

    if (collection == null) {
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
          title: const Text(
            'Erro',
            style: TextStyle(
              color: Color(0xFFFBCB4E),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'Erro ao carregar coleção',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

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
          collection.titulo,
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
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF292535),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF423E51)),
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
                  border: Border.all(color: const Color(0xFF423E51)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: _SectionHeader(title: 'Flashcards da Coleção'),
                        ),
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
                    if (collection.flashcards.isEmpty)
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
                                border: Border.all(
                                  color: const Color(0xFF423E51),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          card.frente,
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

    if (widget.collection.flashcards == null ||
        widget.collection.flashcards.isEmpty) {
      _cards = [];
      return;
    }

    try {
      final shuffled = List<FlashcardModel>.from(
        widget.collection.flashcards ?? [],
      );
      shuffled.shuffle(Random());
      _cards = shuffled.take(widget.quantidadeDeCards).toList();
    } catch (e) {
      print('Erro ao inicializar jogo: $e');
      _cards = [];
    }
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

    try {
      final service = PointsService();

      final result = await service.earnPoints(
        action: "FlashcardRespondido",
        data: {"score": _totalScore},
      );

      print("""
✅ Pontos ganhos: ${result.earnedPoints}

🏆 Total de pontos: ${result.totalPoints}

🎯 Conquistas:
${result.unlockedAchievements.isEmpty ? "Nenhuma" : result.unlockedAchievements.join("\n")}
""");
    } catch (e) {
      setState(() {
        print("❌ Erro:\n$e");
      });
    }

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

    final shouldLeave = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF292535),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Color(0xFF423E51)),
      ),
      builder: (sheetContext) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
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
                border: Border.all(color: const Color(0xFF423E51)),
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
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
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
                onPressed: () => Navigator.of(sheetContext).pop(true),
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
    if (_cards.isEmpty) {
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
        body: const SafeArea(
          child: Center(
            child: Text(
              'Nenhum flashcard disponível para jogar',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

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
                border: Border.all(color: const Color(0xFF423E51)),
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
                border: Border.all(color: const Color(0xFF423E51)),
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
                      border: Border.all(color: const Color(0xFF423E51)),
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
