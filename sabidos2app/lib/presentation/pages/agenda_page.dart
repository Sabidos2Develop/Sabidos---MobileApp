import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sabidos2app/data/repositories/agenda_repository.dart';
import 'package:sabidos2app/domain/models/agenda_event_model.dart';
import 'package:sabidos2app/presentation/dialogs/create_event_dialog.dart';
import 'package:sabidos2app/presentation/dialogs/edit_event_dialog.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final AgendaRepository _repository = AgendaRepository();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mapa para armazenar os compromissos (Agrupados por dia)
  Map<DateTime, List<AgendaEventModel>> events = {};
  bool _isLoading = true;

  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Otimizao: Pequeno atraso para no travar a transio de tela
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _loadEvents();
    });
  }

  Future<void> _loadEvents() async {
  if (!mounted) return;

  if (!_isFirstLoad && _isLoading) return;

  setState(() => _isLoading = true);

  try {
    final data = await _repository.getEvents();

    if (!mounted) return;

    final Map<DateTime, List<AgendaEventModel>> newEvents = {};

    for (var event in data) {
      final eventDate = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );

      if (newEvents[eventDate] == null) {
        newEvents[eventDate] = [];
      }
      newEvents[eventDate]!.add(event);
    }

    if (!mounted) return;

    setState(() {
      events = newEvents;
      _isLoading = false;
      _isFirstLoad = false;
    });
  } catch (e) {
    if (!mounted) return;

    final errorMessage = 'Erro ao carregar eventos';
    
    setState(() {
      _isLoading = false;
      _isFirstLoad = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Tentar',
          onPressed: _loadEvents,
        ),
      ),
    );

    debugPrint('Erro ao carregar eventos: $e');
  }
}

  List<AgendaEventModel> _getEventsForDay(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
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
      builder: (context) => child,
    );
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
          'Agenda',
          style: TextStyle(
            color: Color(0xFFFBCB4E),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFBCB4E)),
            )
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.only(bottom: 12),
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
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    eventLoader: _getEventsForDay,

                    calendarStyle: const CalendarStyle(
                      defaultTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      weekendTextStyle: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                      todayTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Color(0x66FBCB4E),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Color(0xFFFBCB4E),
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: TextStyle(
                        color: Color(0xFF171621),
                        fontWeight: FontWeight.bold,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Color(0xFF1499E2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                      weekendStyle: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Eventos do Dia',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                Expanded(child: _buildEventList()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFBCB4E),
        onPressed: () => _showAddEventDialog(),
        child: const Icon(Icons.add, color: Color(0xFF171621)),
      ),
    );
  }

  Widget _buildEventList() {
    final dayEvents = _getEventsForDay(_selectedDay!);

    if (dayEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tudo limpo por aqui!',
              style: TextStyle(
                color: Colors.white30,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              'Toque no + para adicionar um evento.',
              style: TextStyle(
                color: Colors.white24,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: dayEvents.length,
      itemBuilder: (context, index) {
        final event = dayEvents[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF292535),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF423E51)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFBCB4E),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.white38,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Criado em: ${_formatDate(event.createdAt)}',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white70,
                    size: 22,
                  ),
                  onPressed: () => _showEditEventDialog(event),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                  onPressed: () => _showDeleteConfirmation(event),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation(AgendaEventModel event) {
    _showSheet(
      Padding(
        padding: const EdgeInsets.all(24),
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
            const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 50),
            const SizedBox(height: 16),
            const Text(
              'Excluir?',
              style: TextStyle(color: Color(0xFFFBCB4E), fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Deseja realmente remover este compromisso?',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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
                    onPressed: () async {
                      Navigator.pop(context);
                      await _repository.deleteEvent(event.id);
                      _loadEvents();
                    },
                    child: const Text('Sim, Excluir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditEventDialog(AgendaEventModel event) async {
    final result = await _showSheet<String>(EditEventDialog(event: event));

    if (result != null && result.isNotEmpty) {
      await _repository.updateEvent(event.id, result, _selectedDay!);
      _loadEvents();
    }
  }

  Future<void> _showAddEventDialog() async {
    final result = await _showSheet<String>(const CreateEventDialog());

    if (result != null && result.isNotEmpty) {
      await _repository.addEvent(result, _selectedDay!);
      _loadEvents();
    }
  }
}
